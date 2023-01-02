
// @kind function
// @subcategory db
// @overview Get all partitions of a database.
// @param dbDir {hsym} DB directory.
// @return {date[] | month[] | int[] | ()} Partitions of the database, or an empty list
// if the database is not a partitioned database.
// @throws {FileNotFoundError} If `dbDir` doesn't exist.
// @throws {NotADirectoryError} If `dbDir` doesn't point to a directory.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["db";`qtk];
// .qtk.import.loadModule["tbl";`qtk];
// tabRef:`:/tmp/qtk/db/getPartitions`date`PartitionedTable;
// .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];
//
// 2022.01.01 2022.01.02~.qtk.db.getPartitions first tabRef
.qtk.db.getPartitions:{[dbDir]
  items:.qtk.os.listDir dbDir;
  partitionDirectories:$[`par.txt in items;
                         raze .qtk.db._getPartitionDirectories each .qtk.db._getSegmentPaths[dbDir];
                         .qtk.db._getPartitionDirectories dbDir];
  if[0=count partitionDirectories; :()];
  getPartitionDatatype:{"DMII" 10 7 4?count x};
  partitionDatatype:getPartitionDatatype first partitionDirectories;
  partitionDatatype$partitionDirectories
 };

// @kind function
// @private
// @subcategory db
// @overview Get segment paths of a segmented database.
// @param dbDir {hsym} DB directory.
// @return {hsym[]} Segment paths of the database, or an empty symbol list
// if the database is not a segmented database.
// @throws {FileNotFoundError} If the directory doesn't exist.
// @throws {NotADirectoryError} If the input argument is not a directory.
.qtk.db._getSegmentPaths:{[dbDir]
  items:.qtk.os.listDir dbDir;
  segmentPaths:$[`par.txt in items;
                 hsym each `$read0 .Q.dd[dbDir; `par.txt];
                 `$()
   ];
  segmentPaths
 };

// @kind function
// @private
// @subcategory db
// @overview Get all partition directories of a partitioned database.
// @param dbDir {hsym} DB directory of the partitioned database.
// @return {string[]} Partition directories, or an empty general list if the database is not a partitioned database.
// @throws {FileNotFoundError} If the directory doesn't exist.
// @throws {NotADirectoryError} If the input argument is not a directory.
.qtk.db._getPartitionDirectories:{[dbDir]
  items:.qtk.os.listDir dbDir;
  items:items where items like "[0-9]*";
  string items
 };

// @kind function
// @subcategory db
// @overview Get partition field of a database under a directory.
// @param dbDir {hsym} A database directory.
// @return {symbol} Partition field of the database, either of ``#!q `date`month`year`int ``, or an empty symbol
// if the database is not a partitioned database.
// @see .qtk.db.this.getPartitionField
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["db";`qtk];
// .qtk.import.loadModule["tbl";`qtk];
// tabRef:`:/tmp/qtk/db/getPartitionField`date`PartitionedTable;
// .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];
//
// tabRef[1]~.qtk.db.getPartitionField first tabRef
.qtk.db.getPartitionField:{[dbDir]
  partitions:.qtk.db.getPartitions dbDir;
  $[14h=t:type partitions; `date;
    13h=t; `month;
    0h=t; `;
    all partitions within\: 1000 9999; `year;
    `int]
 };

// @kind function
// @subcategory db
// @overview Row count of a table per partition.
// @param tableName {symbol} A partitioned table by name.
// @return {dict} A dictionary from partitions to row count of the table in each partition.
// @throws {NotAPartitionedTableError} If the table is not a partitioned table.
.qtk.db.rowCountPerPartition:{[tableName]
  rowCounts:
    @[.Q.cn get@;
      tableName;
      {[msg;tableName]
        '.qtk.err.compose[`NotAPartitionedTableError; string[tableName]]
      }[; tableName]
     ];
  .qtk.db.this.getModifiedPartitions[]!rowCounts
 };

// @kind function
// @subcategory db
// @overview Row count of each partitioned table per partition.
// @return {dict} A table keyed by partition and each column is row count of a partitioned table in each partition.
// @throws {RuntimeError: no partition} If there is no partition.
.qtk.db.rowCountPerTablePerPartition:{
  partitionedTables:.qtk.db.this.getPartitionedTables[];
  .qtk.db.rowCountPerPartition each partitionedTables;
  rowCountsByTable:
    @[value; `.Q.pn;
      {'.qtk.err.compose[`RuntimeError; "no partition"]}
     ];
  rowCountsByTable[`partition]:.qtk.db.this.getModifiedPartitions[];
  `partition xkey flip rowCountsByTable
 };

