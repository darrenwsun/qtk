import "type";

// @kind function
// @subcategory db
// @overview Create a new table with given data.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference. It's a symbol for plain table,
// hsym for serialized and splayed table, or 3-element list composed of DB directory, partition field, and table name
// @param data {table} Table data.
// @return {symbol} The table name.
// @throws {TableTypeError: invalid table type [*]} If the table type is not valid.
.qtk.tbl.create:{[tabRef;data]
  tabRefDesc:.qtk.tbl._desc tabRef;
  tableType:tabRefDesc`type;
  tableName:tabRefDesc`name;

  $[tableType in `Plain`Serialized;
    tabRef set data;
    tableType=`Splayed;
    [
      dbDir:tabRefDesc`dbDir;
      tablePath:.Q.dd[dbDir; tableName];
      .qtk.db._addTable[dbDir; tablePath; data];
      ];
    tableType=`Partitioned;
    [
      dbDir:tabRefDesc`dbDir;
      parField:tabRefDesc`parField;
      parValues:distinct ?[data; (); (); parField];
      tablePaths:.Q.par[dbDir; ; tableName] each parValues;
      dataByPartition:flip each value parField xgroup data;
      .qtk.db._addTable[dbDir;;]'[tablePaths; dataByPartition];
      ];
    '.qtk.err.compose[`TableTypeError; "invalid table type [",string[tableType],"]"]
   ];
  tableName
 };

// @kind function
// @private
// @subcategory db
// @overview Return a table with a single row that matches a given table schema.
// @param tabMeta {table)} Metadata of a table.
// @return {symbol} a table with a single row that matches the metadata.
.qtk.tbl._singleton:{[tabMeta]
  tabMeta:0!tabMeta;
  v:enlist each .qtk.type.defaults raze string tabMeta`t;
  flip (tabMeta`c)!v
  };

