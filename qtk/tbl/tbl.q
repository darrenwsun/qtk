import "type";
import "utils";

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
// @return {table} An empty table with a single row that matches the metadata.
.qtk.tbl._singleton:{[tabMeta]
  tabMeta:0!tabMeta;
  v:enlist each .qtk.type.defaults raze string tabMeta`t;
  flip (tabMeta`c)!v
  };

// @kind function
// @private
// @subcategory db
// @overview Return an empty table that matches a given table schema.
// @param tabMeta {table)} Metadata of a table.
// @return {table} An empty table that matches the metadata.
.qtk.tbl._empty:{[tabMeta]
  0#.qtk.tbl._singleton tabMeta
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
// @overview Update values in certain columns of a table, in a similar format to functional update.
// @param table {symbol | table} Table name or value.
// @param criteria {*[]} A list of criteria where the update is applied to, or empty list if it's applied to the whole table.
// @param assignment {dict} A mapping from column names to values of parse-tree form
// @return {symbol} The table name.
// @throws {ColumnNotFoundError: [*]} If a column doesn't exist.
.qtk.tbl.update:{[tableName;criteria;assignment]
  .qtk.db._validateColumnExists[tableName;] each key assignment;

  tableType:.qtk.db.getTableType tableName;
  $[tableType=`Plain;
    ![tableName; criteria; 0b; assignment];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.tbl._update[tablePath; criteria; assignment];
      ];
    // tableType=`Partitioned
    [
      partitionField:.qtk.db.getPartitionField[];
      $[(first criteria)[1]~partitionField;
        [
          partitions:?[tableName; enlist first criteria; 0b; (enlist partitionField)!(enlist partitionField)] partitionField;
          tablePaths:{.Q.par[`:.; x; y]}[; tableName] each partitions;
          .qtk.tbl._update[; 1_criteria; assignment] each tablePaths;
          ];
        [
          partitions:.qtk.db.getCurrentPartitions[];
          tablePaths:{.Q.par[`:.; x; y]}[; tableName] each partitions;
          .qtk.tbl._update[; criteria; assignment] each tablePaths;
          ]
       ];
      ]
   ];

  tableName
 };

// @kind function
// @private
// @overview Update values in certain columns of an on-disk table, in a similar format to functional update.
// @param tablePath {hsym} Path to an on-disk table.
// @param criteria {*[]} A list of criteria where the update is applied to, or empty list if it's applied to the whole table.
// @param assignment {dict} A mapping from column names to values
// @return {hsym} The path to the table.
// @throws {type} If it's a partial update and the new values are not type-compatible with existing values.
.qtk.tbl._update:{[tablePath;criteria;assignment]
  updated:?[tablePath; criteria; 0b; assignment,((enlist `index)!(enlist `i))];
  if[0=count updated; :tablePath];

  i:0;
  allColumns:.qtk.db._getColumns tablePath;
  do[count assignment;
     column:key[assignment] [i];
     columnVal:.qtk.db._enumerate updated column;
     $[column in allColumns;
       [
         columnPath:.Q.dd[tablePath; column];
         $[criteria~();
           .[columnPath; (); :; columnVal];                   // rewrite the whole column
           .Q.ty[columnVal]=.Q.ty[get columnPath];
           @[columnPath; updated`index; :; columnVal];                   // update values at certain indices
           '"type"
          ];
         ];
       .qtk.db._addColumn[tablePath; column; columnVal]
      ];
     i +: 1;
   ];
  tablePath
 };

// @kind function
// @subcategory db
// @overview Select from a table based on given criteria, groupings, and column mappings, in a similar format to functional select.
// @param table {symbol | table} Table name or value.
// @param criteria {*[]} A list of criteria where the select is applied to, or empty list for the whole table.
// @param groupings {*} A mapping of grouping columns, or `0b` for no grouping, `1b` for distinct.
// @param assignment {dict} A mapping from column names to values of parse-tree form.
// @return {table} Selected data from the table.
.qtk.tbl.select:{[tableName;criteria;groupings;assignment]
  ?[tableName; criteria; groupings; assignment]
 };

// @kind function
// @subcategory db
// @overview Similar to `.qtk.tbl.select` but with a limit on rows.
// @param tableName {symbol | table} Table name or value.
// @param criteria {*[]} A list of criteria where the select is applied to, or empty list for the whole table.
// @param groupings {*} A mapping of grouping columns, or `0b` for no grouping, `1b` for distinct.
// @param assignment {dict} A mapping from column names to values of parse-tree form.
// @param limit {int | long | (int;int) | (long;long)} Limit on rows to return.
// @return {table} Selected data from the table.
.qtk.tbl.selectLimit:{[tableName;criteria;groupings;assignment;limit]
  select[limit] from ?[tableName; criteria; groupings; assignment]
 };

// @kind function
// @subcategory db
// @overview Similar to `.qtk.tbl.selectLimit` but with sorting.
// @param tableName {symbol | table} Table name or value.
// @param criteria {*[]} A list of criteria where the select is applied to, or empty list for the whole table.
// @param groupings {*} A mapping of grouping columns, or `0b` for no grouping, `1b` for distinct.
// @param assignment {dict} A mapping from column names to values of parse-tree form.
// @param limit {int | long | (int;int) | (long;long)} Limit on rows to return.
// @param sort {*[]} Sort the result by a column. The format is `(op;col)` where `op` is `>:` for descending and
//   `<:` for ascending, and `col` is the column to be ordered by.
// @return {table} Selected data from the table.
.qtk.tbl.selectLimitSort:{[tableName;criteria;groupings;assignment;limit;sort]
  ?[?[tableName; criteria; groupings; assignment];
    ();
    0b;
    ();
    limit;
    sort]
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
      .qtk.tbl._delete[tablePath; criteria];
      ];
    tableType=`Partitioned;
    [
      parField:.qtk.db.getPartitionField[];
      $[(first criteria)[1]~parField;
        [
          partitions:?[tabRef; enlist first criteria; 0b; (enlist parField)!(enlist parField)] parField;
          tablePaths:{.Q.par[`:.; x; y]}[; tabRef] each partitions;
          .qtk.tbl._delete[; 1_criteria] each tablePaths;
          ];
        [
          partitions:.qtk.db.getCurrentPartitions[];
          tablePaths:{.Q.par[`:.; x; y]}[; tabRef] each partitions;
          .qtk.tbl._delete[; criteria] each tablePaths;
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
.qtk.tbl._delete:{[tablePath;criteria]
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
// @overview Count rows of a table.
// @param tab {symbol | table} Table, by name or value.
// @return {long} Row count of the table.
.qtk.tbl.count:{[tab]
  $[98h=type tab; count tab; count get tab]
 };

// @kind function
// @overview Check if a table of given name exists.
// @param tblName {symbol} Table name.
// @return {boolean} `1b` if the table exists; `0b` otherwise.
.qtk.tbl.exists:{[tblName]
  $[.qtk.utils.nameExists tblName; .qtk.type.isTable tblName; 0b]
 };

// @kind function
// @overview Get entries at given indices of a table.
// @param tblName {symbol} Table name.
// @param indices {int[] | long[]} Indices.
// @return {table} `1b` if the table exists; `0b` otherwise.
.qtk.tbl.index:{[tblName;indices]
  tabRefDesc:.qtk.tbl._desc tblName;
  tableType:tabRefDesc`type;
  tableName:tabRefDesc`name;

  result:$[tableType in `Plain`Serialized`Splayed;
           select from tblName where i in indices;
           tableType in `Partitioned`Segmented;
           [
             r:.Q.ind[get tableName; indices];
             $[r~(); .Q.en[`:.; ] .qtk.tbl._empty meta tableName; r]
             ];
           '.qtk.err.compose[`TableTypeError; "invalid table type [",string[tableType],"]"]
   ];
  result
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
