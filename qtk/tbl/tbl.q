.qtk.import.loadModule["type";`qtk];
.qtk.import.loadModule["utils";`qtk];
.qtk.import.loadModule["db";`qtk];

// @kind function
// @subcategory tbl
// @overview Get table type, either of `` `Plain`Serialized`Splayed`Partitioned ``. Note that tables in segmented database are
// classified as Partitioned.
//
// See also [.Q.qp](https://code.kx.com/q/ref/dotq/#qqp-is-partitioned).
// @param t {table | symbol | hsym | (hsym; symbol; symbol)} Table name, value, path, or a 3-element tuple consisting
// of database directory, partition field, and table name.
// @return {symbol} Table type.
// @throws {ValueError: [*]} If `t` isn't a valid value.
// @doctest A plain table.
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
// `t set ([]c1:til 3);
//
// `Plain=.qtk.tbl.getType t
.qtk.tbl.getType:{[t]
  v:$[-11h=type t;
      [
        if[":"=first str:string t;
           :$["/"=last str; `Splayed; `Serialized]];
        tvar:@[get; t; ::];
        if[tvar~(::); :`Plain];   // t is undefined, treated as the name of a new plain table
        tvar
        ];
      11h=type t;
      [
       // format: (dbDir; pfield; tableName)
       if[3<>count t; '.qtk.err.compose[`ValueError; "expect 3 elements"]];
       if[":"<>first string first t; '.qtk.err.compose[`ValueError; "expect hsym as the first element"]];
       if[not t[1] in `int`date`month`year; '.qtk.err.compose[`ValueError; "expect a valid partition field"]];
       :`Partitioned
        ];
      t
   ];
  isPartitioned:.Q.qp v;
  $[isPartitioned~1b; `Partitioned;
    isPartitioned~0b; `Splayed;
    `Plain
   ]
 };

// @kind function
// @subcategory tbl
// @overview Create a new table with given data.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference.
// @param data {table} Table data.
// @return {symbol | hsym | (hsym; symbol; symbol)} The table reference.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
// tabRef:(`:/tmp/qtk/tbl/create; `date; `PartitionedTable);
//
// tabRef~.qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)]
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
      .qtk.tbl._addTable[dbDir; tablePath; data];
      ];
    [
      dbDir:tabRefDesc`dbDir;
      parField:tabRefDesc`parField;
      parValues:distinct ?[data; (); (); parField];
      tablePaths:.Q.par[dbDir; ; tableName] each parValues;
      dataByPartition:flip each value parField xgroup data;
      .qtk.tbl._addTable[dbDir;;]'[tablePaths; dataByPartition];
      ]
   ];
  tabRef
 };

