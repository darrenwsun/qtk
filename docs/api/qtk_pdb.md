

## .qtk.pdb.fillTables

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

## .qtk.pdb.getPartitionField

Get partition field of a database under a directory.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dbDir|hsym|A database directory.|

**Returns:**

|Type|Description|
|---|---|
|symbol|Partition field of the database, either of ``#!q `date`month`year`int ``, or an empty symbol  if the database is not a partitioned database.|

**See Also:** [ .qtk.pdb.this.getPartitionField ]( qtk_pdb.md#qtkpdbthisgetpartitionfield )

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["pdb";`qtk];
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:`:/tmp/qtk/db/getPartitionField`date`PartitionedTable;
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 tabRef[1]~.qtk.pdb.getPartitionField first tabRef
```

## .qtk.pdb.getPartitions

Get all partitions of a database.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dbDir|hsym|DB directory.|

**Returns:**

|Type|Description|
|---|---|
|date[] \| month[] \| int[] \| ()|Partitions of the database, or an empty list  if the database is not a partitioned database.|

**Throws:**

|Type|Description|
|---|---|
|FileNotFoundError|If `dbDir` doesn't exist.|
|NotADirectoryError|If `dbDir` doesn't point to a directory.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["pdb";`qtk];
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:`:/tmp/qtk/db/getPartitions`date`PartitionedTable;
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 2022.01.01 2022.01.02~.qtk.pdb.getPartitions first tabRef
```

## .qtk.pdb.saveToPartition

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
|SchemaError|If column names/types in the data table don't match those in the on-disk table (if exists).|

## .qtk.pdb.this.countAllPerPartition

Count rows of all tables per partition.

**Returns:**

|Type|Description|
|---|---|
|dict|A table keyed by partition and each column is row count of a partitioned table in each partition.|

**Throws:**

|Type|Description|
|---|---|
|RuntimeError: no partition|If there is no partition.|

## .qtk.pdb.this.countPerPartition

Count rows of a table per partition, subject to modification by [`.Q.view`](https://code.kx.com/q/ref/dotq/#qview-subview).

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

## .qtk.pdb.this.getModifiedPartitions

Get all partitions of current database, subject to modification by [`.Q.view`](https://code.kx.com/q/ref/dotq/#qview-subview).
It's similar to [.Q.pv](https://code.kx.com/q/ref/dotq/#qpv-modified-partition-values) but will return an empty list
if the database is not partitioned.

**Returns:**

|Type|Description|
|---|---|
|date[] \| month[] \| int[] \| ()|Partitions of the database subject to modification by `.Q.view`,  or an empty list if the database is not partitioned.|

**See Also:** [ .qtk.pdb.this.getPartitions ]( qtk_pdb.md#qtkpdbthisgetpartitions )

## .qtk.pdb.this.getPartitionField

Get partition field of the current database.
It's similar to [.Q.pf](https://code.kx.com/q/ref/dotq/#qpf-partition-field) but will return a null symbol if
the database is not partitioned.

**Returns:**

|Type|Description|
|---|---|
|symbol|Partition field of the database, either of ``#!q `date`month`year`int ``, or a null symbol  if the database is not a partitioned database.|

**See Also:** [ .qtk.pdb.getPartitionField ]( qtk_pdb.md#qtkpdbgetpartitionfield )

## .qtk.pdb.this.getPartitionedTables

Get partitioned tables of the current database.
It's similar to [.Q.pt](https://code.kx.com/q/ref/dotq/#qpt-partitioned-tables) but will return an empty symbol vector
if the database is not partitioned.

**Returns:**

|Type|Description|
|---|---|
|symbol[]|Partitioned tables of the database, or empty symbol vector if the database is not a partitioned database.|

## .qtk.pdb.this.getPartitions

Get all partitions of current database.
It's similar to [.Q.PV](https://code.kx.com/q/ref/dotq/#qpv-partition-values) but will return an empty list if
the database is not partitioned.

**Returns:**

|Type|Description|
|---|---|
|date[] \| month[] \| int[] \| ()|Partitions of the database, or an empty list  if the database is not a partitioned database.|

**See Also:** [ .qtk.pdb.getPartitions ]( qtk_pdb.md#qtkpdbgetpartitions ) [ .qtk.pdb.this.getModifiedPartitions ]( qtk_pdb.md#qtkpdbthisgetmodifiedpartitions )

## .qtk.pdb.this.getPartitionsPerSegment

Partitions per segment.

**Returns:**

|Type|Description|
|---|---|
|dict|A dictionary from segments to partitions in each segment. It's empty if the database doesn't contain  any segment.|

## .qtk.pdb.this.getSegments

Get all segments.
It's similar to [.Q.P](https://code.kx.com/q/ref/dotq/#qp-segments) but will return an empty list
if the database is not partitioned.

**Returns:**

|Type|Description|
|---|---|
|hsym[] \| ()|Segments of the database, or an empty list  if the database is not a partitioned database.|
