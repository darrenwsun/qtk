
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
// @overview Count table per partition.
// @param table {symbol} A partitioned table by name.
// @return {long[]} Counts of the partitioned table per partition.
.db.countTablePerPartition:{[table]
  @[.Q.cn; table; { ' "RuntimeError: not a partitioned table" }]
 };
