import "qdate.q_";

import "os";
import "err";

// @kind function
// @overview Get table type: Normal, Splayed, or Partitioned. Note that tables in segmented database are classified
// as Partitioned.
// @param t {symbol | table} Table name or value.
// @return {symbol} Table type: Normal, Splayed, or Partitioned.
.qtk.db.getTableType:{[t]
  table:$[-11h=type t; get t; t];
  isPartitioned:.Q.qp table;
  $[isPartitioned~1b; `Partitioned;
    isPartitioned~0b; `Splayed;
    `Normal
   ]
 };

// @kind function
// @overview Get all partitions.
// @return {date[] | month[] | int[] | ()} Partitions of the database, or an empty general list.
// if the database is not a partitioned database.
.qtk.db.getPartitions:{
  @[value; `.Q.PV; ()]
 };

// @kind function
// @overview Get all partitions, subject to modification by .Q.view.
// @return {date[] | month[] | int[] | ()} Partitions of the database, subject to modification by .Q.view,
// or an empty general list if the database is not a partitioned database.
.qtk.db.getModifiedPartitions:{
  @[value; `.Q.pv; ()]
 };

// @kind function
// @overview Get partition field.
// @return {symbol} Partition fields of the database, either of `date`month`year`int, or an empty symbol
// if the database is not a partitioned database.
.qtk.db.getPartitionField:{
  @[value; `.Q.pf; `]
 };

// @kind function
// @overview Get partitioned tables.
// @return {symbol[]} Partitioned tables of the database, or empty symbol vector if it's not a partitioned database.
.qtk.db.getPartitionedTables:{
  @[value; `.Q.pt; enlist `]
 };

// @kind function
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
// @overview Get all segments.
// @return {hsym[] | ()} Segments of the database, or an empty general list.
// if the database is not a partitioned database.
.qtk.db.getSegments:{
  @[value; `.Q.P; ()]
 };

// @kind function
// @overview Partitions per segment.
// @return {dict} A dictionary from segments to partitions in each segment. It's empty if the database doesn't load
// any segment.
.qtk.db.partitionsPerSegment:{
  .qtk.db.getSegments[]!@[value; `.Q.D; ()]
 };

// @kind function
// @overview Add a new table.
// @param tableName {symbol} Table name.
// @param data {table} Table data.
// @param tableType {symbol} Normal, Splayed, or Partitioned.
// @return {symbol} The table name.
// @throws {TableTypeError: invalid table type [*]} If the table type is not valid.
.qtk.db.addTable:{[tableName;data;tableType]
  $[tableType=`Normal;
    tableName set data;
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.db._addTable[tablePath; data];
      ];
    tableType=`Partitioned;
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getPartitions[];
      .qtk.db._addTable[; data] each tablePaths;
      ];
    '.qtk.err.compose[`TableTypeError; "invalid table type [",string[tableType],"]"]
   ];
  tableName
 };

// @kind function
// @overview Rename a table.
// @param tableName {symbol} Table name.
// @param newName {symbol} New name of the table.
// @return {symbol} New table name.
.qtk.db.renameTable:{[tableName;newName]
  tableType:.qtk.db.getTableType tableName;
  $[tableType=`Normal;
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
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getPartitions[];
      .qtk.db._renameTable[; newName] each tablePaths;
      ]
   ];
  newName
 };

// @kind function
// @overview Add a column to a table.
// @param tableName {symbol} Table name.
// @param column {symbol} Name of new column to be added.
// @param default {*} Value to be set on the new column.
// @return {symbol} The table name.
// @throws {NameError} If the column name is not valid.
// @throws {ColumnExistsError} If the column exists.
.qtk.db.addColumn:{[tableName;column;default]
  .qtk.db._validateColumnName column;
  .qtk.db._validateColumnNotExists[tableName; column];

  tableType:.qtk.db.getTableType tableName;
  $[tableType=`Normal;
    [
      if[-11h=type default; default:enlist default];                      // enlist singleton symbol value
      ![tableName; (); 0b; enlist[column]!enlist[default]];
      ];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.db._addColumn[tablePath; column; .qtk.db._enumerate default];
      ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getPartitions[];
      .qtk.db._addColumn[; column; .qtk.db._enumerate default] each tablePaths;
      ]
   ];

  tableName
 };

