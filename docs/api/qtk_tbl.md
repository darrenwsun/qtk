

## .qtk.db._renameColumnOnDisk **_(private)_**

Rename a column on disk. Column data along with accompanying # and ## files are moved.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|oldPath|hsym|A file symbol representing an existing column.|
|newPath|hsym|A file symbol representing a new column.|

## .qtk.tbl._addColumn **_(private)_**

Add a column to an on-disk table with a given value.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|column|symbol|Name of new column to be added.|
|columnValue|any|Value to be set on the new column. It must be enumerated if it's a symbol or symbol vector.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

## .qtk.tbl._addTable **_(private)_**

Add an on-disk table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|data|table|Table data. Symbol columns must be enumerated and the table is not keyed.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

## .qtk.tbl._apply **_(private)_**

Apply a function to a column of an on-disk table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|dbDir|hsym|DB directory.|
|tablePath|hsym|Path to an on-disk table.|
|column|symbol|A column name of the table.|
|function|fn (any[]) &rarr; any[]|Function to be applied to the column.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

## .qtk.tbl._atSafe **_(private)_**

Get entries at given indices of a partitioned table.
It's similar to [.Q.ind](https://code.kx.com/q/ref/dotq/#qind-partitioned-index) but has the following differences:

- if `indices` are empty, an empty table of conforming schema is returned rather than an empty list.
- if `indices` go out of bound, an empty table of conforming schema is returned rather than raising 'par error

**Parameters:**

|Name|Type|Description|
|---|---|---|
|dbDir|hsym|DB directory.|
|table|table|Partitioned table.|
|indices|int[] \| long[]|Indices to select from.|

**Returns:**

|Type|Description|
|---|---|
|table|Table at the given indices.|

## .qtk.tbl._columnExists **_(private)_**

Check if a column exists in an on-disk table. A column exists if it's listed in `.d` file and
there is a file of the same name in the table path.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|column|symbol|A column name.|

**Returns:**

|Type|Description|
|---|---|
|boolean|`1b` if the column exists in the table; `0b` otherwise.|

## .qtk.tbl._copyColumn **_(private)_**

Copy an existing column of an on-disk table to a new column.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|sourceColumn|symbol|Source column to copy from.|
|targetColumn|symbol|Target column to copy to.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

## .qtk.tbl._count

Count rows of an on-disk table. Only the first column is taken into consideration.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|

**Returns:**

|Type|Description|
|---|---|
|long|Row count of the table.|

## .qtk.tbl._deleteColumn **_(private)_**

Delete a column of an on-disk table and its data.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|column|symbol|A column to be deleted.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

## .qtk.tbl._deleteColumnData **_(private)_**

Delete a column on disk, including accompanying # and ## files (if any).

**Parameter:**

|Name|Type|Description|
|---|---|---|
|columnPath|hsym|Path to a column of an on-disk table.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the column.|

## .qtk.tbl._deleteColumnHeader **_(private)_**

Delete a column header of an on-disk table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|column|symbol|A column to be deleted.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

## .qtk.tbl._deleteRows **_(private)_**

Delete rows of an on-disk table given certain criteria, in a similar format to functional delete.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|criteria|any[]|A list of criteria where matching rows will be deleted, or empty list if it's applied to the whole table.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

## .qtk.tbl._empty **_(private)_**

Return an empty table that matches a given table schema.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|tabMeta|table|Metadata of a table.|

**Returns:**

|Type|Description|
|---|---|
|table|An empty table that matches the metadata.|

## .qtk.tbl._insert **_(private)_**

Insert data into a table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|data|table|Table data. Symbol columns must be enumerated and the table is not keyed.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

## .qtk.tbl._rename **_(private)_**

Rename an on-disk table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|newName|symbol|New table name.|

**Returns:**

|Type|Description|
|---|---|
|hsym|Path to the renamed table.|

## .qtk.tbl._renameColumns **_(private)_**

Rename column(s) of an on-disk table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|nameDict|dict|A dictionary from old name(s) to new name(s).|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

## .qtk.tbl._renameOneColumn **_(private)_**

Rename a column of an on-disk table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|oldName|symbol|A column name of the table.|
|newName|symbol|New column name.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

