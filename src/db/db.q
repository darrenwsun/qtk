
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