.qtk.db.loadSym:{[dbDir;sym]
  symFile:.Q.dd[dbDir;sym];
  if[not .qtk.os.path.isFile symFile; :`];
  if[sym in system enlist"v"; .qtk.db[sym]:get sym];
  load .Q.dd[dbDir;sym];
  sym
 };

.qtk.db.recoverSym:{[sym]
  oldSym:.qtk.db[sym];
  if[11h<>type oldSym; :`];
  sym set oldSym;
  delete sym from `.qtk.db;
  sym
 };

// @kind function
// @subcategory db
// @overview Fill all tables missing in some partitions, using the most recent partition as a template.
// A rename of [`.Q.chk`](https://code.kx.com/q/ref/dotq/#qchk-fill-hdb).
// @param dbDir {hsym} Database directory.
// @return {any[]} Partitions that are filled with missing tables.
.qtk.db.fillTables:{[dbDir]
  .Q.chk dbDir
 };

// @kind function
// @subcategory db
// @overview Save table to a partition.
// See [`.Q.dpft`](https://code.kx.com/q/ref/dotq/#qdpft-save-table).
// @param dir {hsym} A directory handle.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} Table name.
// @param tableData {table} A table of data.
// @param options {dict (enum: dict | symbol)} Saving options.
//   - enum: a single domain for all symbol columns, or a dictionary between column names and their respective domains where the default domain is sym
// @return {hsym} The path to the table in the partition.
// @throws {SchemaError: mismatch between actual columns [*] and expected ones [*]} If column names in the data table
//   don't match those in the on-disk table (if exists).
// @throws {SchemaError: mismatch between actual types [*] and expected ones [*]} If column types in the data table
//   don't match those in the on-disk table (if exists).
.qtk.db.saveTableToPartition:{[dir;partition;tableName;tableData;options]
  tablePath:.Q.par[dir; partition; tableName];

  .qtk.db._validateSchema[tablePath; tableData];

  // enumerate symbol columns
  enumDomain:$[`enum in key options; options`enum; ()!()];
  if[-11h=type enumDomain;
     enumDomain:(enlist `)!(enlist enumDomain)
   ];
  if[not ` in key enumDomain; enumDomain[`]:`sym];  // value to null symbol key denotes default domain

  symbolCols:where 11h=type each flip tableData;
  enumFunc:.qtk.db._enumerateAgainst[dir; ;];
  enumeratedData:@[tableData; symbolCols; :; enumFunc'[(enumDomain`)^enumDomain symbolCols; tableData symbolCols]];

  .qtk.db._saveTable[tablePath; enumeratedData];
  tablePath
 };

// @kind function
// @subcategory db
// @overview Load database in a given directory.
// @param dir {string | hsym} Directory.
// @see .qtk.db.reload
.qtk.db.load:{[dir]
  dirStr:$[10h=type dir; dir; 1_string dir];
  system "l ",dirStr;
 };

// @kind function
// @subcategory db
// @overview Reload current database.
// @see .qtk.db.load
.qtk.db.reload:{
  .qtk.db.load enlist".";
 };

/////////////////////////////////////////////
// private functions
/////////////////////////////////////////////

// @kind function
// @private
// @overview Validate a table conforms to the schema of an on-disk table.
// @param tablePath {hsym} Path to an on-disk table.
// @param data {table} A table of data.
// @throws {SchemaError: mismatch between actual columns [*] and expected ones [*]} If columns in the data table don't match
//   those in the on-disk table (if exists).
// @throws {SchemaError: mismatch between actual types [*] and expected ones [*]} If data types of the columns
//   in the data table don't match those in the on-disk table (if exists).
.qtk.db._validateSchema:{[tablePath;data]
  if[not .qtk.os.path.exists tablePath; :(::)];
  if[not .qtk.db._dotDExists tablePath; :(::)];

  expectedCols:.qtk.db._getColumns tablePath;
  actualCols:cols data;
  if[not expectedCols~actualCols;
     '.qtk.err.compose[`SchemaError; "mismatch between actual columns [",.Q.s1[actualCols],"] and expected ones [",.Q.s1[expectedCols],"]"]
   ];

  if[not all .qtk.db._isTypeCompliant'[tablePath expectedCols; data actualCols];
     '.qtk.err.compose[`SchemaError;
                   "mismatch between actual types [",(.Q.ty each data actualCols),"] and expected ones [",
                   (.Q.ty each tablePath expectedCols),"]"
       ]
   ];
 };

