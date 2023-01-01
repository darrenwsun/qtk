

## .qtk.db._getPartitionDirectories **_(private)_**

Get all partition directories of a partitioned database.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dbDir|hsym|DB directory of the partitioned database.|

**Returns:**

|Type|Description|
|---|---|
|string[]|Partition directories, or an empty general list if the database is not a partitioned database.|

**Throws:**

|Type|Description|
|---|---|
|FileNotFoundError|If the directory doesn't exist.|
|NotADirectoryError|If the input argument is not a directory.|

## .qtk.db._getSegmentPaths **_(private)_**

Get segment paths of a segmented database.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dbDir|hsym|DB directory.|

**Returns:**

|Type|Description|
|---|---|
|hsym[]|Segment paths of the database, or an empty symbol list  if the database is not a segmented database.|

**Throws:**

|Type|Description|
|---|---|
|FileNotFoundError|If the directory doesn't exist.|
|NotADirectoryError|If the input argument is not a directory.|

## .qtk.db.fillTables

Fill all tables missing in some partitions, using the most recent partition as a template.
A rename of [`.Q.chk`](https://code.kx.com/q/ref/dotq/#qchk-fill-hdb).

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dbDir|hsym|Database directory.|

**Returns:**

|Type|Description|
|---|---|
|any[]|Partitions that are filled with missing tables.|

## .qtk.db.getCurrentPartitionField

Get partition field of the current database.

See also [.Q.pf](https://code.kx.com/q/ref/dotq/#qpf-partition-field).

**Returns:**

|Type|Description|
|---|---|
|symbol|Partition field of the database, either of `` `date`month`year`int ``, or an empty symbol  if the database is not a partitioned database.|

## .qtk.db.getCurrentPartitions

Get all partitions.

See also [.Q.PV](https://code.kx.com/q/ref/dotq/#qpv-partition-values).

**Returns:**

|Type|Description|
|---|---|
|date[] \| month[] \| int[] \| ()|Partitions of the database, or an empty general list  if the database is not a partitioned database.|

**See Also:** [ .qtk.db.getModifiedPartitions ]( qtk_db.md#qtkdbgetmodifiedpartitions )

## .qtk.db.getModifiedPartitions

Get all partitions, subject to modification by [`.Q.view`](https://code.kx.com/q/ref/dotq/#qview-subview).

See also [.Q.pv](https://code.kx.com/q/ref/dotq/#qpv-modified-partition-values).

**Returns:**

|Type|Description|
|---|---|
|date[] \| month[] \| int[] \| ()|Partitions of the database subject to modification by `.Q.view`,  or an empty general list if the database is not a partitioned database.|

**See Also:** [ .qtk.db.getCurrentPartitions ]( qtk_db.md#qtkdbgetcurrentpartitions )

## .qtk.db.getPartitionField

Get partition field of a database under a directory.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dbDir|||

**Returns:**

|Type|Description|
|---|---|
|symbol|Partition field of the database, either of `` `date`month`year`int ``, or an empty symbol  if the database is not a partitioned database.|

## .qtk.db.getPartitionedTables

Get partitioned tables.

**Returns:**

|Type|Description|
|---|---|
|symbol[]|Partitioned tables of the database, or empty symbol vector if it's not a partitioned database.|

## .qtk.db.getPartitions **_(private)_**

Get all partitions of a database.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dbDir|hsym|DB directory.|

**Returns:**

|Type|Description|
|---|---|
|date[] \| month[] \| int[] \| ()|Partitions of the database, or an empty general list  if the database is not a partitioned database.|

**Throws:**

|Type|Description|
|---|---|
|FileNotFoundError|If the directory doesn't exist.|
|NotADirectoryError|If the input argument is not a directory.|

## .qtk.db.getSegments

Get all segments.

**Returns:**

|Type|Description|
|---|---|
|hsym[] \| ()|Segments of the database, or an empty general list.  if the database is not a partitioned database.|

## .qtk.db.load

Load database in a given directory.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dir|string \| hsym|Directory.|

## .qtk.db.partitionsPerSegment

Partitions per segment.

**Returns:**

|Type|Description|
|---|---|
|dict|A dictionary from segments to partitions in each segment. It's empty if the database doesn't load  any segment.|

## .qtk.db.reload

Reload current database.

## .qtk.db.rowCountPerPartition

Row count of a table per partition.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|tableName|symbol|A partitioned table by name.|

**Returns:**

|Type|Description|
|---|---|
|dict|A dictionary from partitions to row count of the table in each partition.|

**Throws:**

|Type|Description|
|---|---|
|NotAPartitionedTableError|If the table is not a partitioned table.|

## .qtk.db.rowCountPerTablePerPartition

Row count of each partitioned table per partition.

**Returns:**

|Type|Description|
|---|---|
|dict|A table keyed by partition and each column is row count of a partitioned table in each partition.|

**Throws:**

|Type|Description|
|---|---|
|RuntimeError: no partition|If there is no partition.|

## .qtk.db.saveTableToPartition

Save table to a partition.
See [`.Q.dpft`](https://code.kx.com/q/ref/dotq/#qdpft-save-table).

**Parameters:**

|Name|Type|Description|
|---|---|---|
|dir|hsym|A directory handle.|
|partition|date \| month \| int|A partition.|
|tableName|symbol|Table name.|
|tableData|table|A table of data.|
|options|dict|Saving options.    - enum: a single domain for all symbol columns, or a dictionary between column names and their respective domains where the default domain is sym|
|options.enum|dict \| symbol||

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table in the partition.|

**Throws:**

|Type|Description|
|---|---|
|SchemaError: mismatch between actual columns [*] and expected ones [*]|If column names in the data table    don't match those in the on-disk table (if exists).|
|SchemaError: mismatch between actual types [*] and expected ones [*]|If column types in the data table    don't match those in the on-disk table (if exists).|
