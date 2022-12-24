import "qdate.q_";

import "os";
import "err";

// @kind function
// @subcategory db
// @overview Get all partitions.
//
// See also [.Q.PV](https://code.kx.com/q/ref/dotq/#qpv-partition-values).
// @return {date[] | month[] | int[] | ()} Partitions of the database, or an empty general list
// if the database is not a partitioned database.
// @see .qtk.db.getModifiedPartitions
.qtk.db.getCurrentPartitions:{
  @[value; `.Q.PV; ()]
 };

// @kind function
// @private
// @subcategory db
// @overview Get all partitions of a database.
// @param dbDir {hsym} DB directory.
// @return {date[] | month[] | int[] | ()} Partitions of the database, or an empty general list
// if the database is not a partitioned database.
// @throws {FileNotFoundError} If the directory doesn't exist.
// @throws {NotADirectoryError} If the input argument is not a directory.
.qtk.db.getPartitions:{[dbDir]
  items:.qtk.os.listDir dbDir;
  partitionDirectories:$[`par.txt in items;
                         raze .qtk.db._getPartitionDirectories each .qtk.db._getSegmentPaths[dbDir];
                         .qtk.db._getPartitionDirectories dbDir];
  if[0=count partitionDirectories; :()];
  getPartitionDatatype:{`date`month`int`int[10 7 4?count x]};
  partitionDatatype:getPartitionDatatype first partitionDirectories;
  partitionDatatype$string partitionDirectories
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
// @return {symbol[]} Partition directories, or an empty general list if the database is not a partitioned database.
// @throws {FileNotFoundError} If the directory doesn't exist.
// @throws {NotADirectoryError} If the input argument is not a directory.
.qtk.db._getPartitionDirectories:{[dbDir]
  items:.qtk.os.listDir dbDir;
  items:items where items like "[0-9]*";
  items
 };

// @kind function
// @subcategory db
// @overview Get all partitions, subject to modification by [`.Q.view`](https://code.kx.com/q/ref/dotq/#qview-subview).
//
// See also [.Q.pv](https://code.kx.com/q/ref/dotq/#qpv-modified-partition-values).
// @return {date[] | month[] | int[] | ()} Partitions of the database subject to modification by `.Q.view`,
// or an empty general list if the database is not a partitioned database.
// @see .qtk.db.getCurrentPartitions
.qtk.db.getModifiedPartitions:{
  @[value; `.Q.pv; ()]
 };

// @kind function
// @subcategory db
// @overview Get partition field.
//
// See also [.Q.pf](https://code.kx.com/q/ref/dotq/#qpf-partition-field).
// @return {symbol} Partition field of the database, either of `` `date`month`year`int ``, or an empty symbol
// if the database is not a partitioned database.
.qtk.db.getPartitionField:{
  @[value; `.Q.pf; `]
 };

// @kind function
// @subcategory db
// @overview Get partitioned tables.
// @return {symbol[]} Partitioned tables of the database, or empty symbol vector if it's not a partitioned database.
.qtk.db.getPartitionedTables:{
  @[value; `.Q.pt; enlist `]
 };

// @kind function
// @subcategory db
// @overview Row count of a table per partition.
// @param tableName {symbol} A partitioned table by name.
// @return {dict} A dictionary from partitions to row count of the table in each partition.
// @throws {TableTypeError: not a partitioned table [*]} If the table is not a partitioned table.
.qtk.db.rowCountPerPartition:{[tableName]
  rowCounts:
    @[.Q.cn get@;
      tableName;
      {[msg;tableName]
        '.qtk.err.compose[`TableTypeError; "not a partitioned table [",string[tableName],"]"]
      }[; tableName]
     ];
  .qtk.db.getModifiedPartitions[]!rowCounts
 };

// @kind function
// @subcategory db
// @overview Row count of each partitioned table per partition.
// @return {dict} A table keyed by partition and each column is row count of a partitioned table in each partition.
// @throws {RuntimeError: no partition} If there is no partition.
.qtk.db.rowCountPerTablePerPartition:{
  partitionedTables:.qtk.db.getPartitionedTables[];
  .qtk.db.rowCountPerPartition each partitionedTables;
  rowCountsByTable:
    @[value; `.Q.pn;
      {'.qtk.err.compose[`RuntimeError; "no partition"]}
     ];
  rowCountsByTable[`partition]:.qtk.db.getModifiedPartitions[];
  `partition xkey flip rowCountsByTable
 };