// @kind function
// @overview Delete a column from a table.
// @param tableName {symbol} Table name.
// @param column {symbol} A column to be deleted.
// @return {symbol} The table name.
.qtk.db.deleteColumn:{[tableName;column]
  tableType:.qtk.db.getTableType tableName;
  $[tableType=`Normal;
    ![tableName; (); 0b; enlist[column]];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.db._deleteColumn[tablePath; column];
      ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getPartitions[];
      .qtk.db._deleteColumn[; column] each tablePaths;
      ]
   ];
  tableName
 };

// @kind function
// @overview Rename column(s) from a table.
// @param tableName {symbol} Table name.
// @param nameDict {dict} A dictionary from existing name(s) to new name(s).
// @return {symbol} The table name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
// @throws {ColumnNotFoundError: [*]} If some column in `nameDict` doesn't exist.
.qtk.db.renameColumns:{[tableName;nameDict]
  .qtk.db._validateColumnName each value nameDict;
  .qtk.db._validateColumnExists[tableName;] each key nameDict;

  tableType:.qtk.db.getTableType tableName;
  $[tableType=`Normal;
    tableName set nameDict xcol get tableName;
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.db._renameColumns[tablePath; nameDict];
      ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getPartitions[];
      .qtk.db._renameColumns[; nameDict] each tablePaths;
      ]
   ];
  tableName
 };

// @kind function
// @overview Reorder columns of a table.
// @param tableName {symbol} Table name.
// @param firstColumns {dict} First columns after reordering.
// @return {symbol} The table name.
// @throws {ColumnNotFoundError: [*]} If some column in `firstColumns` doesn't exist.
.qtk.db.reorderColumns:{[tableName;firstColumns]
  .qtk.db._validateColumnExists[tableName;] each firstColumns;

  tableType:.qtk.db.getTableType tableName;
  $[tableType=`Normal;
    tableName set firstColumns xcols get tableName;
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.db._reorderColumns[tablePath; firstColumns];
      ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getPartitions[];
      .qtk.db._reorderColumns[; firstColumns] each tablePaths;
      ]
   ];
  tableName
 };

// @kind function
// @overview Copy an existing column to a new column.
// @param tableName {symbol} Table name.
// @param sourceColumn {symbol} Source column.
// @param targetColumn {symbol} Target column.
// @return {symbol} The table name.
// @throws {ColumnNotFoundError: [*]} If `sourceColumn` doesn't exist.
// @throws {ColumnExistsError: [*]} If `targetColumn` exists.
// @throws {NameError: invalid column name [*]} If name of `targetColumn` is not valid.
.qtk.db.copyColumn:{[tableName;sourceColumn;targetColumn]
  .qtk.db._validateColumnExists[tableName; sourceColumn];
  .qtk.db._validateColumnNotExists[tableName; targetColumn];
  .qtk.db._validateColumnName targetColumn;

  tableType:.qtk.db.getTableType tableName;
  $[tableType=`Normal;
    ![tableName; (); 0b; enlist[targetColumn]!enlist[sourceColumn]];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.db._copyColumn[tablePath; sourceColumn; targetColumn];
      ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getPartitions[];
      .qtk.db._copyColumn[; sourceColumn; targetColumn] each tablePaths;
      ]
   ];

  tableName
 };

