

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

## .qtk.type.defaults
