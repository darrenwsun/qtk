import "os";

// @kind function
// @overview Get all partitions.
// @return {date[] | month[] | int[]} Partitions of the database.
// @throws {RuntimeError: no partition} If it's not a partitioned or segmented database.
.db.getPartitions:{
  @[value; `.Q.PV; {'"RuntimeError: no partition"}]
 };

// @kind function
// @overview Get all partitions, subject to modification by .Q.view.
// @return {date[] | month[] | int[]} Partitions of the database, subject to modification by .Q.view.
// @throws {RuntimeError: no partition} If it's not a partitioned or segmented database.
.db.getModifiedPartitions:{
  @[value; `.Q.pv; {'"RuntimeError: no partition"}]
 };

// @kind function
// @overview Get partition field.
// @return {symbol} Partition fields of the database.
// @throws {RuntimeError: no partition} If it's not a partitioned or segmented database.
.db.getPartitionField:{
  @[value; `.Q.pf; {'"RuntimeError: no partition"}]
 };

// @kind function
// @overview Get partitioned tables.
// @return {symbol[]} Partitioned tables of the database.
// @throws {RuntimeError: no partition} If it's not a partitioned or segmented database.
.db.getPartitionedTables:{
  @[value; `.Q.pt; {'"RuntimeError: no partition"}]
 };

// @kind function
// @overview Count table per partition.
// @param table {table} A partitioned table.
// @return {long[]} Counts of the partitioned table per partition.
.db.countTablePerPartition:{[table]
  @[.Q.cn; table; {'"RuntimeError: not a partitioned table"}]
 };

// @kind function
// @overview Count tables per partition.
// @return {dict} A dictionary between tables and their counts per partition.
.db.countTablesPerPartition:{
  partitionedTables:.db.getPartitionedTables[];
  .db.countTablePerPartition each get each partitionedTables;
  @[value; `.Q.pn; {'"RuntimeError: no partition"}]
 };

// @kind function
// @overview Add a column to a table.
// @param tableName {symbol} A table by name.
// @param column {symbol} New column to be added.
// @param defaultValue {*} Value to be set on the new column.
// @return {symbol} The table by name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
.db.addColumn:{[tableName;column;defaultValue]
  if[not .db._validateColumnName column; '"NameError: invalid column name [",string[column],"]"];
  if[not tableName in .db.getPartitionedTables[];
     if[-11h=type defaultValue; defaultValue:enlist defaultValue];    // enlist singleton symbol value
     ![tableName; (); 0b; enlist[column]!enlist[defaultValue]];
     :tableName
    ];
  .db._addColumn[; tableName; column; .db._enumerate defaultValue] each .db.getPartitions[];
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
// @overview Copy an existing column to a new column.
// @param tableName {symbol} A table by name.
// @param sourceColumn {symbol} Source column.
// @param targetColumn {symbol} Target column.
// @return {symbol} The table by name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
.db.copyColumn:{[tableName;sourceColumn;targetColumn]
  if[not .db._validateColumnName targetColumn; '"NameError: invalid column name [",string[targetColumn],"]"];
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
// @overview remove attribute from a column.
// @param tableName {symbol} A table by name.
// @param column {symbol} A column of the table.
// @return {symbol} The table by name.
.db.removeAttr:{[tableName;column]
  .db.addAttr[tableName; column; `]
 };

/////////////////////////////////////////////
// private functions
/////////////////////////////////////////////

// @kind function
// @overview Validate column name.
// @param columnName {symbol} A column name.
// @return {boolean} `1b` if the column name is valid; `0b` otherwise.
.db._validateColumnName:{[name]
  (not name in `i,.Q.res,key `.q) and name=.Q.id name
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
// @return {symbol} Paths of the table.
.db._enumerate:{[val]
  if[11<>abs type val; :val];
  .Q.dd[`:.; `sym]?val
 };

// @kind function
// @overview Add a column to a table in a particular partition.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @param column {symbol} New column to be added.
// @param defaultValue {*} Value to be set on the new column.
// @return {symbol} The path to the table in the partition.
.db._addColumn:{[partition;tableName;column;defaultValue]
  path:.Q.par[`:.; partition; tableName];
  allColumns:.db._getColumns[partition; tableName];
  if[column in allColumns; :path];
  countInPath:count get .Q.dd[path; first allColumns];
  .[.Q.dd[path; column]; (); :; countInPath#defaultValue];
  @[path; `.d; ,; column];
  path
 };

// @kind function
// @overview Delete a column of a table in a particular partition.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @param column {symbol} New column to be added.
// @return {symbol} The path to the table in the partition.
.db._deleteColumn:{[partition;tableName;column]
  tablePath:.Q.par[`:.; partition; tableName];
  allColumns:.db._getColumns[partition; tableName];
  if[(not column in allColumns) and (not column in .os.listDir tablePath); :tablePath];
  columnPath:.Q.dd[tablePath; column];
  .os.remove columnPath;
  if[.os.path.isFile dataFile:`$string[columnPath],"#";
    .os.remove dataFile];
  if[.os.path.isFile dataFile:`$string[columnPath],"##";
     .os.remove dataFile];

  @[tablePath; `.d; :; allColumns except column];
  tableName
 };

// @kind function
// @overview Copy an existing column to a new column in a particular partition.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @param sourceColumn {symbol} Source column.
// @param targetColumn {symbol} Target column.
// @return {symbol} The path to the table in the partition.
.db._copyColumn:{[partition;tableName;sourceColumn;targetColumn]
  path:.Q.par[`:.; partition; tableName];
  allColumns:.db._getColumns[partition; tableName];
  if[(not sourceColumn in allColumns) or (targetColumn in allColumns); :path];

  sourceFilePath:.Q.dd[.Q.par[`:.; partition; tableName]; sourceColumn];
  targetFilePath:.Q.dd[.Q.par[`:.; partition; tableName]; targetColumn];
  .os.copy[sourceFilePath; targetFilePath];
  if[.os.path.isFile dataFile:`$string[sourceFilePath],"#";
    .os.copy[dataFile; `$string[targetFilePath],"#"]];
  if[.os.path.isFile dataFile:`$string[sourceFilePath],"##";
     .os.copy[dataFile; `$string[targetFilePath],"##"]];

  @[path; `.d; ,; targetColumn];
  path
 };

// @kind function
// @overview Get all columns of a table in a particular partition.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @return {symbol[]} Columns of the table in the partition.
.db._getColumns:{[partition;tableName]
  get .Q.dd[.Q.par[`:.; partition; tableName]; `.d]
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
  allColumns:.db._getColumns[partition; tableName];
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