// @kind function
// @overview Apply a function to a column.
// @param tableName {symbol} Table name.
// @param column {symbol} Name of new column to be added.
// @param function {function} Function to be applied.
// @return {symbol} The table name.
// @throws {ColumnNotFoundError: [*]} If `column` doesn't exist.
.qtk.db.applyToColumn:{[tableName;column;function]
  .qtk.db._validateColumnExists[tableName; column];

  tableType:.qtk.db.getTableType tableName;
  $[tableType=`Normal;
    ![tableName; (); 0b; enlist[column]!enlist[function (value tableName)[column]]];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.db._applyToColumn[tablePath; column; function];
      ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getPartitions[];
      .qtk.db._applyToColumn[; column; function] each tablePaths;
      ]
   ];

  tableName
 };

// @kind function
// @overview Cast the datatype of a column.
// @param tableName {symbol} Table name.
// @param column {symbol} Name of new column to be added.
// @param newType {symbol | char} Name or char code of the new type.
// @return {symbol} The table name.
// @throws {ColumnNotFoundError: [*]} If `column` doesn't exist.
.qtk.db.castColumn:{[tableName;column;newType]
  .qtk.db.applyToColumn[tableName; column; newType$]
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
// `t set ([]c1:til 3);
// .qtk.db.addAttr[`t; `c1; `s];
// `s=attr t`c1
.qtk.db.addAttr:{[tableName;column;newAttr]
  .qtk.db.applyToColumn[tableName; column; newAttr#]
 };

// @kind function
// @overview Remove attribute from a column.
// @param tableName {symbol} Table name.
// @param column {symbol} A column name of the table.
// @return {symbol} The table name.
// @throws {ColumnNotFoundError: [*]} where If `column` doesn't exist.
.qtk.db.removeAttr:{[tableName;column]
  .qtk.db.addAttr[tableName; column; `]
 };

// @kind function
// @overview Update values in certain columns of a table, in a similar format to functional update.
// @param table {symbol | table} Table name or value.
// @param criteria {*[]} A list of criteria where the update is applied to, or empty list if it's applied to the whole table.
// @param assignment {dict} A mapping from column names to values of parse-tree form
// @return {symbol} The table name.
// @throws {ColumnNotFoundError: [*]} If a column doesn't exist.
.qtk.db.update:{[tableName;criteria;assignment]
  .qtk.db._validateColumnExists[tableName;] each key assignment;

  tableType:.qtk.db.getTableType tableName;
  $[tableType=`Normal;
    ![tableName; criteria; 0b; assignment];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.db._update[tablePath; criteria; assignment];
      ];
    // tableType=`Partitioned
    [
      partitionField:.qtk.db.getPartitionField[];
      $[(first criteria)[1]~partitionField;
        [
          partitions:?[tableName; enlist first criteria; 0b; (enlist partitionField)!(enlist partitionField)] partitionField;
          tablePaths:{.Q.par[`:.; x; y]}[; tableName] each partitions;
          .qtk.db._update[; 1_criteria; assignment] each tablePaths;
          ];
        [
          partitions:.qtk.db.getPartitions[];
          tablePaths:{.Q.par[`:.; x; y]}[; tableName] each partitions;
          .qtk.db._update[; criteria; assignment] each tablePaths;
          ]
       ];
      ]
   ];

  tableName
 };

// @kind function
// @overview Delete rows of a table given certain criteria, in a similar format to functional delete.
// @param table {symbol | table} Table name or value.
// @param criteria {*[]} A list of criteria where matching rows will be deleted, or empty list if it's applied to the whole table.
// @return {symbol} The table name.
.qtk.db.delete:{[tableName;criteria]
  tableType:.qtk.db.getTableType tableName;
  $[tableType=`Normal;
    ![tableName; criteria; 0b; `$()];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.db._delete[tablePath; criteria];
      ];
    // tableType=`Partitioned
    [
      partitionField:.qtk.db.getPartitionField[];
      $[(first criteria)[1]~partitionField;
        [
          partitions:?[tableName; enlist first criteria; 0b; (enlist partitionField)!(enlist partitionField)] partitionField;
          tablePaths:{.Q.par[`:.; x; y]}[; tableName] each partitions;
          .qtk.db._delete[; 1_criteria] each tablePaths;
          ];
        [
          partitions:.qtk.db.getPartitions[];
          tablePaths:{.Q.par[`:.; x; y]}[; tableName] each partitions;
          .qtk.db._delete[; criteria] each tablePaths;
          ]
       ];
      ]
   ];

  tableName
 };


// @kind function
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
  tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getPartitions[] except refPartition;
  .qtk.db._fixTable[; refColumns!defaultValues] each tablePaths;
  tableName
 };

// @kind function
// @overview Fill all tables missing in some partitions, using the most recent partition as a template.
// See [`.Q.chk`](https://code.kx.com/q/ref/dotq/#qchk-fill-hdb).
// @return {*[]} Partitions that are filled with missing tables.
// @throws {TableTypeError: not a partitioned table [*]} If the table is not a partitioned table.
.qtk.db.fillTables:{
  .Q.chk[`:.]
 };

// @kind function
// @overview Get a slice of a table.
// See [`.Q.ind`](https://code.kx.com/q/ref/dotq/#qind-partitioned-index).
// @param tableName {symbol} Table name.
// @param startIndex {integer} Index of the first element in the slice.
// @param endIndex {integer} Index of the next element after the last element in the slice.
// @return {table} A slice of the table within the given range.
.qtk.db.slice:{[tableName;startIndex;endIndex]
  tableType:.qtk.db.getTableType tableName;
  $[tableType in `Normal`Splayed;
    (endIndex-startIndex)#startIndex _get tableName;
    // tableType=`Partitioned
    .Q.ind[get tableName; startIndex+til endIndex-startIndex]
   ]
 };

