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
// @throws {RuntimeError: not a partitioned table [*]} If the table is not a partitioned table.
.db.rowCountPerPartition:{[tableName]
  rowCounts:@[.Q.cn get@;
    tableName;
    {[msg;tableName]
      '"RuntimeError: not a partitioned table [",string[tableName],"]"
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
// @param prototype {table} Prototype where column names and types of the new table refers to.
// @param tableType {symbol} Normal, Splayed, or Partitioned.
// @return {symbol} The table by name.
// @throws {RuntimeError: invalid table type [*]} If the table type is not valid.
.db.addTable:{[tableName;prototype;tableType]
  $[tableType=`Normal;
    tableName set 0#prototype;
    tableType=`Splayed;
    [
      tablePath:.Q.dd[`:.; tableName];
      .db._addTable[tablePath; .Q.en[`:.; 0#prototype]];
    ];
    tableType=`Partitioned;
    [
      tablePaths:{.Q.par[`:.; x; y]}[; tableName] each .db.getPartitions[];
      .db._addTable[; .Q.en[`:.; 0#prototype]] each tablePaths;
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
  if[not tableName in .db.getPartitionedTables[];
     newName set get tableName;
     ![`.; (); 0b; enlist tableName];
     :tableName
    ];
  .db._renameTable[; tableName; newName] each .db.getPartitions[];
  tableName
 };

// @kind function
// @overview Add a column to a table.
// @param tableName {symbol} A table by name.
// @param column {symbol} New column to be added.
// @param defaultValue {*} Value to be set on the new column.
// @return {symbol} The table by name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
.db.addColumn:{[tableName;column;defaultValue]
  .db._validateColumnName column;
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
  if[not tableName in .db.getPartitionedTables[];
     ![tableName; (); 0b; enlist[column]];
     :tableName
    ];
  .db._deleteColumn[; tableName; column] each .db.getPartitions[];
  tableName
 };

// @kind function
// @overview Rename column(s) from a table.
// @param tableName {symbol} A table by name.
// @param nameDict {dict} A dictionary from old name(s) to new name(s).
// @return {symbol} The table by name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
.db.renameColumns:{[tableName;nameDict]
  .db._validateColumnName each value nameDict;
  if[not tableName in .db.getPartitionedTables[];
     tableName set nameDict xcol get tableName;
     :tableName
    ];
  .db._renameColumns[; tableName; nameDict] each .db.getPartitions[];
  tableName
 };

// @kind function
// @overview Reorder columns of a table.
// @param tableName {symbol} A table by name.
// @param firstColumns {dict} First columns after reordering.
// @return {symbol} The table by name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
.db.reorderColumns:{[tableName;firstColumns]
  if[not tableName in .db.getPartitionedTables[];
     tableName set firstColumns xcols get tableName;
     :tableName
    ];
  .db._reorderColumns[; tableName; firstColumns] each .db.getPartitions[];
  tableName
 };

// @kind function
// @overview Copy an existing column to a new column.
// @param tableName {symbol} A table by name.
// @param sourceColumn {symbol} Source column.
// @param targetColumn {symbol} Target column.
// @return {symbol} The table by name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
.db.copyColumn:{[tableName;sourceColumn;targetColumn]
  .db._validateColumnName targetColumn;
  $[not tableName in .db.getPartitionedTables[];
    ![tableName; (); 0b; enlist[targetColumn]!enlist[sourceColumn]];
    .db._copyColumn[; tableName; sourceColumn; targetColumn] each .db.getPartitions[]
   ];
  tableName
 };

// @kind function
// @overview Apply a function to a column.
// @param tableName {symbol} A table by name.
// @param column {symbol} New column to be added.
// @param function {function} Function to be applied.
// @return {symbol} The table by name.
.db.applyToColumn:{[tableName;column;function]
  if[not tableName in .db.getPartitionedTables[];
     ![tableName; (); 0b; enlist[column]!enlist[function (value tableName)[column]]];
     :tableName
    ];
  .db._applyToColumn[; tableName; column; function] each .db.getPartitions[];
  tableName
 };

// @kind function
// @overview Cast the datatype of a column.
// @param tableName {symbol} A table by name.
// @param column {symbol} New column to be added.
// @param newType {symbol | char} Name or char code of the new type.
// @return {symbol} The table by name.
.db.castColumn:{[tableName;column;newType]
  .db.applyToColumn[tableName; column; newType$]
 };

// @kind function
// @overview Add attribute to a column.
// @param tableName {symbol} A table by name.
// @param column {symbol} A column of the table.
// @param newAttr {symbol} Attribute to be added to the column.
// @return {symbol} The table by name.
.db.addAttr:{[tableName;column;newAttr]
  if[not tableName in .db.getPartitionedTables[];
     ![tableName; (); 0b; enlist[column]!enlist[(#; enlist newAttr; column)]];
     :tableName
    ];
  .db._applyToColumn[; tableName; column; newAttr#] each .db.getPartitions[];
  tableName
 };

// @kind function
// @overview Remove attribute from a column.
// @param tableName {symbol} A table by name.
// @param column {symbol} A column of the table.
// @return {symbol} The table by name.
.db.removeAttr:{[tableName;column]
  .db.addAttr[tableName; column; `]
 };

// @kind function
// @overview Fix table based on a good partition.
// @param tableName {symbol} A table by name.
// @param refPartition {date | month | int} A partition to which the other partitions refer.
// @return {symbol} The table by name.
// @throws {RuntimeError: not a partitioned table [*]} If the table is not a partitioned table.
.db.fixTable:{[tableName;refPartition]
  if[not tableName in .db.getPartitionedTables[]; '"RuntimeError: not a partitioned table [",string[tableName],"]"];
  tablePath:.Q.par[`:.; refPartition; tableName];
  refColumns:.db._getColumns tablePath;
  defaultValues:.db._defaultValue[tablePath;] each refColumns;
  .db._fixTable[; tableName; refColumns!defaultValues] each .db.getPartitions[] except refPartition;
  tableName
 };

/////////////////////////////////////////////
// private functions
/////////////////////////////////////////////

// @kind function
// @overview Validate column name.
// @param columnName {symbol} A column name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
.db._validateColumnName:{[name]
  if[(name in `i,.Q.res,key `.q) or name<>.Q.id name;
     '"NameError: invalid column name [",string[name],"]"]
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
// @param tablePath {hsym} Path to a table.
// @param prototype {table} Prototype where column names and types of the new table refers to.
// @return {symbol} The path to the table in the partition.
.db._addTable:{[tablePath;prototype]
  @[tablePath; `; :; .Q.en[`:.; 0#prototype]];
  tablePath
 };

// @kind function
// @overview Rename a table in a particular partition.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @param newName {symbol} New name of the table.
// @return {symbol} The path to the table in the partition.
.db._renameTable:{[partition;tableName;newName]
  tablePath:.Q.par[`:.; partition; tableName];
  newTablePath:.Q.par[`:.; partition; newName];
  .os.move[tablePath; newTablePath];
  newTablePath
 };

// @kind function
// @overview Add a column to a table specified by a path.
// @param tablePath {hsym} Path to a table.
// @param column {symbol} New column to be added.
// @param defaultValue {*} Value to be set on the new column.
// @return {symbol} The path to the table in the partition.
.db._addColumn:{[tablePath;column;defaultValue]
  allColumns:.db._getColumns tablePath;

  if[column in allColumns; :tablePath];

  countInPath:count get .Q.dd[tablePath; first allColumns];
  columnPath:.Q.dd[tablePath; column];

  // rename the column file if it exists, although the column itself was is not declared in .d file
  if[.os.path.isFile columnPath; .os.move[columnPath; string[columnPath],"_",.qdate.print["%Y%m%d_%H%M%S"; .z.d]]];

  .[.Q.dd[tablePath; column]; (); :; countInPath#defaultValue];
  @[tablePath; `.d; ,; column];

  tablePath
 };

// @kind function
// @overview Delete a column of a table in a particular partition.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @param column {symbol} New column to be added.
// @return {symbol} The path to the table in the partition.
.db._deleteColumn:{[partition;tableName;column]
  tablePath:.Q.par[`:.; partition; tableName];
  allColumns:.db._getColumns tablePath;
  if[(not column in allColumns) and (not column in .os.listDir tablePath); :tablePath];
  columnPath:.Q.dd[tablePath; column];
  .db._deleteColumnOnDisk columnPath;

  @[tablePath; `.d; :; allColumns except column];
  tablePath
 };

// @kind function
// @overview Rename column(s) of a table in a particular partition.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @param nameDict {dict} A dictionary from old name(s) to new name(s).
// @return {symbol} The path to the table in the partition.
.db._renameColumns:{[partition;tableName;nameDict]
  renameOneColumn:.db_renameOneColumn[partition; tableName; ;];
  renameOneColumn'[key nameDict; value nameDict];
 };

// @kind function
// @overview Rename a column of a table in a particular partition.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @param oldName {symbol} A column of the table.
// @param newName {symbol} New column name.
// @return {symbol} The path to the table in the partition.
.db_renameOneColumn:{[partition;tableName;oldName;newName]
  tablePath:.Q.par[`:.; partition; tableName];
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
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @param sourceColumn {symbol} Source column.
// @param targetColumn {symbol} Target column.
// @return {symbol} The path to the table in the partition.
.db._copyColumn:{[partition;tableName;sourceColumn;targetColumn]
  tablePath:.Q.par[`:.; partition; tableName];
  allColumns:.db._getColumns tablePath;
  if[(not sourceColumn in allColumns) or (targetColumn in allColumns); :tablePath];

  sourceColumnPath:.Q.dd[.Q.par[`:.; partition; tableName]; sourceColumn];
  targetColumnPath:.Q.dd[.Q.par[`:.; partition; tableName]; targetColumn];
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
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @param column {symbol} A column of the table.
// @param function {function} Function to be applied to the column.
// @return {symbol} The path to the table in the partition.
.db._applyToColumn:{[partition;tableName;column;function]
  tablePath:.Q.par[`:.; partition; tableName];
  allColumns:.db._getColumns tablePath;
  if[not column in allColumns; :tablePath];  // the column doesn't exist in the current partition, ignore

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
// @overview Fix table in a partition based on a mapping between columns and their default values.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @param columnDefaults {dict} A mapping between columns and their default values.
// @return {symbol} The path to the table in the partition.
.db._fixTable:{[partition;tableName;columnDefaults]
  tablePath:.Q.par[`:.; partition; tableName];
  filesInPartition:.os.listDir tablePath;
  expectedColumns:key columnDefaults;

  if[not `.d in filesInPartition; .Q.dd[tablePath; `.d] set expectedColumns];

  // add missing columns
  allColumns:.db._getColumns tablePath;
  if[count missingColumns:expectedColumns except allColumns;
     addColumnProjection:.db._addColumn[tablePath; ;];
     addColumnProjection'[missingColumns; columnDefaults missingColumns]];

  allColumns:.db._getColumns tablePath;
  if[not allColumns~expectedColumns;
    .db._reorderColumns[partition; tableName; expectedColumns]];
  tablePath
 };

// @kind function
// @overview Reorder columns of a table in a partition using specified first columns.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @param firstColumns {dict} First columns after reordering.
// @return {symbol} The path to the table in the partition.
// @throws {RuntimeError: } The path to the table in the partition.
.db._reorderColumns:{[partition;tableName;firstColumns]
  tablePath:.Q.par[`:.; partition; tableName];
  allColumns:.db._getColumns tablePath;
  if[count extraColumns:firstColumns except allColumns;
     '"RuntimeError: columns [",("," sv string extraColumns),"] not in table [",string[tableName],"]"];
  @[tablePath; `.d; :; firstColumns,allColumns except firstColumns];
  tablePath
 };

// @kind function
// @overview Get default value based on a path to a partitioned table and a column. The default value is type-specific
// null if it's a simple column, an empty typed list if it's a compound column, or an empty general list.
// @param tablePath {symbol} A file symbol to a partitioned table.
// @param column {symbol} A column of the table.
// @return {symbol} The table by name.
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

// @kind function
// @overview Delete a column on disk.
// @param columnPath {symbol} A file symbol representing an existing column.
.db._deleteColumnOnDisk:{[columnPath]
  .os.remove columnPath;
  if[.os.path.isFile dataFile:`$string[columnPath],"#";
     .os.remove dataFile];
  if[.os.path.isFile dataFile:`$string[columnPath],"##";
     .os.remove dataFile];
 };