## .qtk.tbl._reorderColumns **_(private)_**

Reorder columns of an on-disk table with specified first columns.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|firstColumns|dict|First columns after reordering.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

## .qtk.tbl._singleton **_(private)_**

Return a table with a single row that matches a given table schema.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|tabMeta|table|Metadata of a table.|

**Returns:**

|Type|Description|
|---|---|
|table|A table with a single row that matches the metadata.|

## .qtk.tbl._update **_(private)_**

Update values in certain columns of an on-disk table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|dbDir|hsym|DB directory.|
|tablePath|hsym|Path to an on-disk table.|
|criteria|any[]|A list of criteria where the update is applied to, or empty list if it's applied to the whole table.|
|groupings|dict \| 0b|A mapping of grouping columns, or `0b` for no grouping.|
|columns|dict|Mappings from column names to columns/expressions.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

**Throws:**

|Type|Description|
|---|---|
|TypeError \| type|If it's a partial update and the new values don't have the same type as other values.|

## .qtk.tbl._validateTableName **_(private)_**

Validate table name.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|name|symbol|Table name.|

**Throws:**

|Type|Description|
|---|---|
|TableNameError|If the table name is not valid.|

## .qtk.tbl.addColumn

Add a column to a table with a given value.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|
|column|symbol|Name of new column to be added.|
|columnValue|any|Value to be set on the new column.|

**Returns:**

|Type|Description|
|---|---|
|symbol \| hsym \| (hsym; symbol; symbol)|The table reference.|

**Throws:**