// @kind function
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
// @overview Check if a column exists in a table. For splayed tables, column existence requires that the column
// appears in `.d` file and its data file exists. For partitioned table, it requires the condition holds for all
// partitions.
// @param tableName {symbol} Table name.
// @param column {symbol} A column name.
// @return {boolean} `1b` if the column exists in the table; `0b` otherwise.
.qtk.db.columnExists:{[tableName;column]
  tableType:.qtk.db.getTableType tableName;
  $[tableType=`Normal;
    column in cols tableName;
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .qtk.db._columnExists[tablePath; column]
      ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .qtk.db.getPartitions[];
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
// @overview Validate column name.
// @param columnName {symbol} A column name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
.qtk.db._validateColumnName:{[columnName]
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
.qtk.db._validateColumnExists:{[tableName;column]
  if[not .qtk.db.columnExists[tableName; column];
     '.qtk.err.compose[`ColumnNotFoundError; "[",string[column],"]"]
   ];
 };

// @kind function
// @private
// @overview Validate that a column doesn't exist, either header or data or neither.
// @param tableName {symbol} Table name.
// @param column {symbol} A column name.
// @throws {ColumnExistsError: [*]} If the column exists.
.qtk.db._validateColumnNotExists:{[tableName;column]
  if[.qtk.db.columnExists[tableName; column];
     '.qtk.err.compose[`ColumnExistsError; "[",string[column],"]"]
   ];
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
  partitions:.qtk.db.getPartitions[];
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
// @param tablePath {hsym} Path to an on-disk table.
// @param data {table} Table data.
// @return {hsym} The path to the table.
.qtk.db._addTable:{[tablePath;data]
  @[tablePath; `; :; .Q.en[`:.; data]];
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
// @overview Add a column to a table specified by a path, using a default value unless
// a length- and type-compliant column data file exists.
// @param tablePath {hsym} Path to an on-disk table.
// @param column {symbol} Name of new column to be added.
// @param defaultValue {*} Value to be set on the new column.
// @return {hsym} The path to the table.
.qtk.db._addColumn:{[tablePath;column;defaultValue]
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
// @private
// @overview Delete a column of an on-disk table and its data.
// @param tablePath {hsym} Path to an on-disk table.
// @param column {symbol} A column to be deleted.
// @return {hsym} The path to the table.
.qtk.db._deleteColumn:{[tablePath;column]
  columnPath:.Q.dd[tablePath; column];
  .qtk.db._deleteColumnData columnPath;
  .qtk.db._deleteColumnHeader[tablePath; column];
  tablePath
 };

// @kind function
// @private
// @overview Delete a column header of an on-disk table.
// @param tablePath {hsym} Path to an on-disk table.
// @param column {symbol} A column to be deleted.
// @return {hsym} The path to the table.
.qtk.db._deleteColumnHeader:{[tablePath;column]
  allColumns:.qtk.db._getColumns tablePath;
  @[tablePath; `.d; :; allColumns except column];
  tablePath
 };

// @kind function
// @private
// @overview Delete a column on disk.
// @param columnPath {symbol} A file symbol representing an existing column.
.qtk.db._deleteColumnData:{[columnPath]
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
// @private
// @overview Rename column(s) of an on-disk table.
// @param tablePath {hsym} Path to an on-disk table.
// @param nameDict {dict} A dictionary from old name(s) to new name(s).
// @return {hsym} The path to the table.
.qtk.db._renameColumns:{[tablePath;nameDict]
  renameOneColumn:.qtk.db._renameOneColumn[tablePath; ;];
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
.qtk.db._renameOneColumn:{[tablePath;oldName;newName]
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
// @overview Copy an existing column of an on-disk table to a new column.
// @param tablePath {hsym} Path to an on-disk table.
// @param sourceColumn {symbol} Source column.
// @param targetColumn {symbol} Target column.
// @return {hsym} The path to the table.
.qtk.db._copyColumn:{[tablePath;sourceColumn;targetColumn]
  sourceColumnPath:.Q.dd[tablePath; sourceColumn];
  targetColumnPath:.Q.dd[tablePath; targetColumn];
  .qtk.db._copyColumnOnDisk[sourceColumnPath; targetColumnPath];
  @[tablePath; `.d; ,; targetColumn];
  tablePath
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
// @overview Apply a function to a column of an on-disk table.
// @param tablePath {hsym} Path to an on-disk table.
// @param column {symbol} A column name of the table.
// @param function {function} Function to be applied to the column.
// @return {hsym} The path to the table.
.qtk.db._applyToColumn:{[tablePath;column;function]
  columnPath:.Q.dd[tablePath; column];
  oldValue:get columnPath;
  oldAttr:attr oldValue;
  newValue:function oldValue;
  newAttr:attr newValue;
  if[(not oldValue~newValue) or (not oldAttr~newAttr);
     .[columnPath; (); :; newValue]
   ];
  tablePath
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
  addColumnProjection:.qtk.db._addColumn[tablePath; ;];
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
     .qtk.db._deleteColumnHeader[tablePath;] each excessiveColumns;
   ];

  // fix column order
  allColumns:.qtk.db._getColumns tablePath;
  if[not allColumns~expectedColumns;
     .qtk.db._reorderColumns[tablePath; expectedColumns]
   ];

  tablePath
 };

// @kind function
// @private
// @overview Reorder columns of an on-disk table with specified first columns.
// @param tablePath {hsym} Path to an on-disk table.
// @param firstColumns {dict} First columns after reordering.
// @return {hsym} The path to the table.
.qtk.db._reorderColumns:{[tablePath;firstColumns]
  allColumns:.qtk.db._getColumns tablePath;
  @[tablePath; `.d; :; firstColumns,allColumns except firstColumns];
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
// @overview Update values in certain columns of an on-disk table, in a similar format to functional update.
// @param tablePath {hsym} Path to an on-disk table.
// @param criteria {*[]} A list of criteria where the update is applied to, or empty list if it's applied to the whole table.
// @param assignment {dict} A mapping from column names to values
// @return {hsym} The path to the table.
// @throws {type} If it's a partial update and the new values are not type-compatible with existing values.
.qtk.db._update:{[tablePath;criteria;assignment]
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

// @kind function
// @private
// @overview Copy a column on disk.
// @param oldColumnPath {symbol} A file symbol representing an existing column.
// @param newColumnPath {symbol} A file symbol representing a new column.
.qtk.db._copyColumnOnDisk:{[oldColumnPath;newColumnPath]
  if[.qtk.os.path.isFile newColumnPath;
     .qtk.db._renameColumnOnDisk[newColumnPath; hsym `$string[newColumnPath],"_",.qdate.print["%Y%m%d_%H%M%S"; .z.d]]
   ];
  .qtk.os.copy[oldColumnPath; newColumnPath];
  if[.qtk.os.path.isFile dataFile:`$string[oldColumnPath],"#";
     .qtk.os.copy[dataFile; `$string[newColumnPath],"#"]
   ];
  if[.qtk.os.path.isFile dataFile:`$string[oldColumnPath],"##";
     .qtk.os.copy[dataFile; `$string[newColumnPath],"##"]
   ];
 };

// @kind function
// @private
// @overview Rename a column on disk.
// @param oldColumnPath {symbol} A file symbol representing an existing column.
// @param newColumnPath {symbol} A file symbol representing a new column.
.qtk.db._renameColumnOnDisk:{[oldColumnPath;newColumnPath]
  if[.qtk.os.path.isFile newColumnPath;
     .qtk.db._renameColumnOnDisk[newColumnPath; `$string[newColumnPath],"_",.qdate.print["%Y%m%d_%H%M%S"; .z.d]]
   ];
  .qtk.os.move[oldColumnPath; newColumnPath];
  if[.qtk.os.path.isFile dataFile:`$string[oldColumnPath],"#";
     .qtk.os.move[dataFile; `$string[newColumnPath],"#"]
   ];
  if[.qtk.os.path.isFile dataFile:`$string[oldColumnPath],"##";
     .qtk.os.move[dataFile; `$string[newColumnPath],"##"]
   ];
 };