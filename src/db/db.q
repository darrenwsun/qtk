import "os";
import "qdate.q_";

// @kind function
// @param t {symbol | table} A table by name or value.
// @overview Get table type.
// @return {symbol} Table type: Normal, Splayed, or Partitioned.
.db.getTableType:{[t]
  table:$[-11h=type t; get t; t];
  isPartitioned:.Q.qp table;
  $[isPartitioned~1b; `Partitioned;
    isPartitioned~0b; `Splayed;
    `Normal]
 };

// @kind function
// @overview Get all partitions.
// @return {date[] | month[] | int[] | ()} Partitions of the database, or an empty general list
// if the database is not a partitioned database.
.db.getPartitions:{
  @[value; `.Q.PV; ()]
 };

// @kind function
// @overview Get all partitions, subject to modification by .Q.view.
// @return {date[] | month[] | int[] | ()} Partitions of the database, subject to modification by .Q.view,
// or an empty general list if the database is not a partitioned database.
.db.getModifiedPartitions:{
  @[value; `.Q.pv; ()]
 };

// @kind function
// @overview Get partition field.
// @return {symbol} Partition fields of the database, either of `date`month`year`int, or an empty general list
// if the database is not a partitioned database.
.db.getPartitionField:{
  @[value; `.Q.pf; `]
 };

// @kind function
// @overview Get partitioned tables.
// @return {symbol[]} Partitioned tables of the database, or empty symbol vector if it's not a partitioned database.
.db.getPartitionedTables:{
  @[value; `.Q.pt; enlist`]
 };

// @kind function
// @overview Row count of a table per partition.
// @param tableName {symbol} A partitioned table by name.
// @return {dict} A dictionary from partitions to row count of the table in each partition.
// @throws {TableTypeError: not a partitioned table [*]} If the table is not a partitioned table.
.db.rowCountPerPartition:{[tableName]
  rowCounts:@[.Q.cn get@;
    tableName;
    {[msg;tableName]
      '"TableTypeError: not a partitioned table [",string[tableName],"]"
    }[; tableName]
   ];
  .db.getModifiedPartitions[]!rowCounts
 };

// @kind function
// @overview Row count of each partitioned table per partition.
// @return {dict} A table keyed by partition and each column is row count of a partitioned table in each partition.
// @throws {RuntimeError: no partition} If there is no partition.
.db.rowCountPerTablePerPartition:{
  partitionedTables:.db.getPartitionedTables[];
  .db.rowCountPerPartition each partitionedTables;
  rowCountsByTable:@[value; `.Q.pn; {'"RuntimeError: no partition"}];
  rowCountsByTable[`partition]:.db.getModifiedPartitions[];
  `partition xkey flip rowCountsByTable
 };

// @kind function
// @overview Add a new table.
// @param tableName {symbol} A table by name.
// @param data {table} Table data.
// @param tableType {symbol} Normal, Splayed, or Partitioned.
// @return {symbol} The table by name.
// @throws {RuntimeError: invalid table type [*]} If the table type is not valid.
.db.addTable:{[tableName;data;tableType]
  $[tableType=`Normal;
    tableName set data;
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .db._addTable[tablePath; data];
    ];
    tableType=`Partitioned;
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .db.getPartitions[];
      .db._addTable[; data] each tablePaths;
    ];
    '"RuntimeError: invalid table type [",string[tableType],"]"
   ];
  tableName
 };

// @kind function
// @overview Rename a table.
// @param tableName {symbol} A table by name.
// @param newName {symbol} New name of the table.
// @return {symbol} New table name.
.db.renameTable:{[tableName;newName]
  tableType:.db.getTableType tableName;
  $[tableType=`Normal;
    [
      newName set get tableName;
      ![`.; (); 0b; enlist tableName];
    ];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .db._renameTable[tablePath; newName];
    ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .db.getPartitions[];
      .db._renameTable[; newName] each tablePaths;
    ]
   ];
  newName
 };