// @kind function
// @subcategory db
// @overview Drop a table.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference. It's a symbol for plain table,
// hsym for serialized and splayed table, or 3-element list composed of DB directory, partition field, and table name
.qtk.tbl.drop:{[tabRef]
  tabRefDesc:.qtk.tbl._desc tabRef;
  tableType:tabRefDesc`type;
  tableName:tabRefDesc`name;

  $[tableType in `Plain;
    ![`.; (); 0b; enlist tableName];
    tableType in `Serialized`Splayed;
    [
      dbDir:tabRefDesc`dbDir;
      tablePath:.Q.dd[dbDir; tableName];
      .qtk.os.rmtree tablePath;
      ];
    tableType=`Partitioned;
    [
      dbDir:tabRefDesc`dbDir;
      tablePaths:.Q.par[dbDir; ; tableName] each .qtk.db.getCurrentPartitions[];
      .qtk.os.rmtree each tablePaths;
      ];
    '.qtk.err.compose[`TableTypeError; "invalid table type [",string[tableType],"]"]
   ];
  ![`.; (); 0b; enlist tableName];
 };

// @kind function
// @private
// @subcategory db
// @overview Describe a table reference.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference. It's a symbol for plain table,
// hsym for serialized and splayed table, or 3-element list composed of DB directory, partition field, and table name
// @return {dict (type:symbol; name:symbol; dbDir:symbol; parField:symbol)} A dictionary describing the table reference.
// @throws {TypeError} If `tabRef` is not of valid type.
.qtk.tbl._desc:{[tabRef]
  if[11h<>abs type tabRef; '.qtk.err.compose[`TypeError; "expect symbol or symbol vector"]];
  tableType:.qtk.db.getTableType tabRef;

  dbDir:tableName:parField:`;
  $[tableType=`Plain;
    tableName:tabRef;
    tableType=`Serialized;
    [
      split:` vs tabRef;
      dbDir:first split;
      tableName:last split
      ];
    tableType=`Splayed;
    [
      $["/"=last string tabRef;
        [
          // tabRef is a full path
         split:` vs `$-1 _ string tabRef;
         dbDir:first split;
         tableName:last split
          ];
        [
          // tabRef is the table name
         dbDir:`:.;
         tableName:tabRef
          ]
       ];
      ];
    [
      $[11h=type tabRef;
        [
          // tabRef is a full path
         dbDir:tabRef[0];
         parField:tabRef[1];
         tableName:tabRef[2]
          ];
        [
          // tabRef is the table name
         dbDir:`:.;
         parField:.Q.pf;
         tableName:tabRef
          ]
       ]
      ]
   ];

  r:.[!;] flip (
    (`type;tableType);
    (`name;tableName);
    (`dbDir;dbDir);
    (`parField;parField)
    );
  r
 };

// @kind function
// @subcategory db
// @overview Insert data into a table.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference. It's a symbol for plain table,
// hsym for serialized and splayed table, or 3-element list composed of DB directory, partition field, and table name
// for partitioned table.
// @param data {table} Table data.
// @return {symbol | hsym} `t` itself.
// @throws {TableTypeError: invalid table type [*]} If the table type is not valid.
.qtk.tbl.insert:{[tabRef;data]
  tabRefDesc:.qtk.tbl._desc tabRef;
  tableType:tabRefDesc`type;
  tableName:tabRefDesc`name;

  $[tableType=`Plain;
    tabRef insert data;
    tableType=`Serialized;
    tabRef insert data;
    tableType=`Splayed;
    [
      dbDir:tabRefDesc`dbDir;
      tablePath:` sv (dbDir; tableName; `);
      completeData:1 _ (.qtk.tbl._singleton meta tableName) upsert data;     // in case data don't have some columns
      enumeratedData:.Q.en[dbDir; completeData];
      .qtk.tbl._insert[tablePath; enumeratedData]
      ];
    tableType=`Partitioned;
    [
      dbDir:tabRefDesc`dbDir;
      completeData:1 _ (.qtk.tbl._singleton meta tableName) upsert data;     // in case data don't have some columns
      enumeratedData:.Q.en[dbDir; completeData];
      parField:tabRefDesc`parField;
      parValues:distinct ?[enumeratedData; (); (); parField];
      tablePaths:.Q.dd[; `] each .Q.par[dbDir; ; tableName] each parValues;
      dataByPartition:flip each value parField xgroup enumeratedData;
      .qtk.tbl._insert'[tablePaths; dataByPartition];
      ];
    '.qtk.err.compose[`TableTypeError; "invalid table type [",string[tableType],"]"]
   ];
  tableName
 };

// @kind function
// @subcategory db
// @overview Insert data into a table.
// @param tablePath {hsym} Path to an on-disk table.
// @param data {table} Table data.
// @return {hsym} `tablePath` itself.
.qtk.tbl._insert:{[tablePath;data]
  tablePath upsert data
 };

// @kind function
// @subcategory db
// @overview Delete rows of a table given certain criteria.
// @param tabRef {symbol | hsym} Table reference.
// @param criteria {*[]} A list of criteria where matching rows will be deleted, or empty list if it's applied to the whole table.
// @return {symbol} The table name.
.qtk.tbl.delete:{[tabRef;criteria]
  tabRefDesc:.qtk.tbl._desc tabRef;
  tableType:tabRefDesc`type;
  tableName:tabRefDesc`name;

  $[tableType=`Plain;
    ![tabRef; criteria; 0b; `$()];
    tableType=`Serialized;
    tabRef set ![get tabRef; criteria; 0b; `$()];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tabRef];
      .qtk.db._delete[tablePath; criteria];
      ];
    tableType=`Partitioned;
    [
      parField:.qtk.db.getPartitionField[];
      $[(first criteria)[1]~parField;
        [
          partitions:?[tabRef; enlist first criteria; 0b; (enlist parField)!(enlist parField)] parField;
          tablePaths:{.Q.par[`:.; x; y]}[; tabRef] each partitions;
          .qtk.db._delete[; 1_criteria] each tablePaths;
          ];
        [
          partitions:.qtk.db.getCurrentPartitions[];
          tablePaths:{.Q.par[`:.; x; y]}[; tabRef] each partitions;
          .qtk.db._delete[; criteria] each tablePaths;
          ]
       ];
      ];
    '.qtk.err.compose[`TableTypeError; "invalid table type [",string[tableType],"]"]
   ];
  tableName
 };

// @kind function
// @private
// @overview Delete rows of an on-disk table given certain criteria, in a similar format to functional delete.
// @param tablePath {hsym} Path to an on-disk table.
// @param criteria {*[]} A list of criteria where matching rows will be deleted, or empty list if it's applied to the whole table.
// @return {hsym} The path to the table.
.qtk.db._delete:{[tablePath;criteria]
  indicesToDelete:exec index from ?[tablePath; criteria; 0b; (enlist `index)!(enlist `i)];
  if[0=count indicesToDelete; :tablePath];

  rowCount:.qtk.db._rowCount tablePath;
  remainingIndices:(til rowCount) except indicesToDelete;

  i:0;
  allColumns:.qtk.db._getColumns tablePath;
  do[count allColumns;
     columnPath:.Q.dd[tablePath; allColumns[i]];
     .[columnPath; (); :; get[columnPath] remainingIndices];
     i +: 1;
   ];
  tablePath
 };

// @kind function
// @subcategory db
// @overview Rename a table.
// @param tableName {symbol} Table name.
// @param newName {symbol} New name of the table.
// @return {symbol} New table name.
.qtk.tbl.rename:{[tableName;newName]
  tableType:.qtk.db.getTableType tableName;
  $[tableType=`Plain;
    [
      newName set get tableName;
      ![`.; (); 0b; enlist tableName];
      ];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.db._renameTable[tablePath; newName];
      ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getCurrentPartitions[];
      .qtk.db._renameTable[; newName] each tablePaths;
      ]
   ];
  newName
 };
