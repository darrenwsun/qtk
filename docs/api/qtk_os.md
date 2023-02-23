

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

List files and directories under a path, in ascending order.
It's similar to [key](https://code.kx.com/q/ref/key/#files-in-a-folder) but raises errors if the directory doesn't exist
or the argument isn't a directory.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dir|hsym|A file symbol representing a directory.|

**Returns:**

|Type|Description|
|---|---|
|symbol[]|Items under the directory in ascending order.|

**Throws:**

|Type|Description|
|---|---|
|FileNotFoundError|If the directory doesn't exist.|
|NotADirectoryError|If the input argument is not a directory.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];

 "FileNotFoundError: /not/a/directory"~@[.qtk.os.listDir; `:/not/a/directory; {x}]
```

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
It's an alias of [key](https://code.kx.com/q/ref/key/#whether-a-folder-exists).

**Parameter:**

|Name|Type|Description|
|---|---|---|
|path|hsym \| string|A file symbol or string representing a path.|

**Returns:**

|Type|Description|
|---|---|
|boolean|`1b` if this entry is a directory or a symbolic link pointing to a directory; return `0b` otherwise.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];

 .qtk.os.path.isDir `:/tmp
```

## .qtk.os.path.isFile

Check if the path points to a file.
It's an alias of [key](https://code.kx.com/q/ref/key/#whether-a-file-exists).

**Parameter:**

|Name|Type|Description|
|---|---|---|
|path|hsym \| string|A file symbol or string representing a path.|

**Returns:**

|Type|Description|
|---|---|
||`1b` if the path points to a file; `0b` otherwise.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];

 .qtk.os.path.isFile `:/bin/bash
```

## .qtk.os.path.join

Join path segments. It's similar to [filepath-components overload of sv](https://code.kx.com/q/ref/sv/#filepath-components)
but moving the file handle out as a standalone argument.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|base|hsym|Base path.|
|segments|symbol \| symbol[]|Path segments.|

**Returns:**

|Type|Description|
|---|---|
|hsym|A path by joining base path with the segments.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["os";`qtk];

 `:/tmp/seg1/seg2~.qtk.os.path.join[`:/tmp;`seg1`seg2]
```

## .qtk.os.path.string

Get OS-compliant path of a file.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|path|symbol \| string|A file path, of either symbol, file symbol, or string format.|

**Returns:**

|Type|Description|
|---|---|
|string|OS-compliant path of the file.|

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