// @kind function
// @overview Add a column to a table.
// @param tableName {symbol} A table by name.
// @param column {symbol} New column to be added.
// @param defaultValue {*} Value to be set on the new column.
// @return {symbol} The table by name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
// @throws {ColumnExistsError: [*]} If the column exists.
.db.addColumn:{[tableName;column;defaultValue]
  .db._validateColumnName column;
  .db._validateColumnNotExists[tableName; column];

  tableType:.db.getTableType tableName;
  $[tableType=`Normal;
    [
      if[-11h=type defaultValue; defaultValue:enlist defaultValue];    // enlist singleton symbol value
      ![tableName; (); 0b; enlist[column]!enlist[defaultValue]];
    ];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .db._addColumn[tablePath; column; .db._enumerate defaultValue];
    ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .db.getPartitions[];
      .db._addColumn[; column; .db._enumerate defaultValue] each tablePaths;
    ]
   ];

  tableName
 };

// @kind function
// @overview Delete a column from a table.
// @param tableName {symbol} A table by name.
// @param column {symbol} A column to be deleted.
// @return {symbol} The table by name.
.db.deleteColumn:{[tableName;column]
  tableType:.db.getTableType tableName;
  $[tableType=`Normal;
    ![tableName; (); 0b; enlist[column]];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .db._deleteColumn[tablePath; column];
    ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .db.getPartitions[];
      .db._deleteColumn[; column] each tablePaths;
    ]
   ];
  tableName
 };

// @kind function
// @overview Rename column(s) from a table.
// @param tableName {symbol} A table by name.
// @param nameDict {dict} A dictionary from existing name(s) to new name(s).
// @return {symbol} The table by name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
// @throws {ColumnNotFoundError: [*]} If some column in `nameDict` doesn't exist.
.db.renameColumns:{[tableName;nameDict]
  .db._validateColumnName each value nameDict;
  .db._validateColumnExists[tableName; ] each key nameDict;

  tableType:.db.getTableType tableName;
  $[tableType=`Normal;
    tableName set nameDict xcol get tableName;
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .db._renameColumns[tablePath; nameDict];
    ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .db.getPartitions[];
      .db._renameColumns[; nameDict] each tablePaths;
    ]
   ];
  tableName
 };

// @kind function
// @overview Reorder columns of a table.
// @param tableName {symbol} A table by name.
// @param firstColumns {dict} First columns after reordering.
// @return {symbol} The table by name.
// @throws {ColumnNotFoundError: [*]} If some column in `firstColumns` doesn't exist.
.db.reorderColumns:{[tableName;firstColumns]
  .db._validateColumnExists[tableName; ] each firstColumns;

  tableType:.db.getTableType tableName;
  $[tableType=`Normal;
    tableName set firstColumns xcols get tableName;
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .db._reorderColumns[tablePath; firstColumns];
    ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .db.getPartitions[];
      .db._reorderColumns[; firstColumns] each tablePaths;
    ]
   ];
  tableName
 };

// @kind function
// @overview Copy an existing column to a new column.
// @param tableName {symbol} A table by name.
// @param sourceColumn {symbol} Source column.
// @param targetColumn {symbol} Target column.
// @return {symbol} The table by name.
// @throws {ColumnNotFoundError: [*]} If `sourceColumn` doesn't exist.
// @throws {ColumnExistsError: [*]} If `targetColumn` exists.
// @throws {NameError: invalid column name [*]} If name of `targetColumn` is not valid.
.db.copyColumn:{[tableName;sourceColumn;targetColumn]
  .db._validateColumnExists[tableName; sourceColumn];
  .db._validateColumnNotExists[tableName; targetColumn];
  .db._validateColumnName targetColumn;

  tableType:.db.getTableType tableName;
  $[tableType=`Normal;
    ![tableName; (); 0b; enlist[targetColumn]!enlist[sourceColumn]];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .db._copyColumn[tablePath; sourceColumn; targetColumn];
    ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .db.getPartitions[];
      .db._copyColumn[; sourceColumn; targetColumn] each tablePaths;
    ]
   ];

  tableName
 };

// @kind function
// @overview Apply a function to a column.
// @param tableName {symbol} A table by name.
// @param column {symbol} New column to be added.
// @param function {function} Function to be applied.
// @return {symbol} The table by name.
// @throws {ColumnNotFoundError: [*]} If `column` doesn't exist.
.db.applyToColumn:{[tableName;column;function]
  .db._validateColumnExists[tableName; column];

  tableType:.db.getTableType tableName;
  $[tableType=`Normal;
    ![tableName; (); 0b; enlist[column]!enlist[function (value tableName)[column]]];
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .db._applyToColumn[tablePath; column; function];
    ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .db.getPartitions[];
      .db._applyToColumn[; column; function] each tablePaths;
    ]
   ];

  tableName
 };