// @kind function
// @private
// @overview Check if a list is type-compliant to a target list. A list is type-compliant to another list when
//   - their types as returned by `.Q.ty` are the same
//   - target list is not a vector nor a compound list
//   - target list is a compound list, and actual list is a generic empty list
// @param target {any[]} Target list.
// @param actual {any[]} Actual list.
// @return `1b` if the actual list is type-compliant to the target list; `0b` otherwise.
.qtk.db._isTypeCompliant:{[target;actual]
  targetType:.Q.ty target;
  actualType:.Q.ty actual;
  if[(targetType=" ") or targetType=actualType; :1b];
  if[(targetType in .Q.A) and (actualType~()); :1b];
  0b
 };

// @kind function
// @private
// @overview Locate partitioned or segmented table.
// @param tableName {symbol} Table name.
// @return {symbol} Paths of the table.
.qtk.db._locateTable:{[tableName]
  partitions:.qtk.db.this.getPartitions[];
  .Q.par[`:.; ; tableName] each partitions
 };

// @kind function
// @private
// @overview Enumerate a value against sym.
// @param val {any} A value.
// @return {enum} Enumerated value against sym file in the current directory if the value is a symbol or a symbol vector;
//   otherwise the same value as-is.
.qtk.db._enumerate:{[val]
  .qtk.db._enumerateAgainst[`:.; `sym; val]
 };

// @kind function
// @private
// @overview Enumerate a value against a domain.
// @param dir {hsym} Handle to a directory.
// @param val {any} A value.
// @param domain {symbol} Name of domain.
// @return {enum} Enumerated value against the domain in the directory if the value is a symbol or a symbol vector;
//   otherwise the same value as-is.
.qtk.db._enumerateAgainst:{[dir;domain;val]
  if[11<>abs type val; :val];
  .Q.dd[dir; domain]?val
 };

// @kind function
// @private
// @overview Get all columns of an on-disk table.
// @param tablePath {hsym} Path to a splayed/partitioned table.
// @return {symbol[]} Columns of the table.
.qtk.db._getColumns:{[tablePath]
  get .Q.dd[tablePath; `.d]
 };

// @kind function
// @private
// @overview Save a table of data to an on-disk table.
// @param tablePath {hsym} Path to an on-disk table.
// @param tableData {table} A table of data.
// @return {hsym} The path to the table.
.qtk.db._saveTable:{[tablePath;tableData]
  columns:cols tableData;
  @[tablePath; columns; ,; tableData columns];
  if[not .qtk.db._dotDExists tablePath; @[tablePath; `.d; :; columns]];
  tablePath
 };

// @kind function
// @private
// @overview Get row count of an on-disk table. Count of the first column is used.
// @param tablePath {hsym} Path to an on-disk table.
// @return {long} Row count of the table.
.qtk.db._rowCount:{[tablePath]
  allColumns:.qtk.db._getColumns tablePath;
  count get .Q.dd[tablePath; first allColumns]
 };

// @kind function
// @private
// @overview Check if `.d` file exists in a path of a splayed/partitioned table.
// @param tablePath {hsym} Path to an on-disk table..
// @return {boolean} `1b` if `.d` exists; `0b` otherwise.
.qtk.db._dotDExists:{[tablePath]
  filesInPartition:.qtk.os.listDir tablePath;
  `.d in filesInPartition
 };

// @kind function
// @private
// @overview Get default value based on a path to a partitioned table and a column. The default value is type-specific
// null if it's a simple column, an empty typed list if it's a compound column, or an empty general list.
// @param tablePath {symbol} A file symbol to a partitioned table.
// @param column {symbol} A column name of the table.
// @return {any} Default value of the column.
.qtk.db._defaultValue:{[tablePath;column]
  columnValue:tablePath column;
  columnType:.Q.ty columnValue;
  $[columnType in .Q.a; first 0#columnValue;
    columnType in .Q.A; lower[columnType]$();
    ()
   ]
 };