// @kind function
// @private
// @overview Add a table to a path.
// @param dbDir {hsym} DB directory.
// @param tablePath {hsym} Path to an on-disk table.
// @param data {table} Table data.
// @return {hsym} The path to the table.
.qtk.tbl._addTable:{[dbDir;tablePath;data]
  @[tablePath; `; :; .Q.en[dbDir; data]];
  tablePath
 };

// @kind function
// @private
// @subcategory tbl
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
// @subcategory tbl
// @overview Return an empty table that matches a given table schema.
// @param tabMeta {table)} Metadata of a table.
// @return {table} An empty table that matches the metadata.
.qtk.tbl._empty:{[tabMeta]
  0#.qtk.tbl._singleton tabMeta
 };

// @kind function
// @subcategory tbl
// @overview Drop a table.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference.
// @return {symbol | hsym | (hsym; symbol; symbol)} The table reference.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
// tabRef:(`:/tmp/qtk/tbl/drop; `date; `PartitionedTable);
// .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];
//
// // Or replace tabRef with PartitionedTable if the database is loaded
// tabRef~.qtk.tbl.drop tabRef
.qtk.tbl.drop:{[tabRef]
  tabRefDesc:.qtk.tbl._desc tabRef;
  tableType:tabRefDesc`type;
  tableName:tabRefDesc`name;

  $[tableType=`Plain;
    ![`.; (); 0b; enlist tableName];
    tableType=`Serialized;
    .qtk.os.remove tabRef;
    tableType=`Splayed;
    [
      dbDir:tabRefDesc`dbDir;
      if[dbDir=`:.; ![`.; (); 0b; enlist tableName]];
      tablePath:.Q.dd[dbDir; tableName];
      .qtk.os.rmtree tablePath;
      ];
    // tableType=`Partitioned
    [
      dbDir:tabRefDesc`dbDir;
      if[dbDir=`:.; ![`.; (); 0b; enlist tableName]];
      tablePaths:.Q.par[dbDir; ; tableName] each .qtk.db.getPartitions dbDir;
      .qtk.os.rmtree each tablePaths;
      ]
   ];

  tabRef
 };

// @kind function
// @private
// @subcategory tbl
// @overview Describe a table reference.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference. It's a symbol for plain table,
// hsym for serialized and splayed table, or 3-element list composed of DB directory, partition field, and table name
// @return {dict (type:symbol; name:symbol; dbDir:symbol; parField:symbol)} A dictionary describing the table reference.
// @throws {TypeError} If `tabRef` is not of valid type.
.qtk.tbl._desc:{[tabRef]
  if[11h<>abs type tabRef; '.qtk.err.compose[`TypeError; "expect symbol or symbol vector"]];
  tableType:.qtk.tbl.getType tabRef;

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
         parField:.qtk.db.getPartitionField dbDir;
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
// @subcategory tbl
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
// @private
// @subcategory tbl
// @overview Insert data into a table.
// @param tablePath {hsym} Path to an on-disk table.
// @param data {table} Table data.
// @return {hsym} `tablePath` itself.
.qtk.tbl._insert:{[tablePath;data]
  tablePath upsert data
 };

// @kind function
// @subcategory tbl
// @overview Update values in certain columns of a table, in a similar format to functional update.
// @param table {symbol | table} Table name or value.
// @param criteria {any[]} A list of criteria where the update is applied to, or empty list if it's applied to the whole table.
// @param assignment {dict} A mapping from column names to values of parse-tree form
// @return {symbol} The table name.
// @throws {ColumnNotFoundError: [*]} If a column doesn't exist.
.qtk.tbl.update:{[tableName;criteria;assignment]
  .qtk.tbl._validateColumnExists[tableName;] each key assignment;

  tableType:.qtk.tbl.getType tableName;
  $[tableType=`Plain;
    ![tableName; criteria; 0b; assignment];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.tbl._update[tablePath; criteria; assignment];
      ];
    // tableType=`Partitioned
    [
      partitionField:.qtk.db.getCurrentPartitionField[];
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
// @param criteria {any[]} A list of criteria where the update is applied to, or empty list if it's applied to the whole table.
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
       .qtk.tbl._addColumn[tablePath; column; columnVal]
      ];
     i +: 1;
   ];
  tablePath
 };

// @kind function
// @subcategory tbl
// @overview Select from a table based on given criteria, groupings, and column mappings, in a similar format to functional select.
// @param table {symbol | table} Table name or value.
// @param criteria {any[]} A list of criteria where the select is applied to, or empty list for the whole table.
// @param groupings {*} A mapping of grouping columns, or `0b` for no grouping, `1b` for distinct.
// @param assignment {dict} A mapping from column names to values of parse-tree form.
// @return {table} Selected data from the table.
.qtk.tbl.select:{[tableName;criteria;groupings;assignment]
  ?[tableName; criteria; groupings; assignment]
 };

// @kind function
// @subcategory tbl
// @overview Similar to `.qtk.tbl.select` but with a limit on rows.
// @param tableName {symbol | table} Table name or value.
// @param criteria {any[]} A list of criteria where the select is applied to, or empty list for the whole table.
// @param groupings {*} A mapping of grouping columns, or `0b` for no grouping, `1b` for distinct.
// @param assignment {dict} A mapping from column names to values of parse-tree form.
// @param limit {int | long | (int;int) | (long;long)} Limit on rows to return.
// @return {table} Selected data from the table.
.qtk.tbl.selectLimit:{[tableName;criteria;groupings;assignment;limit]
  select[limit] from ?[tableName; criteria; groupings; assignment]
 };

// @kind function
// @subcategory tbl
// @overview Similar to `.qtk.tbl.selectLimit` but with sorting.
// @param tableName {symbol | table} Table name or value.
// @param criteria {any[]} A list of criteria where the select is applied to, or empty list for the whole table.
// @param groupings {*} A mapping of grouping columns, or `0b` for no grouping, `1b` for distinct.
// @param assignment {dict} A mapping from column names to values of parse-tree form.
// @param limit {int | long | (int;int) | (long;long)} Limit on rows to return.
// @param sort {any[]} Sort the result by a column. The format is `(op;col)` where `op` is `>:` for descending and
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
// @subcategory tbl
// @overview Delete rows of a table given certain criteria.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference.
// @param criteria {any[]} A list of criteria where matching rows will be deleted, or empty list to delete all rows.
// For partitioned tables, if partition field is included in the criteria, it has to be the first in the list.
// @return {tabRef} The table reference.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
// tabRef:(`:/tmp/qtk/tbl/deleteRows; `date; `PartitionedTable);
// .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02 2022.01.02; c1:1 2 3)];
//
// // Or replace tabRef with PartitionedTable if the database is loaded
// tabRef~.qtk.tbl.deleteRows[tabRef; enlist(=;`c1;3)]
.qtk.tbl.deleteRows:{[tabRef;criteria]
  tabRefDesc:.qtk.tbl._desc tabRef;
  tableType:tabRefDesc`type;
  tableName:tabRefDesc`name;

  $[tableType=`Plain;
    ![tabRef; criteria; 0b; `$()];
    tableType=`Serialized;
    tabRef set ![get tabRef; criteria; 0b; `$()];
    tableType=`Splayed;
    [
      dbDir:tabRefDesc`dbDir;
      tablePath:.Q.dd[dbDir; tableName];
      .qtk.tbl._deleteRows[tablePath; criteria];
      ];
    // tableType=`Partitioned
    [
      dbDir:tabRefDesc`dbDir;
      partitions:.qtk.db.getPartitions dbDir;
      parField:.qtk.db.getPartitionField dbDir;

      if[(first criteria)[1]~parField;
         partitions:?[flip enlist[parField]!enlist[partitions]; enlist first criteria; (); parField];
         criteria:1_criteria
       ];

      tablePaths:.Q.par[dbDir; ; tableName] each partitions;
      .qtk.tbl._deleteRows[; criteria] each tablePaths;
      ]
   ];
  tabRef
 };

// @kind function
// @private
// @overview Delete rows of an on-disk table given certain criteria, in a similar format to functional delete.
// @param tablePath {hsym} Path to an on-disk table.
// @param criteria {any[]} A list of criteria where matching rows will be deleted, or empty list if it's applied to the whole table.
// @return {hsym} The path to the table.
.qtk.tbl._deleteRows:{[tablePath;criteria]
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
// @subcategory tbl
// @overview Check if a column exists in a table.
// For splayed tables, column existence requires that the column appears in `.d` file and its data file exists.
// For partitioned tables, it requires the condition holds for all partitions.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference.
// @param column {symbol} Column name.
// @return {boolean} `1b` if the column exists in the table; `0b` otherwise.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
// tabRef:(`:/tmp/qtk/tbl/columnExists; `date; `PartitionedTable);
// .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];
//
// // Or replace tabRef with PartitionedTable if the database is loaded
// .qtk.tbl.columnExists[tabRef;`c1]
.qtk.tbl.columnExists:{[tabRef;column]
  tabRefDesc:.qtk.tbl._desc tabRef;
  tableType:tabRefDesc`type;
  tableName:tabRefDesc`name;

  $[tableType=`Plain;
    column in cols tabRef;
    tableType=`Serialized;
    column in cols get tabRef;
    tableType=`Splayed;
    [
      dbDir:tabRefDesc`dbDir;
      tablePath:.Q.dd[dbDir; tableName];
      .qtk.tbl._columnExists[tablePath; column]
      ];
    // tableType=`Partitioned
    [
      dbDir:tabRefDesc`dbDir;
      tablePaths:.Q.par[dbDir; ; tableName] each .qtk.db.getPartitions dbDir;
      // Can make the following part simpler by `all .qtk.tbl._columnExists[...]` at the cost of performance, due to inability
      // to return early
      partitionCount:count tablePaths;
      i:0;
      while[i<partitionCount;
            if[not .qtk.tbl._columnExists[tablePaths[i]; column]; :0b];
            i+:1
       ];
      1b
      ]
   ]
 };

// @kind function
// @private
// @overview Check if a column exists in an on-disk table. A column exists if it's listed in .d file and
// there is a file of the same name in the table path.
// @param tablePath {hsym} Path to an on-disk table.
// @param column {symbol} A column name.
// @return {boolean} `1b` if the column exists in the table; `0b` otherwise.
.qtk.tbl._columnExists:{[tablePath;column]
  allColumns:.qtk.db._getColumns tablePath;
  if[not column in allColumns; :0b];
  columnPath:.Q.dd[tablePath; column];
  .qtk.os.path.isFile columnPath
 };

// @kind function
// @subcategory tbl
// @overview Add a column to a table with a given value.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference.
// @param column {symbol} Name of new column to be added.
// @param columnValue {any} Value to be set on the new column.
// @return {symbol | hsym | (hsym; symbol; symbol)} The table reference.
// @throws {NameError} If `column` is not a valid name.
// @throws {ColumnExistsError} If `column` already exists.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
// tabRef:(`:/tmp/qtk/tbl/addColumn; `date; `PartitionedTable);
// .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];
//
// // Or replace tabRef with PartitionedTable if the database is loaded
// tabRef~.qtk.tbl.addColumn[tabRef; `c2; 0n]
.qtk.tbl.addColumn:{[tabRef;column;columnValue]
  .qtk.tbl._validateColumnName column;
  .qtk.tbl._validateColumnNotExists[tabRef; column];

  tabRefDesc:.qtk.tbl._desc tabRef;
  tableType:tabRefDesc`type;
  tableName:tabRefDesc`name;
  $[tableType=`Plain;
    [
      if[-11h=type columnValue; columnValue:enlist columnValue];                         // enlist singleton symbol value
      ![tabRef; (); 0b; enlist[column]!enlist[columnValue]];
      ];
    tableType=`Serialized;
    [
      if[-11h=type columnValue; columnValue:enlist columnValue];                         // enlist singleton symbol value
      tabRef set ![get tabRef; (); 0b; enlist[column]!enlist[columnValue]];
      ];
    tableType=`Splayed;
    [
      dbDir:tabRefDesc`dbDir;
      tablePath:.Q.dd[dbDir; tableName];
      .qtk.tbl._addColumn[tablePath; column; .qtk.db._enumerateAgainst[dbDir;`sym;columnValue]];
      ];
    // tableType=`Partitioned
    [
      dbDir:tabRefDesc`dbDir;
      tablePaths:.Q.par[dbDir; ; tableName] each .qtk.db.getPartitions dbDir;
      .qtk.tbl._addColumn[; column; .qtk.db._enumerateAgainst[dbDir;`sym;columnValue] ] each tablePaths;
      ]
   ];

  tabRef
 };

// @kind function
// @private
// @overview Add a column to a table specified by a path, using a default value unless
// a length- and type-compliant column data file exists.
// @param tablePath {hsym} Path to an on-disk table.
// @param column {symbol} Name of new column to be added.
// @param defaultValue {*} Value to be set on the new column.
// @return {hsym} The path to the table.
.qtk.tbl._addColumn:{[tablePath;column;defaultValue]
  allColumns:.qtk.db._getColumns tablePath;
  countInPath:count get .Q.dd[tablePath; first allColumns];
  columnPath:.Q.dd[tablePath; column];

  // if the column file exists and it's type- and length-compliant, use it as-is;
  // otherwise create the file using defaultValue
  $[.qtk.os.path.isFile columnPath;
    if[not (count[tablePath column]=countInPath) and (type[defaultValue]=type[.qtk.db._defaultValue[tablePath; column]]);
       .[.Q.dd[tablePath; column]; (); :; countInPath#defaultValue]
     ];
    .[.Q.dd[tablePath; column]; (); :; countInPath#defaultValue]
   ];
  @[tablePath; `.d; :; distinct allColumns,column];

  tablePath
 };

// @kind function
// @subcategory tbl
// @overview Delete a column from a table.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference.
// @param column {symbol} A column to be deleted.
// @return {symbol | hsym | (hsym; symbol; symbol)} The table reference.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
// tabRef:(`:/tmp/qtk/tbl/deleteColumn; `date; `PartitionedTable);
// .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2; c2:`a`b)];
//
// // Or replace tabRef with PartitionedTable if the database is loaded
// tabRef~.qtk.tbl.deleteColumn[tabRef; `c2]
.qtk.tbl.deleteColumn:{[tabRef;column]
  tabRefDesc:.qtk.tbl._desc tabRef;
  tableType:tabRefDesc`type;
  tableName:tabRefDesc`name;

  $[tableType=`Plain;
    ![tabRef; (); 0b; enlist[column]];
    tableType=`Serialized;
    tabRef set ![get tabRef; (); 0b; enlist[column]];
    tableType=`Splayed;
    [
      dbDir:tabRefDesc`dbDir;
      tablePath:.Q.dd[dbDir; tableName];
      .qtk.tbl._deleteColumn[tablePath; column];
      ];
    // tableType=`Partitioned
    [
      dbDir:tabRefDesc`dbDir;
      tablePaths:.Q.par[dbDir; ; tableName] each .qtk.db.getPartitions dbDir;
      .qtk.tbl._deleteColumn[; column] each tablePaths;
      ]
   ];

  tabRef
 };

// @kind function
// @private
// @overview Delete a column of an on-disk table and its data.
// @param tablePath {hsym} Path to an on-disk table.
// @param column {symbol} A column to be deleted.
// @return {hsym} The path to the table.
.qtk.tbl._deleteColumn:{[tablePath;column]
  columnPath:.Q.dd[tablePath; column];
  .qtk.tbl._deleteColumnData columnPath;
  .qtk.tbl._deleteColumnHeader[tablePath; column];
  tablePath
 };

// @kind function
// @private
// @overview Delete a column header of an on-disk table.
// @param tablePath {hsym} Path to an on-disk table.
// @param column {symbol} A column to be deleted.
// @return {hsym} The path to the table.
.qtk.tbl._deleteColumnHeader:{[tablePath;column]
  allColumns:.qtk.db._getColumns tablePath;
  @[tablePath; `.d; :; allColumns except column];
  tablePath
 };

// @kind function
// @private
// @overview Delete a column on disk.
// @param columnPath {symbol} A file symbol representing an existing column.
.qtk.tbl._deleteColumnData:{[columnPath]
  if[.qtk.os.path.isFile columnPath;
     .qtk.os.remove columnPath
   ];
  if[.qtk.os.path.isFile dataFile:`$string[columnPath],"#";
     .qtk.os.remove dataFile
   ];
  if[.qtk.os.path.isFile dataFile:`$string[columnPath],"##";
     .qtk.os.remove dataFile
   ];
 };

// @kind function
// @subcategory tbl
// @overview Rename column(s) from a table.
// @param tableName {symbol} Table name.
// @param nameDict {dict} A dictionary from existing name(s) to new name(s).
// @return {symbol} The table name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
// @throws {ColumnNotFoundError: [*]} If some column in `nameDict` doesn't exist.
.qtk.tbl.renameColumns:{[tableName;nameDict]
  .qtk.tbl._validateColumnName each value nameDict;
  .qtk.tbl._validateColumnExists[tableName;] each key nameDict;

  tableType:.qtk.tbl.getType tableName;
  $[tableType in `Plain`Serialized;
    tableName set nameDict xcol get tableName;
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.tbl._renameColumns[tablePath; nameDict];
      ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getCurrentPartitions[];
      .qtk.tbl._renameColumns[; nameDict] each tablePaths;
      ]
   ];
  tableName
 };

// @kind function
// @private
// @overview Rename column(s) of an on-disk table.
// @param tablePath {hsym} Path to an on-disk table.
// @param nameDict {dict} A dictionary from old name(s) to new name(s).
// @return {hsym} The path to the table.
.qtk.tbl._renameColumns:{[tablePath;nameDict]
  renameOneColumn:.qtk.tbl._renameOneColumn[tablePath; ;];
  renameOneColumn'[key nameDict; value nameDict];
  tablePath
 };

// @kind function
// @private
// @overview Rename a column of an on-disk table.
// @param tablePath {hsym} Path to an on-disk table.
// @param oldName {symbol} A column name of the table.
// @param newName {symbol} New column name.
// @return {hsym} The path to the table.
.qtk.tbl._renameOneColumn:{[tablePath;oldName;newName]
  allColumns:.qtk.db._getColumns tablePath;

  if[(not oldName in allColumns) or (newName in allColumns); :tablePath];

  oldColumnPath:.Q.dd[tablePath; oldName];
  newColumnPath:.Q.dd[tablePath; newName];
  .qtk.db._renameColumnOnDisk[oldColumnPath; newColumnPath];

  newColumns:@[allColumns; first where allColumns=oldName; :; newName];
  @[tablePath; `.d; :; newColumns];
  tablePath
 };

// @kind function
// @private
// @overview Rename a column on disk.
// @param oldColumnPath {symbol} A file symbol representing an existing column.
// @param newColumnPath {symbol} A file symbol representing a new column.
.qtk.db._renameColumnOnDisk:{[oldColumnPath;newColumnPath]
  .qtk.os.move[oldColumnPath; newColumnPath];
  if[.qtk.os.path.isFile dataFile:`$string[oldColumnPath],"#";
     .qtk.os.move[dataFile; `$string[newColumnPath],"#"]
   ];
  if[.qtk.os.path.isFile dataFile:`$string[oldColumnPath],"##";
     .qtk.os.move[dataFile; `$string[newColumnPath],"##"]
   ];
 };

// @kind function
// @subcategory tbl
// @overview Reorder columns of a table.
// @param tableName {symbol} Table name.
// @param firstColumns {symbol[]} First columns after reordering.
// @return {symbol} The table name.
// @throws {ColumnNotFoundError: [*]} If some column in `firstColumns` doesn't exist.
.qtk.tbl.reorderColumns:{[tableName;firstColumns]
  .qtk.tbl._validateColumnExists[tableName;] each firstColumns;

  tableType:.qtk.tbl.getType tableName;
  $[tableType in `Plain`Serialized;
    tableName set firstColumns xcols get tableName;
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.tbl._reorderColumns[tablePath; firstColumns];
      ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getCurrentPartitions[];
      .qtk.tbl._reorderColumns[; firstColumns] each tablePaths;
      ]
   ];
  tableName
 };

// @kind function
// @private
// @overview Reorder columns of an on-disk table with specified first columns.
// @param tablePath {hsym} Path to an on-disk table.
// @param firstColumns {dict} First columns after reordering.
// @return {hsym} The path to the table.
.qtk.tbl._reorderColumns:{[tablePath;firstColumns]
  allColumns:.qtk.db._getColumns tablePath;
  @[tablePath; `.d; :; firstColumns,allColumns except firstColumns];
  tablePath
 };

// @kind function
// @subcategory tbl
// @overview Copy an existing column of a table to a new column.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference.
// @param sourceColumn {symbol} Source column to copy from.
// @param targetColumn {symbol} Target column to copy to.
// @return {symbol | hsym | (hsym; symbol; symbol)} The table reference.
// @throws {ColumnNotFoundError} If `sourceColumn` doesn't exist.
// @throws {ColumnExistsError} If `targetColumn` exists.
// @throws {NameError} If name of `targetColumn` is not valid.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
// tabRef:(`:/tmp/qtk/tbl/copyColumn; `date; `PartitionedTable);
// .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];
//
// // Or replace tabRef with PartitionedTable if the database is loaded
// .qtk.tbl.copyColumn[tabRef; `c1; `c2];
// .qtk.tbl.columnExists[tabRef; `c2]
.qtk.tbl.copyColumn:{[tabRef;sourceColumn;targetColumn]
  .qtk.tbl._validateColumnExists[tabRef; sourceColumn];
  .qtk.tbl._validateColumnNotExists[tabRef; targetColumn];
  .qtk.tbl._validateColumnName targetColumn;

  tabRefDesc:.qtk.tbl._desc tabRef;
  tableType:tabRefDesc`type;
  tableName:tabRefDesc`name;
  $[tableType=`Plain;
    ![tabRef; (); 0b; enlist[targetColumn]!enlist[sourceColumn]];
    tableType=`Serialized;
    tabRef set ![get tabRef; (); 0b; enlist[targetColumn]!enlist[sourceColumn]];
    tableType=`Splayed;
    [
      dbDir:tabRefDesc`dbDir;
      tablePath:.Q.dd[dbDir; tableName];
      .qtk.tbl._copyColumn[tablePath; sourceColumn; targetColumn];
      ];
    // tableType=`Partitioned
    [
      dbDir:tabRefDesc`dbDir;
      tablePaths:.Q.par[dbDir; ; tableName] each .qtk.db.getPartitions dbDir;
      .qtk.tbl._copyColumn[; sourceColumn; targetColumn] each tablePaths;
      ]
   ];

  tabRef
 };

// @kind function
// @private
// @overview Copy an existing column of an on-disk table to a new column.
// @param tablePath {hsym} Path to an on-disk table.
// @param sourceColumn {symbol} Source column.
// @param targetColumn {symbol} Target column.
// @return {hsym} The path to the table.
.qtk.tbl._copyColumn:{[tablePath;sourceColumn;targetColumn]
  sourceColumnPath:.Q.dd[tablePath; sourceColumn];
  targetColumnPath:.Q.dd[tablePath; targetColumn];
  .qtk.tbl._copyColumnOnDisk[sourceColumnPath; targetColumnPath];
  @[tablePath; `.d; ,; targetColumn];
  tablePath
 };

// @kind function
// @private
// @overview Copy a column on disk.
// @param oldColumnPath {symbol} A file symbol representing an existing column.
// @param newColumnPath {symbol} A file symbol representing a new column.
.qtk.tbl._copyColumnOnDisk:{[oldColumnPath;newColumnPath]
  .qtk.os.copy[oldColumnPath; newColumnPath];
  if[.qtk.os.path.isFile dataFile:`$string[oldColumnPath],"#";
     .qtk.os.copy[dataFile; `$string[newColumnPath],"#"]
   ];
  if[.qtk.os.path.isFile dataFile:`$string[oldColumnPath],"##";
     .qtk.os.copy[dataFile; `$string[newColumnPath],"##"]
   ];
 };

// @kind function
// @subcategory tbl
// @overview Apply a function to a column of a table.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference.
// @param column {symbol} Column where the function will be applied.
// @param function {fn(any[]) -> any[]} Function to be applied.
// @return {symbol | hsym | (hsym; symbol; symbol)} The table reference.
// @throws {ColumnNotFoundError} If `column` doesn't exist.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
// tabRef:(`:/tmp/qtk/tbl/apply; `date; `PartitionedTable);
// .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];
//
// // Or replace tabRef with PartitionedTable if the database is loaded
// tabRef~.qtk.tbl.apply[tabRef; `c1; 2*]
.qtk.tbl.apply:{[tabRef;column;function]
  .qtk.tbl._validateColumnExists[tabRef; column];

  tabRefDesc:.qtk.tbl._desc tabRef;
  tableType:tabRefDesc`type;
  tableName:tabRefDesc`name;
  $[tableType=`Plain;
    ![tabRef; (); 0b; enlist[column]!enlist[(function;column)]];
    tableType=`Serialized;
    tabRef set ![get tabRef; (); 0b; enlist[column]!enlist[(function;column)]];
    tableType=`Splayed;
    [
      dbDir:tabRefDesc`dbDir;
      tablePath:.Q.dd[dbDir; tableName];
      .qtk.tbl._apply[dbDir; tablePath; column; function];
      ];
    // tableType=`Partitioned
    [
      dbDir:tabRefDesc`dbDir;
      tablePaths:.Q.par[dbDir; ; tableName] each .qtk.db.getPartitions dbDir;
      .qtk.tbl._apply[dbDir; ; column; function] each tablePaths;
      ]
   ];

  tabRef
 };

// @kind function
// @private
// @overview Apply a function to a column of an on-disk table.
// @param tablePath {hsym} Path to an on-disk table.
// @param column {symbol} A column name of the table.
// @param function {function} Function to be applied to the column.
// @return {hsym} The path to the table.
.qtk.tbl._apply:{[dbDir;tablePath;column;function]
  columnPath:.Q.dd[tablePath; column];
  oldValue:get columnPath;
  oldAttr:attr oldValue;
  newValue:function oldValue;
  newAttr:attr newValue;
  if[(not oldValue~newValue) or (not oldAttr~newAttr);
     .[columnPath; (); :; .qtk.db._enumerateAgainst[dbDir;`sym;newValue]]
   ];
  tablePath
 };

// @kind function
// @subcategory tbl
// @overview Cast the datatype of a column of a table.
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference.
// @param column {symbol} Column whose datatype will be casted.
// @param newType {symbol | char} Name or character code of the new data type.
// @return {symbol | hsym | (hsym; symbol; symbol)} The table reference.
// @throws {ColumnNotFoundError} If `column` doesn't exist.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
// tabRef:(`:/tmp/qtk/tbl/castColumn; `date; `PartitionedTable);
// .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];
//
// // Or replace tabRef with PartitionedTable if the database is loaded
// tabRef~.qtk.tbl.castColumn[tabRef; `c1; `int]
.qtk.tbl.castColumn:{[tabRef;column;newType]
  .qtk.tbl.apply[tabRef; column; newType$]
 };

// @kind function
// @subcategory tbl
// @overview Set an attribute to a column. See also [Set Attribute](https://code.kx.com/q/ref/set-attribute/).
// @param tableName {symbol} Table name.
// @param column {symbol} A column name of the table.
// @param attribute {symbol} Attribute to be added to the column.
// @return {symbol} The table name.
// @throws {ColumnNotFoundError} If `column` doesn't exist.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
// `t set ([]c1:til 2);
//
// .qtk.tbl.setAttr[`t;`c1;`s];
// `s=meta[t][`c1;`a]
.qtk.tbl.setAttr:{[tableName;column;attribute]
  .qtk.tbl.apply[tableName; column; attribute#]
 };

// @kind function
// @subcategory tbl
// @overview Remove attribute from a column.
// @param tableName {symbol} Table name.
// @param column {symbol} A column name of the table.
// @return {symbol} The table name.
// @throws {ColumnNotFoundError: [*]} where If `column` doesn't exist.
.qtk.tbl.removeAttr:{[tableName;column]
  .qtk.tbl.apply[tableName; column; `#]
 };

// @kind function
// @private
// @overview Validate column name.
// @param columnName {symbol} A column name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
.qtk.tbl._validateColumnName:{[columnName]
  if[(columnName in `i,.Q.res,key `.q) or columnName<>.Q.id columnName;
     '.qtk.err.compose[`NameError; "invalid column name [",string[columnName],"]"]
   ];
 };

// @kind function
// @private
// @overview Validate that a column exists, including header and data.
// @param tableName {symbol} Table name.
// @param column {symbol} A column name.
// @throws {ColumnNotFoundError: [*]} If the column doesn't exist.
.qtk.tbl._validateColumnExists:{[tableName;column]
  if[not .qtk.tbl.columnExists[tableName; column];
     '.qtk.err.compose[`ColumnNotFoundError; "[",string[column],"]"]
   ];
 };

// @kind function
// @private
// @overview Validate that a column doesn't exist, either header or data or neither.
// @param tableName {symbol} Table name.
// @param column {symbol} A column name.
// @throws {ColumnExistsError: [*]} If the column exists.
.qtk.tbl._validateColumnNotExists:{[tableName;column]
  if[.qtk.tbl.columnExists[tableName; column];
     '.qtk.err.compose[`ColumnExistsError; "[",string[column],"]"]
   ];
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
// @param tabRef {symbol | hsym | (hsym; symbol; symbol)} Table reference.
// @return {boolean} `1b` if the table exists; `0b` otherwise.
.qtk.tbl.exists:{[tabRef]
  tabRefDesc:.qtk.tbl._desc tabRef;
  tableType:tabRefDesc`type;
  tableName:tabRefDesc`name;

  $[tableType=`Plain;
    $[.qtk.utils.nameExists tabRef; .qtk.type.isTable tabRef; 0b];
    tableType=`Serialized;
    .qtk.os.path.isFile tabRef;
    tableType=`Splayed;
    [
      dbDir:tabRefDesc`dbDir;
      tablePath:.Q.dd[dbDir; tableName];
      .qtk.os.path.isDir tablePath
      ];
    // tableType=`Partitioned
    [
      dbDir:tabRefDesc`dbDir;
      tablePaths:.Q.par[dbDir; ; tableName] each (first;last) @\: .qtk.db.getPartitions dbDir;
      any .qtk.os.path.isDir each tablePaths
      ]
   ]
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
// @subcategory tbl
// @overview Rename a table.
// @param tableName {symbol} Table name.
// @param newName {symbol} New name of the table.
// @return {symbol} New table name.
.qtk.tbl.rename:{[tableName;newName]
  tableType:.qtk.tbl.getType tableName;
  $[tableType=`Plain;
    [
      newName set get tableName;
      ![`.; (); 0b; enlist tableName];
      ];
    tableType=`Serialized;
    .qtk.os.move[tableName; newName];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.tbl._rename[tablePath; newName];
      ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getCurrentPartitions[];
      .qtk.tbl._rename[; newName] each tablePaths;
      ]
   ];
  newName
 };

// @kind function
// @private
// @overview Rename an on-disk table.
// @param tablePath {hsym} Path to an on-disk table.
// @param newName {hsym} New table name.
// @return {hsym} Path to the renamed table in the partition.
.qtk.tbl._rename:{[tablePath;newName]
  newTablePath:.Q.dd[first[` vs tablePath]; newName];
  .qtk.os.move[tablePath; newTablePath];
  newTablePath
 };
