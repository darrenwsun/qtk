
// @kind function
// @subcategory db
// @overview Get all partitions of current database.
// It's similar to [.Q.PV](https://code.kx.com/q/ref/dotq/#qpv-partition-values) but will return an empty list if
// the database is not partitioned.
// @return {date[] | month[] | int[] | ()} Partitions of the database, or an empty list
// if the database is not a partitioned database.
// @see .qtk.db.getPartitions
// @see .qtk.db.this.getModifiedPartitions
.qtk.db.this.getPartitions:{
  @[value; `.Q.PV; ()]
 };

// @kind function
// @subcategory db
// @overview Get all partitions of current database, subject to modification by [`.Q.view`](https://code.kx.com/q/ref/dotq/#qview-subview).
// It's similar to [.Q.pv](https://code.kx.com/q/ref/dotq/#qpv-modified-partition-values) but will return an empty list
// if the database is not partitioned.
// @return {date[] | month[] | int[] | ()} Partitions of the database subject to modification by `.Q.view`,
// or an empty list if the database is not partitioned.
// @see .qtk.db.this.getPartitions
.qtk.db.this.getModifiedPartitions:{
  @[value; `.Q.pv; ()]
 };

// @kind function
// @subcategory db
// @overview Get partition field of the current database.
// It's similar to [.Q.pf](https://code.kx.com/q/ref/dotq/#qpf-partition-field) but will return a null symbol if
// the database is not partitioned.
// @return {symbol} Partition field of the database, either of ``#!q `date`month`year`int ``, or a null symbol
// if the database is not a partitioned database.
// @see .qtk.db.getPartitionField
.qtk.db.this.getPartitionField:{
  @[value; `.Q.pf; `]
 };

// @kind function
// @subcategory db
// @overview Get partitioned tables of the current database.
// It's similar to [.Q.pt](https://code.kx.com/q/ref/dotq/#qpt-partitioned-tables) but will return an empty symbol vector
// if the database is not partitioned.
// @return {symbol[]} Partitioned tables of the database, or empty symbol vector if the database is not a partitioned database.
.qtk.db.this.getPartitionedTables:{
  @[value; `.Q.pt; enlist `]
 };

// @kind function
// @subcategory db
// @overview Get all segments.
// It's similar to [.Q.P](https://code.kx.com/q/ref/dotq/#qp-segments) but will return an empty list
// if the database is not partitioned.
// @return {hsym[] | ()} Segments of the database, or an empty list
// if the database is not a partitioned database.
.qtk.db.this.getSegments:{
  @[value; `.Q.P; ()]
 };

// @kind function
// @subcategory db
// @overview Partitions per segment.
// @return {dict} A dictionary from segments to partitions in each segment. It's empty if the database doesn't contain
// any segment.
.qtk.db.this.getPartitionsPerSegment:{
  .qtk.db.this.getSegments[]!@[value; `.Q.D; ()]
 };
