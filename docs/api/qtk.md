

## .qtk.db._defaultValue **_(private)_**

Get default value based on a path to a partitioned table and a column. The default value is type-specific
null if it's a simple column, an empty typed list if it's a compound column, or an empty general list.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|symbol|A file symbol to a partitioned table.|
|column|symbol|A column name of the table.|

**Returns:**

|Type|Description|
|---|---|
|any|Default value of the column.|

## .qtk.db._dotDExists **_(private)_**

Check if `.d` file exists in a path of a splayed/partitioned table.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table..|

**Returns:**

|Type|Description|
|---|---|
|boolean|`1b` if `.d` exists; `0b` otherwise.|

## .qtk.db._enumerate **_(private)_**

Enumerate a value against sym.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|val|any|A value.|

**Returns:**

|Type|Description|
|---|---|
|enum|Enumerated value against sym file in the current directory if the value is a symbol or a symbol vector;    otherwise the same value as-is.|

## .qtk.db._enumerateAgainst **_(private)_**

Enumerate a value against a domain.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|dir|hsym|Handle to a directory.|
|domain|symbol|Name of domain.|
|val|any|A value.|

**Returns:**

|Type|Description|
|---|---|
|enum|Enumerated value against the domain in the directory if the value is a symbol or a symbol vector;    otherwise the same value as-is.|

## .qtk.db._getColumns **_(private)_**

Get all columns of an on-disk table.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to a splayed/partitioned table.|

**Returns:**

|Type|Description|
|---|---|
|symbol[]|Columns of the table.|

## .qtk.db._isTypeCompliant **_(private)_**

Check if a list is type-compliant to a target list. A list is type-compliant to another list when
  - their types as returned by `.Q.ty` are the same
  - target list is not a vector nor a compound list
  - target list is a compound list, and actual list is a generic empty list

**Parameters:**

|Name|Type|Description|
|---|---|---|
|target|any[]|Target list.|
|actual|any[]|Actual list.|

**Returns:**

|Type|Description|
|---|---|
||`1b` if the actual list is type-compliant to the target list; `0b` otherwise.|

## .qtk.db._locateTable **_(private)_**

Locate partitioned or segmented table.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|tableName|symbol|Table name.|

**Returns:**

|Type|Description|
|---|---|
|symbol|Paths of the table.|

## .qtk.db._rowCount **_(private)_**

Get row count of an on-disk table. Count of the first column is used.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|

**Returns:**

|Type|Description|
|---|---|
|long|Row count of the table.|

## .qtk.db._saveTable **_(private)_**

Save a table of data to an on-disk table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|tableData|table|A table of data.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

## .qtk.db._validateSchema **_(private)_**

Validate a table conforms to the schema of an on-disk table.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|data|table|A table of data.|

**Throws:**

|Type|Description|
|---|---|
|SchemaError: mismatch between actual columns [*] and expected ones [*]|If columns in the data table don't match    those in the on-disk table (if exists).|
|SchemaError: mismatch between actual types [*] and expected ones [*]|If data types of the columns    in the data table don't match those in the on-disk table (if exists).|

## .qtk.db.loadSym

**Parameters:**

|Name|Type|Description|
|---|---|---|
|dbDir|||
|sym|||

## .qtk.db.recoverSym

**Parameter:**

|Name|Type|Description|
|---|---|---|
|sym|||

## .qtk.os.copy

Copy a file from a source to a target.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|source|symbol \| string|Source file path, of either symbol, file symbol, or string format.|
|target|symbol \| string|Target file path, of either symbol, file symbol, or string format.|

## .qtk.os.isWindows

`1b` if the underlying OS is Windows; `0b` otherwise.

## .qtk.os.listDir

List files and directories under a path.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dir|symbol|A file symbol representing a directory.|

**Returns:**

|Type|Description|
|---|---|
|symbol[]|Items under the directory in ascending order.|

**Throws:**

|Type|Description|
|---|---|
|FileNotFoundError|If the directory doesn't exist.|
|NotADirectoryError|If the input argument is not a directory.|

## .qtk.os.mkdir

Create directory.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dir|symbol|A file symbol representing a directory.|

## .qtk.os.move

Move a file from a source to a target.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|source|symbol \| string|Source file path, of either symbol, file symbol, or string format.|
|target|symbol \| string|Target file path, of either symbol, file symbol, or string format.|

## .qtk.os.path.exists

Check if the path exists.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|path|hsym \| string|A file symbol or string representing a path.|

**Returns:**

|Type|Description|
|---|---|
||`1b` if the path exists; `0b` otherwise.|

## .qtk.os.path.isDir

Check if the path points to a directory.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|path|hsym \| string|A file symbol or string representing a path.|

**Returns:**

|Type|Description|
|---|---|
|boolean|`1b` if this entry is a directory or a symbolic link pointing to a directory; return `0b` otherwise.|

## .qtk.os.path.isFile

Check if the path points to a file.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|path|hsym \| string|A file symbol or string representing a path.|

**Returns:**

|Type|Description|
|---|---|
||`1b` if the path points to a file; `0b` otherwise.|

## .qtk.os.remove

remove a file.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|file|symbol \| string|File path, of either symbol, file symbol, or string format.|

## .qtk.os.rmtree

remove a directory and all nested items within it.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dir|symbol \| string|Directory path, of either symbol, file symbol, or string format.|

## .qtk.tbl._fix **_(private)_**

Fix an on-disk table based on a mapping between columns and their default values. Fixable issues include:

  - add `.d` file if missing
  - add missing columns to `.d` file
  - add missing data files to disk filled by nulls for simple columns or empty lists for compound columns
  - remove excessive columns from `.d` file but leave data files untouched
  - put columns in the right order

**Parameters:**

|Name|Type|Description|
|---|---|---|
|tablePath|hsym|Path to an on-disk table.|
|columnDefaults|dict|A mapping between columns and their default values.|

**Returns:**

|Type|Description|
|---|---|
|hsym|The path to the table.|

## .qtk.type.defaults

## .qtk.utils.nameExists **_(private)_**

Check if a name is in use.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|name|symbol|Variable name.|

**Returns:**

|Type|Description|
|---|---|
||`1b` if the name is in use; `0b` otherwise.|

## .qtk.utils.raiseIfNameExists **_(private)_**

Raise NameExistsError if a name is in use.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|name|symbol|Variable name.|

**Throws:**

|Type|Description|
|---|---|
|NameExistsError|If the name is in use.|
