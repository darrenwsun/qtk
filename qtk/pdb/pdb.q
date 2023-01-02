// Utilities for partitioned database

.qtk.import.loadModule["db";`qtk];

// @kind function
// @subcategory pdb
// @overview Get all partitions of a database.
// @param dbDir {hsym} DB directory.
// @return {date[] | month[] | int[] | ()} Partitions of the database, or an empty list
// if the database is not a partitioned database.
// @throws {FileNotFoundError} If `dbDir` doesn't exist.
// @throws {NotADirectoryError} If `dbDir` doesn't point to a directory.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["pdb";`qtk];
// .qtk.import.loadModule["tbl";`qtk];
// tabRef:`:/tmp/qtk/db/getPartitions`date`PartitionedTable;
// .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];
//
// 2022.01.01 2022.01.02~.qtk.pdb.getPartitions first tabRef
.qtk.pdb.getPartitions:{[dbDir]
  items:.qtk.os.listDir dbDir;
  partitionDirectories:$[`par.txt in items;
                         raze .qtk.pdb._getPartitionDirectories each .qtk.pdb._getSegmentPaths[dbDir];
                         .qtk.pdb._getPartitionDirectories dbDir];
  if[0=count partitionDirectories; :()];
  getPartitionDatatype:{"DMII" 10 7 4?count x};
  partitionDatatype:getPartitionDatatype first partitionDirectories;
  partitionDatatype$partitionDirectories
 };

// @kind function
// @private
// @subcategory pdb
// @overview Get segment paths of a segmented database.
// @param dbDir {hsym} DB directory.
// @return {hsym[]} Segment paths of the database, or an empty symbol list
// if the database is not a segmented database.
// @throws {FileNotFoundError} If the directory doesn't exist.
// @throws {NotADirectoryError} If the input argument is not a directory.
.qtk.pdb._getSegmentPaths:{[dbDir]
  items:.qtk.os.listDir dbDir;
  segmentPaths:$[`par.txt in items;
                 hsym each `$read0 .Q.dd[dbDir; `par.txt];
                 `$()
   ];
  segmentPaths
 };

// @kind function
// @private
// @subcategory pdb
// @overview Get all partition directories of a partitioned database.
// @param dbDir {hsym} DB directory of the partitioned database.
// @return {string[]} Partition directories, or an empty general list if the database is not a partitioned database.
// @throws {FileNotFoundError} If the directory doesn't exist.
// @throws {NotADirectoryError} If the input argument is not a directory.
.qtk.pdb._getPartitionDirectories:{[dbDir]
  items:.qtk.os.listDir dbDir;
  items:items where items like "[0-9]*";
  string items
 };

// @kind function
// @subcategory pdb
// @overview Get partition field of a database under a directory.
// @param dbDir {hsym} A database directory.
// @return {symbol} Partition field of the database, either of ``#!q `date`month`year`int ``, or an empty symbol
// if the database is not a partitioned database.
// @see .qtk.pdb.this.getPartitionField
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["pdb";`qtk];
// .qtk.import.loadModule["tbl";`qtk];
// tabRef:`:/tmp/qtk/db/getPartitionField`date`PartitionedTable;
// .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];
//
// tabRef[1]~.qtk.pdb.getPartitionField first tabRef
.qtk.pdb.getPartitionField:{[dbDir]
  partitions:.qtk.pdb.getPartitions dbDir;
  $[14h=t:type partitions; `date;
    13h=t; `month;
    0h=t; `;
    all partitions within\: 1000 9999; `year;
    `int]
 };

// @kind function
// @subcategory pdb
// @overview Fill all tables missing in some partitions, using the most recent partition as a template.
// A rename of [`.Q.chk`](https://code.kx.com/q/ref/dotq/#qchk-fill-hdb).
// @param dbDir {hsym} Database directory.
// @return {any[]} Partitions that are filled with missing tables.
.qtk.pdb.fillTables:{[dbDir]
  .Q.chk dbDir
 };

// @kind function
// @subcategory pdb
// @overview Save table to a partition.
// See [`.Q.dpft`](https://code.kx.com/q/ref/dotq/#qdpft-save-table).
// @param dir {hsym} A directory handle.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} Table name.
// @param tableData {table} A table of data.
// @param options {dict (enum: dict | symbol)} Saving options.
//   - enum: a single domain for all symbol columns, or a dictionary between column names and their respective domains where the default domain is sym
// @return {hsym} The path to the table in the partition.
// @throws {SchemaError} If column names/types in the data table don't match those in the on-disk table (if exists).
.qtk.pdb.saveToPartition:{[dir;partition;tableName;tableData;options]
  tablePath:.Q.par[dir; partition; tableName];

  .qtk.pdb._validateSchema[tablePath; tableData];

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
// @private
// @overview Validate a table conforms to the schema of an on-disk table.
// @param tablePath {hsym} Path to an on-disk table.
// @param data {table} A table of data.
// @throws {SchemaError: mismatch between actual columns [*] and expected ones [*]} If columns in the data table don't match
//   those in the on-disk table (if exists).
// @throws {SchemaError: mismatch between actual types [*] and expected ones [*]} If data types of the columns
//   in the data table don't match those in the on-disk table (if exists).
.qtk.pdb._validateSchema:{[tablePath;data]
  if[not .qtk.os.path.exists tablePath; :(::)];
  if[not .qtk.db._dotDExists tablePath; :(::)];

  expectedCols:.qtk.db._getColumns tablePath;
  actualCols:cols data;
  if[not expectedCols~actualCols;
     '.qtk.err.compose[`SchemaError; "mismatch between actual columns [",.Q.s1[actualCols],"] and expected ones [",.Q.s1[expectedCols],"]"]
   ];

  if[not all .qtk.pdb._isTypeCompliant'[tablePath expectedCols; data actualCols];
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
.qtk.pdb._isTypeCompliant:{[target;actual]
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
.qtk.pdb._locateTable:{[tableName]
  partitions:.qtk.pdb.this.getPartitions[];
  .Q.par[`:.; ; tableName] each partitions
 };