// @kind function
// @subcategory db
// @overview Get all segments.
// @return {hsym[] | ()} Segments of the database, or an empty general list.
// if the database is not a partitioned database.
.qtk.db.getSegments:{
  @[value; `.Q.P; ()]
 };

// @kind function
// @subcategory db
// @overview Partitions per segment.
// @return {dict} A dictionary from segments to partitions in each segment. It's empty if the database doesn't load
// any segment.
.qtk.db.partitionsPerSegment:{
  .qtk.db.getSegments[]!@[value; `.Q.D; ()]
 };

// @kind function
// @subcategory db
// @overview Cast the datatype of a column.
// @param tableName {symbol} Table name.
// @param column {symbol} Name of new column to be added.
// @param newType {symbol | char} Name or char code of the new type.
// @return {symbol} The table name.
// @throws {ColumnNotFoundError: [*]} If `column` doesn't exist.
.qtk.db.castColumn:{[tableName;column;newType]
  .qtk.tbl.apply[tableName; column; newType$]
 };

// @kind function
// @subcategory db
// @overview Add an attribute to a column.
// @param tableName {symbol} Table name.
// @param column {symbol} A column name of the table.
// @param newAttr {symbol} Attribute to be added to the column.
// @return {symbol} The table name.
// @throws {ColumnNotFoundError} If `column` doesn't exist.
// @doctest
// system "l qtk/pkg.q";
// .pkg.add enlist "qtk";
// .q.import "db";
//
// `t set ([]c1:til 3);
// .qtk.db.addAttr[`t; `c1; `s];
// `s=attr t`c1
.qtk.db.addAttr:{[tableName;column;newAttr]
  .qtk.tbl.apply[tableName; column; newAttr#]
 };

// @kind function
// @subcategory db
// @overview Remove attribute from a column.
// @param tableName {symbol} Table name.
// @param column {symbol} A column name of the table.
// @return {symbol} The table name.
// @throws {ColumnNotFoundError: [*]} where If `column` doesn't exist.
.qtk.db.removeAttr:{[tableName;column]
  .qtk.db.addAttr[tableName; column; `]
 };


// @kind function
// @subcategory db
// @overview Fix table based on a good partition. See `.qtk.db._fixTable` for fixable issues.
// @param tableName {symbol} Table name.
// @param refPartition {date | month | int} A partition to which the other partitions refer.
// @return {symbol} The table name.
// @throws {TableTypeError: not a partitioned table [*]} If the table is not a partitioned table.
// @see .qtk.db._fixTable
.qtk.db.fixTable:{[tableName;refPartition]
  if[not tableName in .qtk.db.getPartitionedTables[];
     '.qtk.err.compose[`TableTypeError; "not a partitioned table [",string[tableName],"]"]
   ];
  tablePath:.Q.par[`:.; refPartition; tableName];
  refColumns:.qtk.db._getColumns tablePath;
  defaultValues:.qtk.db._defaultValue[tablePath;] each refColumns;
  tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getCurrentPartitions[] except refPartition;
  .qtk.db._fixTable[; refColumns!defaultValues] each tablePaths;
  tableName
 };

// @kind function
// @subcategory db
// @overview Fill all tables missing in some partitions, using the most recent partition as a template.
// See [`.Q.chk`](https://code.kx.com/q/ref/dotq/#qchk-fill-hdb).
// @return {*[]} Partitions that are filled with missing tables.
// @throws {TableTypeError: not a partitioned table [*]} If the table is not a partitioned table.
.qtk.db.fillTables:{
  .Q.chk[`:.]
 };

