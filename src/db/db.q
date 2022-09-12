
// @kind function
// @overview Get all partitions.
// @return {date[] | month[] | int[]} Partitions of the database.
// @throws {RuntimeError: no partition} If it's not a partitioned or segmented database.
.db.getPartitions:{
  @[value; `.Q.PV; {' "RuntimeError: no partition"}]
 };

// @kind function
// @overview Get all partitions, subject to modification by .Q.view.
// @return {date[] | month[] | int[]} Partitions of the database, subject to modification by .Q.view.
// @throws {RuntimeError: no partition} If it's not a partitioned or segmented database.
.db.getModifiedPartitions:{
  @[value; `.Q.pv; {' "RuntimeError: no partition"}]
 };

// @kind function
// @overview Get partition field.
// @return {symbol} Partition fields of the database.
// @throws {RuntimeError: no partition} If it's not a partitioned or segmented database.
.db.getPartitionField:{
  @[value; `.Q.pf; {' "RuntimeError: no partition"}]
 };

// @kind function
// @overview Get partitioned tables.
// @return {symbol[]} Partitioned tables of the database.
// @throws {RuntimeError: no partition} If it's not a partitioned or segmented database.
.db.getPartitionedTables:{
  @[value; `.Q.pt; {' "RuntimeError: no partition"}]
 };

// @kind function
// @overview Count table per partition.
// @param table {table} A partitioned table.
// @return {long[]} Counts of the partitioned table per partition.
.db.countTablePerPartition:{[table]
  @[.Q.cn; table; { ' "RuntimeError: not a partitioned table" }]
 };

// @kind function
// @overview Count tables per partition.
// @return {dict} A dictionary between tables and their counts per partition.
.db.countTablesPerPartition:{
  partitionedTables:.db.getPartitionedTables[];
  .db.countTablePerPartition each get each partitionedTables;
  @[value; `.Q.pn; { ' "RuntimeError: no partition" }]
 };

// @kind function
// @overview Add a column to a table.
// @param tableName {symbol} A table by name.
// @param column {symbol} New column to be added.
// @param defaultValue {*} Value to be set on the new column.
// @return {symbol} The table by name.
// @throws {NameError: invalid column name [*]} If the column name is not valid.
.db.addColumn:{[tableName;column;defaultValue]
  if[not .db._validateColumnName column; ' "NameError: invalid column name [",string[column],"]"];
  if[not tableName in .db.getPartitionedTables[];
    if[-11h=type defaultValue; defaultValue:enlist defaultValue];   // enlist singleton symbol value
    ![tableName; (); 0b; enlist[column]!enlist[defaultValue]];
    :tableName
   ];
  .db._addColumn[; tableName; column; .db._enumerate defaultValue] each .db.getPartitions[];
 };


// @kind function
// @overview Validate column name.
// @param columnName {symbol} A column name.
// @return {boolean} `1b` if the column name is valid; `0b` otherwise.
.db._validateColumnName:{[name]
  (not name in `i,.Q.res,key`.q) and name=.Q.id name
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
  .Q.dd[`:.;`sym]?val
 };

// @kind function
// @overview Add a column to a table in a particular partition.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @param column {symbol} New column to be added.
// @param defaultValue {*} Value to be set on the new column.
// @return {symbol} The path to the table in the partition.
.db._addColumn:{[partition;tableName;column;defaultValue]
  allColumns:.db._getColumns[partition; tableName];
  if[column in allColumns; :tableName];
  path:.Q.par[`:.;partition;tableName];
  countInPath:count get .Q.dd[path; first allColumns];
  .[.Q.dd[path; column]; (); :; countInPath#defaultValue];
  @[path; `.d; ,; column];
  path
 };

// @kind function
// @overview Get all columns of a table in a particular partition.
// @param partition {date | month | int} A partition.
// @param tableName {symbol} A table by name.
// @return {symbol[]} Columns of the table in the partition.
.db._getColumns:{[partition;tableName]
  get .Q.dd[.Q.par[`:.;partition;tableName]; `.d]
 };