// @kind function
// @overview Cast the datatype of a column.
// @param tableName {symbol} A table by name.
// @param column {symbol} New column to be added.
// @param newType {symbol | char} Name or char code of the new type.
// @return {symbol} The table by name.
// @throws {ColumnNotFoundError: [*]} If `column` doesn't exist.
.db.castColumn:{[tableName;column;newType]
  .db.applyToColumn[tableName; column; newType$]
 };

// @kind function
// @overview Add attribute to a column.
// @param tableName {symbol} A table by name.
// @param column {symbol} A column of the table.
// @param newAttr {symbol} Attribute to be added to the column.
// @return {symbol} The table by name.
// @throws {ColumnNotFoundError: [*]} If `column` doesn't exist.
.db.addAttr:{[tableName;column;newAttr]
  .db.applyToColumn[tableName; column; newAttr#]
 };

// @kind function
// @overview Remove attribute from a column.
// @param tableName {symbol} A table by name.
// @param column {symbol} A column of the table.
// @return {symbol} The table by name.
// @throws {ColumnNotFoundError: [*]} If `column` doesn't exist.
.db.removeAttr:{[tableName;column]
  .db.addAttr[tableName; column; `]
 };

// @kind function
// @overview Fix table based on a good partition. See `.db._fixTable` for fixable issues.
// @param tableName {symbol} A table by name.
// @param refPartition {date | month | int} A partition to which the other partitions refer.
// @return {symbol} The table by name.
// @throws {TableTypeError: not a partitioned table [*]} If the table is not a partitioned table.
// @see .db._fixTable
.db.fixTable:{[tableName;refPartition]
  if[not tableName in .db.getPartitionedTables[]; '"TableTypeError: not a partitioned table [",string[tableName],"]"];
  tablePath:.Q.par[`:.; refPartition; tableName];
  refColumns:.db._getColumns tablePath;
  defaultValues:.db._defaultValue[tablePath;] each refColumns;
  tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .db.getPartitions[] except refPartition;
  .db._fixTable[; refColumns!defaultValues] each tablePaths;
  tableName
 };

// @kind function
// @overview Fill all tables missing in some partitions, using the most recent partition as a template.
// See [`.Q.chk`](https://code.kx.com/q/ref/dotq/#qchk-fill-hdb).
// @return {*[]} Partitions that are filled with missing tables.
// @throws {TableTypeError: not a partitioned table [*]} If the table is not a partitioned table.
.db.fillTables:{
  .Q.chk[`:.]
 };

// @kind function
// @overview Check if a column exists in a table. For splayed tables, column existence requires that the column
// appears in `.d` file and its data file exists. For partitioned table, it requires the condition holds for all
// partitions.
// @param tableName {symbol} A table by name.
// @param column {symbol} A column name.
// @return {boolean} `1b` if the column exists in the table; `0b` otherwise.
.db.columnExists:{[tableName;column]
  tableType:.db.getTableType tableName;
  $[tableType=`Normal;
    column in cols tableName;
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .db._columnExists[tablePath; column]
    ];
    // tableType=`Partitioned
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .db.getPartitions[];
      // Can make the following part simpler by `all .db._columnExists[...]` at the cost of performance, due to inability
      // to return early
      partitionCount:count tablePaths;
      i:0;
      while[i<partitionCount;
            if[not .db._columnExists[tablePaths[i]; column]; :0b];
            i+:1
           ];
      1b
    ]
   ]
 };