|Type|Description|
|---|---|
|ColumnNameError|If `column` is not a valid name.|
|ColumnExistsError|If `column` already exists.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/addColumn; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 tabRef~.qtk.tbl.addColumn[tabRef; `c2; 0n]
```

## .qtk.tbl.apply

Apply a function to a column of a table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|
|column|symbol|Column where the function will be applied.|
|function|fn (any[]) &rarr; any[]|Function to be applied.|

**Returns:**

|Type|Description|
|---|---|
|symbol \| hsym \| (hsym; symbol; symbol)|The table reference.|

**Throws:**

|Type|Description|
|---|---|
|ColumnNotFoundError|If `column` doesn't exist.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/apply; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 tabRef~.qtk.tbl.apply[tabRef; `c1; 2*]
```

## .qtk.tbl.at

Get entries at given indices of a table.
It's similar to [.Q.ind](https://code.kx.com/q/ref/dotq/#qind-partitioned-index) but has the following differences:

- if `indices` are empty, an empty table of conforming schema is returned rather than an empty list.
- if `indices` go out of bound, an empty table of conforming schema is returned rather than raising 'par error

**Parameters:**

|Name|Type|Description|
|---|---|---|
|table|symbol \| hsym \| table|Table name, path or value.|
|indices|int[] \| long[]|Indices to select from.|

**Returns:**

|Type|Description|
|---|---|
|table|Table at the given indices.|

## .qtk.tbl.castColumn

Cast the datatype of a column of a table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|
|column|symbol|Column whose datatype will be casted.|
|newType|symbol \| char|Name or character code of the new data type.|

**Returns:**

|Type|Description|
|---|---|
|symbol \| hsym \| (hsym; symbol; symbol)|The table reference.|

**Throws:**

|Type|Description|
|---|---|
|ColumnNotFoundError|If `column` doesn't exist.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/castColumn; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 tabRef~.qtk.tbl.castColumn[tabRef; `c1; `int]
```

## .qtk.tbl.columnExists

Check if a column exists in a table.
For splayed tables, column existence requires that the column appears in `.d` file and its data file exists.
For partitioned tables, it requires the condition holds for the latest partition.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|table|table \| symbol \| hsym \| (hsym; symbol; symbol)|Table value or reference.|
|column|symbol|Column name.|

**Returns:**

|Type|Description|
|---|---|
|boolean|`1b` if the column exists in the table; `0b` otherwise.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/columnExists; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 .qtk.tbl.columnExists[tabRef;`c1]
```

## .qtk.tbl.copyColumn

Copy an existing column of a table to a new column.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|
|sourceColumn|symbol|Source column to copy from.|
|targetColumn|symbol|Target column to copy to.|

**Returns:**

|Type|Description|
|---|---|
|symbol \| hsym \| (hsym; symbol; symbol)|The table reference.|

**Throws:**

|Type|Description|
|---|---|
|ColumnNotFoundError|If `sourceColumn` doesn't exist.|
|ColumnExistsError|If `targetColumn` exists.|
|ColumnNameError|If name of `targetColumn` is not valid.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/copyColumn; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 .qtk.tbl.copyColumn[tabRef; `c1; `c2];
 .qtk.tbl.columnExists[tabRef; `c2]
```

## .qtk.tbl.count

Count rows of a table.
It's similar to [count](https://code.kx.com/q/ref/count/#count) but supports all table types.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|table|table \| symbol \| hsym \| (hsym; symbol; symbol)|Table value or reference.|

**Returns:**

|Type|Description|
|---|---|
|long|Row count of the table.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/count; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 2=.qtk.tbl.count tabRef
```

## .qtk.tbl.create

Create a new table with given data.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|
|data|table|Table data.|

**Returns:**

|Type|Description|
|---|---|
|symbol \| hsym \| (hsym; symbol; symbol)|The table reference.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/create; `date; `PartitionedTable);

 tabRef~.qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)]
```

## .qtk.tbl.deleteColumn

Delete a column from a table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|
|column|symbol|A column to be deleted.|

**Returns:**

|Type|Description|
|---|---|
|symbol \| hsym \| (hsym; symbol; symbol)|The table reference.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/deleteColumn; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2; c2:`a`b)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 tabRef~.qtk.tbl.deleteColumn[tabRef; `c2]
```

## .qtk.tbl.deleteRows

Delete rows of a table given certain criteria.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|
|criteria|any[]|A list of criteria where matching rows will be deleted, or empty list to delete all rows.  For partitioned tables, if partition field is included in the criteria, it has to be the first in the list.|

**Returns:**

|Type|Description|
|---|---|
|tabRef|The table reference.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/deleteRows; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02 2022.01.02; c1:1 2 3)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 tabRef~.qtk.tbl.deleteRows[tabRef; enlist(=;`c1;3)]
```

## .qtk.tbl.describe

Describe a table reference.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|

**Returns:**

|Name|Type|Description|
|---|---|---|
|description|dict|A dictionary describing the table reference.|
|description.type|symbol|[Table type](#qtktblgettype).|
|description.name|symbol|Table name.|
|description.dbDir|hsym|Database directory, or null symbol if not applicable.|
|description.parField|symbol|Partition field or null symbol if not applicable.|

**Throws:**

|Type|Description|
|---|---|
|TypeError|If `tabRef` is not of valid type.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/describe; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 (`type`name`dbDir`parField!(`Partitioned; `PartitionedTable; `:/tmp/qtk/tbl/describe ; `date))~.qtk.tbl.describe tabRef
```

## .qtk.tbl.drop

Drop a table.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|

**Returns:**

|Type|Description|
|---|---|
|symbol \| hsym \| (hsym; symbol; symbol)|The table reference.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/drop; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 tabRef~.qtk.tbl.drop tabRef
```

## .qtk.tbl.exists

Check if a table of given name exists.
For splayed table not in the current database, it's deemed existent if the directory exists.
For partitioned table not in the current database, it's deemed existent if the directory exists in either the first
or the last partition.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|

**Returns:**

|Type|Description|
|---|---|
|boolean|`1b` if the table exists; `0b` otherwise.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/exists; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 .qtk.tbl.exists tabRef
```

## .qtk.tbl.getType

Get table type, either of `` `Plain`Serialized`Splayed`Partitioned ``. Note that tables in segmented database are
classified as Partitioned.

- See also [.Q.qp](https://code.kx.com/q/ref/dotq/#qqp-is-partitioned).

**Parameter:**

|Name|Type|Description|
|---|---|---|
|t|table \| symbol \| hsym \| (hsym; symbol; symbol)|Table or table reference.|

**Returns:**

|Type|Description|
|---|---|
|symbol|Table type.|

**Throws:**

|Type|Description|
|---|---|
|ValueError|If `t` is a symbol vector but not a valid partitioned table ID.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/getType; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 `Partitioned=.qtk.tbl.getType tabRef
```

## .qtk.tbl.insert

Insert data into a table.
For partitioned tables, data need to be sorted by partitioned field.
Partial data are acceptable; the missing columns will be filled by type compliant nulls for simple columns
or empty lists for compound columns.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference|
|data|table|Table data.|

**Returns:**

|Type|Description|
|---|---|
|symbol \| hsym \| (hsym; symbol; symbol)|The table reference.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/insert; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 tabRef~.qtk.tbl.insert[tabRef; ([] date:2022.01.03 2022.01.04; c1:3 4)]
```

## .qtk.tbl.meta

Get metadata of a table. It's similar to [meta](https://code.kx.com/q/ref/meta/) but supports all table types.
For partitioned table, the latest partition is used.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|t|table \| symbol \| hsym \| (hsym; symbol; symbol)|Table or table reference.|

**Returns:**

|Type|Description|
|---|---|
|table|Metadata of the table.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/meta; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 ([c:`date`c1] t:"dj"; f:`; a:`)~.qtk.tbl.meta tabRef
```

## .qtk.tbl.raiseIfColumnExists

Raise ColumnExistsError if a column exists in a table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|table|table \| symbol \| hsym \| (hsym; symbol; symbol)|Table value or reference.|
|column|symbol|A column name.|

**Throws:**

|Type|Description|
|---|---|
|ColumnExistsError|If the column exists.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/raiseIfColumnExists; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 "ColumnExistsError: c1 on :/tmp/qtk/tbl/raiseIfColumnExists/date/PartitionedTable"~.[.qtk.tbl.raiseIfColumnExists; (tabRef; `c1); {x}]
```

## .qtk.tbl.raiseIfColumnNameInvalid

Raise ColumnNameError if a column name is not valid, i.e. it collides with q's reserved words and implicit column `i`.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|name|symbol|A column name.|

**Throws:**

|Type|Description|
|---|---|
|ColumnNameError|If the column name is not valid.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];

 "ColumnNameError: abs"~@[.qtk.tbl.raiseIfColumnNameInvalid; `abs; {x}]
```

## .qtk.tbl.raiseIfColumnNotFound

Raise ColumnNotFoundError if a column is not found from a table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|table|table \| symbol \| hsym \| (hsym; symbol; symbol)|Table value or reference.|
|column|symbol|A column name.|

**Throws:**

|Type|Description|
|---|---|
|ColumnNotFoundError|If the column doesn't exist.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/raiseIfColumnNotFound; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 "ColumnNotFoundError: c2 on :/tmp/qtk/tbl/raiseIfColumnNotFound/date/PartitionedTable"~.[.qtk.tbl.raiseIfColumnNotFound; (tabRef; `c2); {x}]
```

## .qtk.tbl.rename

Rename a table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|
|newName|symbol|New name of the table.|

**Returns:**

|Type|Description|
|---|---|
|symbol \| hsym \| (hsym; symbol; symbol)|New table reference.|

**Throws:**

|Type|Description|
|---|---|
|TableNameError|If the table name is not valid, i.e. it collides with q's reserved words|
|NameExistsError|If the name is in use|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/rename; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 (`:/tmp/qtk/tbl/rename; `date; `NewPartitionedTable)~.qtk.tbl.rename[tabRef; `NewPartitionedTable]
```

## .qtk.tbl.renameColumns

Rename column(s) from a table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table name.|
|nameDict|dict|A dictionary from existing name(s) to new name(s).|

**Returns:**

|Type|Description|
|---|---|
|symbol \| hsym \| (hsym; symbol; symbol)|The table reference.|

**Throws:**

|Type|Description|
|---|---|
|ColumnNameError|If the column name is not valid.|
|ColumnNotFoundError|If some column doesn't exist.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/renameColumns; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2; c2:`a`b)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 tabRef~.qtk.tbl.renameColumns[tabRef; `c1`c2!`c3`c4]
```

## .qtk.tbl.reorderColumns

Reorder columns of a table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|
|firstColumns|symbol[]|First columns after reordering.|

**Returns:**

|Type|Description|
|---|---|
|symbol \| hsym \| (hsym; symbol; symbol)|The table reference.|

**Throws:**

|Type|Description|
|---|---|
|ColumnNotFoundError|If some column in `firstColumns` doesn't exist.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/reorderColumns; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2; c2:`a`b)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 tabRef~.qtk.tbl.reorderColumns[tabRef; `c2]
```

## .qtk.tbl.select

Select from a table similar to [functional select](https://code.kx.com/q/basics/funsql/#select)
but support all table types.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|table|table \| symbol \| hsym|Table name, path or value.|
|criteria|any[]|A list of criteria where the select is applied to, or empty list for the whole table.|
|groupings|dict \| boolean|A mapping of grouping columns, or `0b` for no grouping, `1b` for distinct.|
|columns|dict|Mappings from column names to columns/expressions.|

**Returns:**

|Type|Description|
|---|---|
|table|Selected data from the table.|

## .qtk.tbl.selectLimit

Select from a table similar to [rank-5 functional select](https://code.kx.com/q/basics/funsql/#rank-5)
but support all table types.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|table|table \| symbol \| hsym|Table name, path or value.|
|criteria|any[]|A list of criteria where the select is applied to, or empty list for the whole table.|
|groupings|dict \| boolean|A mapping of grouping columns, or `0b` for no grouping, `1b` for distinct.|
|columns|dict|Mappings from column names to columns/expressions.|
|limit|int \| long \| (int; int) \| (long; long)|Limit on rows to return.|

**Returns:**

|Type|Description|
|---|---|
|table|Selected data from the table.|

## .qtk.tbl.selectLimitSort

Select from a table similar to [rank-6 functional select](https://code.kx.com/q/basics/funsql/#rank-6)
but support all table types.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|table|table \| symbol \| hsym|Table name, path or value.|
|criteria|any[]|A list of criteria where the select is applied to, or empty list for the whole table.|
|groupings|dict \| boolean|A mapping of grouping columns, or `0b` for no grouping, `1b` for distinct.|
|columns|dict|Mappings from column names to columns/expressions.|
|limit|int \| long \| (int; int) \| (long; long)|Limit on rows to return.|
|sort|any[]|Sort the result by a column. The format is `(op;col)` where `op` is `>:` for descending and    `<:` for ascending, and `col` is the column to be ordered by.|

**Returns:**

|Type|Description|
|---|---|
|table|Selected data from the table.|

## .qtk.tbl.setAttr

Set an attribute to a column. See also [Set Attribute](https://code.kx.com/q/ref/set-attribute/).

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|
|column|symbol|A column name of the table.|
|attribute|symbol|Attribute to be added to the column.|

**Returns:**

|Type|Description|
|---|---|
|symbol|The table name.|

**Throws:**

|Type|Description|
|---|---|
|ColumnNotFoundError|If `column` doesn't exist.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];
 tabRef:(`:/tmp/qtk/tbl/setAttr; `date; `PartitionedTable);
 .qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)];

 // Or replace tabRef with `PartitionedTable if the database is loaded
 .qtk.tbl.setAttr[tabRef; `c1; `s];
 `s=.qtk.tbl.meta[tabRef][`c1;`a]
```

## .qtk.tbl.update

Update values in certain columns of a table, similar to [functional update](https://code.kx.com/q/basics/funsql/#update)
but support all table types.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tabRef|symbol \| hsym \| (hsym; symbol; symbol)|Table reference.|
|criteria|any[]|A list of criteria where the select is applied to, or empty list for the whole table.  For partitioned tables, if partition field is included in the criteria, it has to be the first in the list.|
|groupings|dict \| 0b|A mapping of grouping columns, or `0b` for no grouping.|
|columns|dict|Mappings from column names to columns/expressions.|

**Returns:**

|Type|Description|
|---|---|
|symbol \| hsym \| (hsym; symbol; symbol)|The table reference.|

**Throws:**

|Type|Description|
|---|---|
|ColumnNotFoundError|If a column from `columns` doesn't exist.|