// @kind function
// @subcategory db
// @overview Get a slice of a table.
// See [`.Q.ind`](https://code.kx.com/q/ref/dotq/#qind-partitioned-index).
// @param tableName {symbol} Table name.
// @param startIndex {integer} Index of the first element in the slice.
// @param endIndex {integer} Index of the next element after the last element in the slice.
// @return {table} A slice of the table within the given range.
.qtk.db.slice:{[tableName;startIndex;endIndex]
  tableType:.qtk.tbl.getType tableName;
  $[tableType in `Plain`Splayed;
    (endIndex-startIndex)#startIndex _get tableName;
    // tableType=`Partitioned
    .Q.ind[get tableName; startIndex+til endIndex-startIndex]
   ]
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
// @overview Check if a column exists in a table. For splayed tables, column existence requires that the column
// appears in `.d` file and its data file exists. For partitioned table, it requires the condition holds for all
// partitions.
// @param tableName {symbol} Table name.
// @param column {symbol} A column name.
// @return {boolean} `1b` if the column exists in the table; `0b` otherwise.
.qtk.db.columnExists:{[tableName;column]
  tableType:.qtk.tbl.getType tableName;
  $[tableType=`Plain;
    column in cols tableName;
    tableType=`Serialized;
    column in cols get tableName;
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.db._columnExists[tablePath; column]
      ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getCurrentPartitions[];
      // Can make the following part simpler by `all .qtk.db._columnExists[...]` at the cost of performance, due to inability
      // to return early
      partitionCount:count tablePaths;
      i:0;
      while[i<partitionCount;
            if[not .qtk.db._columnExists[tablePaths[i]; column]; :0b];
            i +: 1
       ];
      1b
      ]
   ]
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
// @param target {*[]} Target list.
// @param actual {*[]} Actual list.
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
  partitions:.qtk.db.getCurrentPartitions[];
  .Q.par[`:.; ; tableName] each partitions
 };

// @kind function
// @private
// @overview Enumerate a value against sym.
// @param val {*} A value.
// @return {enum} Enumerated value against sym file in the current directory if the value is a symbol or a symbol vector;
//   otherwise the same value as-is.
.qtk.db._enumerate:{[val]
  .qtk.db._enumerateAgainst[`:.; `sym; val]
 };

// @kind function
// @private
// @overview Enumerate a value against a domain.
// @param dir {hsym} Handle to a directory.
// @param val {*} A value.
// @param domain {symbol} Name of domain.
// @return {enum} Enumerated value against the domain in the directory if the value is a symbol or a symbol vector;
//   otherwise the same value as-is.
.qtk.db._enumerateAgainst:{[dir;domain;val]
  if[11<>abs type val; :val];
  .Q.dd[dir; domain]?val
 };

// @kind function
// @private
// @overview Add a table to a path.
// @param dbDir {hsym} DB directory.
// @param tablePath {hsym} Path to an on-disk table.
// @param data {table} Table data.
// @return {hsym} The path to the table.
.qtk.db._addTable:{[dbDir;tablePath;data]
  @[tablePath; `; :; .Q.en[dbDir; data]];
  tablePath
 };

// @kind function
// @private
// @overview Rename an on-disk table.
// @param tablePath {hsym} Path to an on-disk table.
// @param newName {hsym} New table name.
// @return {hsym} Path to the renamed table in the partition.
.qtk.db._renameTable:{[tablePath;newName]
  newTablePath:.Q.dd[first[` vs tablePath]; newName];
  .qtk.os.move[tablePath; newTablePath];
  newTablePath
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
// @overview Fix an on-disk table based on a mapping between columns and their default values. Fixable issues include:
//   - create `.d` file if missing
//   - add missing columns to `.d` file
//   - add missing data files to disk
//   - remove excessive columns from `.d` file but leave data files untouched
//   - put columns in the right order
// @param tablePath {hsym} Path to an on-disk table.
// @param columnDefaults {dict} A mapping between columns and their default values.
// @return {hsym} The path to the table.
.qtk.db._fixTable:{[tablePath;columnDefaults]
  filesInPartition:.qtk.os.listDir tablePath;
  addColumnProjection:.qtk.tbl._addColumn[tablePath; ;];
  expectedColumns:key columnDefaults;

  if[not .qtk.db._dotDExists tablePath; @[tablePath; `.d; :; expectedColumns]];

  // add missing columns
  allColumns:.qtk.db._getColumns tablePath;
  if[count missingColumns:expectedColumns except allColumns;
     addColumnProjection'[missingColumns; columnDefaults missingColumns]
   ];

  // add missing data files
  allColumns:.qtk.db._getColumns tablePath;
  if[count missingDataColumns:allColumns except filesInPartition;
     addColumnProjection'[missingDataColumns; columnDefaults missingDataColumns]
   ];

  // remove excessive columns
  allColumns:.qtk.db._getColumns tablePath;
  if[count excessiveColumns:allColumns except expectedColumns;
     .qtk.tbl._deleteColumnHeader[tablePath;] each excessiveColumns;
   ];

  // fix column order
  allColumns:.qtk.db._getColumns tablePath;
  if[not allColumns~expectedColumns;
     .qtk.tbl._reorderColumns[tablePath; expectedColumns]
   ];

  tablePath
 };

// @kind function
// @private
// @overview Check if a column exists in an on-disk table. A column exists if it's listed in .d file and
// there is a file of the same name in the table path.
// @param tablePath {hsym} Path to an on-disk table.
// @param column {symbol} A column name.
// @return {boolean} `1b` if the column exists in the table; `0b` otherwise.
.qtk.db._columnExists:{[tablePath;column]
  allColumns:.qtk.db._getColumns tablePath;
  if[not column in allColumns; :0b];
  columnPath:.Q.dd[tablePath; column];
  .qtk.os.path.isFile columnPath
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
// @return {*} Default value of the column.
.qtk.db._defaultValue:{[tablePath;column]
  columnValue:tablePath column;
  columnType:.Q.ty columnValue;
  $[columnType in .Q.a; first 0#columnValue;
    columnType in .Q.A; lower[columnType]$();
    ()
   ]
 };