/////////////////////////////////////////////
// private functions
/////////////////////////////////////////////

// @kind function
// @overview Validate column name.
// @param columnName {symbol} A column name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
.db._validateColumnName:{[columnName]
  if[(columnName in `i,.Q.res,key `.q) or columnName<>.Q.id columnName;
     '"NameError: invalid column name [",string[columnName],"]"]
 };

// @kind function
// @overview Validate that a column exists, including header and data.
// @param tableName {symbol} A table by name.
// @param column {symbol} A column name.
// @throws {ColumnNotFoundError: [*]} If the column doesn't exist.
.db._validateColumnExists:{[tableName;column]
  if[not .db.columnExists[tableName; column]; '"ColumnNotFoundError: [",string[column],"]"];
 };

// @kind function
// @overview Validate that a column doesn't exist, either header or data or neither.
// @param tableName {symbol} A table by name.
// @param column {symbol} A column name.
// @throws {ColumnExistsError: [*]} If the column exists.
.db._validateColumnNotExists:{[tableName;column]
  if[.db.columnExists[tableName; column]; '"ColumnExistsError: [",string[column],"]"];
 };

// @kind function
// @overview Locate partitioned or segmented table.
// @param tableName {symbol} A table by name.
// @return {symbol} Paths of the table.
.db._locateTable:{[tableName]
  partitions:.db.getPartitions[];
  .Q.par[`:.; ; tableName] each partitions
 };

// @kind function
// @overview Enumerate a value against sym.
// @param val {*} A value.
// @return {enum} Enumerated value against sym if the value is a symbol or a symbol vector; otherwise the same value as-is.
.db._enumerate:{[val]
  if[11<>abs type val; :val];
  .Q.dd[`:.; `sym]?val
 };

// @kind function
// @overview Add a table to a path.
// @param tablePath {hsym} Path to a table in a partition.
// @param data {table} Table data.
// @return {hsym} The path to the table in the partition.
.db._addTable:{[tablePath;data]
  @[tablePath; `; :; .Q.en[`:.; data]];
  tablePath
 };

// @kind function
// @overview Rename a table in a particular partition.
// @param tablePath {hsym} Path to a table in a partition.
// @param newName {hsym} New table name.
// @return {hsym} Path to the renamed table in the partition.
.db._renameTable:{[tablePath;newName]
  newTablePath:.Q.dd[first[` vs tablePath]; newName];
  .os.move[tablePath; newTablePath];
  newTablePath
 };

// @kind function
// @overview Add a column to a table specified by a path, using a default value unless
// a length- and type-compliant column data file exists.
// @param tablePath {hsym} Path to a table in a partition.
// @param column {symbol} New column to be added.
// @param defaultValue {*} Value to be set on the new column.
// @return {hsym} The path to the table in the partition.
.db._addColumn:{[tablePath;column;defaultValue]
  allColumns:.db._getColumns tablePath;
  countInPath:count get .Q.dd[tablePath; first allColumns];
  columnPath:.Q.dd[tablePath; column];

  // if the column file exists and it's type- and length-compliant, use it as-is;
  // otherwise create the file using defaultValue
  $[.os.path.isFile columnPath;
    if[not (count[tablePath column]=countInPath) and (type[defaultValue]=type[.db._defaultValue[tablePath; column]]);
       .[.Q.dd[tablePath; column]; (); :; countInPath#defaultValue]
      ];
    .[.Q.dd[tablePath; column]; (); :; countInPath#defaultValue]
   ];
  @[tablePath; `.d; :; distinct allColumns,column];

  tablePath
 };

// @kind function
// @overview Delete a column of a table and its data in a particular partition.
// @param tablePath {hsym} Path to a table in a partition.
// @param column {symbol} A column to be deleted.
// @return {hsym} The path to the table in the partition.
.db._deleteColumn:{[tablePath;column]
  columnPath:.Q.dd[tablePath; column];
  .db._deleteColumnData columnPath;
  .db._deleteColumnHeader[tablePath; column];
  tablePath
 };

// @kind function
// @overview Delete a column header of a table in a particular partition.
// @param tablePath {hsym} Path to a table in a partition.
// @param column {symbol} A column to be deleted.
// @return {hsym} The path to the table in the partition.
.db._deleteColumnHeader:{[tablePath;column]
  allColumns:.db._getColumns tablePath;
  @[tablePath; `.d; :; allColumns except column];
  tablePath
 };

// @kind function
// @overview Delete a column on disk.
// @param columnPath {symbol} A file symbol representing an existing column.
.db._deleteColumnData:{[columnPath]
  if[.os.path.isFile columnPath;
     .os.remove columnPath];
  if[.os.path.isFile dataFile:`$string[columnPath],"#";
     .os.remove dataFile];
  if[.os.path.isFile dataFile:`$string[columnPath],"##";
     .os.remove dataFile];
 };

// @kind function
// @overview Rename column(s) of a table in a particular partition.
// @param tablePath {hsym} Path to a table in a partition.
// @param nameDict {dict} A dictionary from old name(s) to new name(s).
// @return {hsym} The path to the table in the partition.
.db._renameColumns:{[tablePath;nameDict]
  renameOneColumn:.db_renameOneColumn[tablePath; ;];
  renameOneColumn'[key nameDict; value nameDict];
  tablePath
 };

// @kind function
// @overview Rename a column of a table in a particular partition.
// @param tablePath {hsym} Path to a table in a partition.
// @param oldName {symbol} A column of the table.
// @param newName {symbol} New column name.
// @return {hsym} The path to the table in the partition.
.db_renameOneColumn:{[tablePath;oldName;newName]
  allColumns:.db._getColumns tablePath;

  if[(not oldName in allColumns) or (newName in allColumns); :tablePath];

  oldColumnPath:.Q.dd[tablePath; oldName];
  newColumnPath:.Q.dd[tablePath; newName];
  .db._renameColumnOnDisk[oldColumnPath; newColumnPath];

  newColumns:@[allColumns; first where allColumns=oldName; :; newName];
  @[tablePath; `.d; :; newColumns];
  tablePath
 };

// @kind function
// @overview Copy an existing column to a new column in a particular partition.
// @param tablePath {hsym} Path to a table in a partition.
// @param sourceColumn {symbol} Source column.
// @param targetColumn {symbol} Target column.
// @return {hsym} The path to the table in the partition.
.db._copyColumn:{[tablePath;sourceColumn;targetColumn]
  sourceColumnPath:.Q.dd[tablePath; sourceColumn];
  targetColumnPath:.Q.dd[tablePath; targetColumn];
  .db._copyColumnOnDisk[sourceColumnPath; targetColumnPath];
  @[tablePath; `.d; ,; targetColumn];
  tablePath
 };

// @kind function
// @overview Get all columns of an on-disk table.
// @param tablePath {hsym} Path to a splayed/partitioned table.
// @return {symbol[]} Columns of the table.
.db._getColumns:{[tablePath]
  get .Q.dd[tablePath; `.d]
 };

// @kind function
// @overview Apply a function to a column of a table in a particular partition.
// @param tablePath {hsym} Path to a table in a partition.
// @param column {symbol} A column of the table.
// @param function {function} Function to be applied to the column.
// @return {hsym} The path to the table in the partition.
.db._applyToColumn:{[tablePath;column;function]
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
// @overview Fix a table in a partition based on a mapping between columns and their default values. Fixable issues include:
//   - create `.d` file if missing
//   - add missing columns to `.d` file
//   - add missing data files to disk
//   - remove excessive columns from `.d` file but leave data files untouched
//   - put columns in the right order
// @param tablePath {hsym} Path to a table in a partition.
// @param columnDefaults {dict} A mapping between columns and their default values.
// @return {hsym} The path to the table in the partition.
.db._fixTable:{[tablePath;columnDefaults]
  filesInPartition:.os.listDir tablePath;
  addColumnProjection:.db._addColumn[tablePath; ;];
  expectedColumns:key columnDefaults;

  if[not `.d in filesInPartition; .Q.dd[tablePath; `.d] set expectedColumns];

  // add missing columns
  allColumns:.db._getColumns tablePath;
  if[count missingColumns:expectedColumns except allColumns;
     addColumnProjection'[missingColumns; columnDefaults missingColumns]
    ];

  // add missing data files
  allColumns:.db._getColumns tablePath;
  if[count missingDataColumns:allColumns except filesInPartition;
     addColumnProjection'[missingDataColumns; columnDefaults missingDataColumns]];

  // remove excessive columns
  allColumns:.db._getColumns tablePath;
  if[count excessiveColumns:allColumns except expectedColumns;
     .db._deleteColumnHeader[tablePath; ] each excessiveColumns;];

  // fix column order
  allColumns:.db._getColumns tablePath;
  if[not allColumns~expectedColumns;
    .db._reorderColumns[tablePath; expectedColumns]];

  tablePath
 };

// @kind function
// @overview Reorder columns of a table in a partition with specified first columns.
// @param tablePath {hsym} Path to a table in a partition.
// @param firstColumns {dict} First columns after reordering.
// @return {hsym} The path to the table in the partition.
.db._reorderColumns:{[tablePath;firstColumns]
  allColumns:.db._getColumns tablePath;
  @[tablePath; `.d; :; firstColumns,allColumns except firstColumns];
  tablePath
 };

// @kind function
// @overview Check if a column exists in a table in a partition. A column exists if it's listed in .d file and
// there is a file of the same name in the table path.
// @param tablePath {hsym} Path to a table in a partition.
// @param column {symbol} A column name.
// @return {boolean} `1b` if the column exists in the table in a partition; `0b` otherwise.
.db._columnExists:{[tablePath;column]
  allColumns:.db._getColumns tablePath;
  if[not column in allColumns; :0b];
  columnPath:.Q.dd[tablePath; column];
  .os.path.isFile columnPath
 };

// @kind function
// @overview Get default value based on a path to a partitioned table and a column. The default value is type-specific
// null if it's a simple column, an empty typed list if it's a compound column, or an empty general list.
// @param tablePath {symbol} A file symbol to a partitioned table.
// @param column {symbol} A column of the table.
// @return {*} Default value of the column.
.db._defaultValue:{[tablePath;column]
  columnValue:tablePath column;
  columnType:.Q.ty columnValue;
  $[columnType in .Q.a; first 0#columnValue;
    columnType in .Q.A; lower[columnType]$();
    ()]
 };

// @kind function
// @overview Copy a column on disk.
// @param oldColumnPath {symbol} A file symbol representing an existing column.
// @param newColumnPath {symbol} A file symbol representing a new column.
.db._copyColumnOnDisk:{[oldColumnPath;newColumnPath]
  if[.os.path.isFile newColumnPath;
     .db._renameColumnOnDisk[newColumnPath; hsym `$string[newColumnPath],"_",.qdate.print["%Y%m%d_%H%M%S"; .z.d]]];
  .os.copy[oldColumnPath; newColumnPath];
  if[.os.path.isFile dataFile:`$string[oldColumnPath],"#";
     .os.copy[dataFile; `$string[newColumnPath],"#"]];
  if[.os.path.isFile dataFile:`$string[oldColumnPath],"##";
     .os.copy[dataFile; `$string[newColumnPath],"##"]];
 };

// @kind function
// @overview Rename a column on disk.
// @param oldColumnPath {symbol} A file symbol representing an existing column.
// @param newColumnPath {symbol} A file symbol representing a new column.
.db._renameColumnOnDisk:{[oldColumnPath;newColumnPath]
  if[.os.path.isFile newColumnPath;
     .db._renameColumnOnDisk[newColumnPath; `$string[newColumnPath],"_",.qdate.print["%Y%m%d_%H%M%S"; .z.d]]];
  .os.move[oldColumnPath; newColumnPath];
  if[.os.path.isFile dataFile:`$string[oldColumnPath],"#";
     .os.move[dataFile; `$string[newColumnPath],"#"]];
  if[.os.path.isFile dataFile:`$string[oldColumnPath],"##";
     .os.move[dataFile; `$string[newColumnPath],"##"]];
 };
