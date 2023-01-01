

## .qtk.import._loadModule

Load modules under a path and its subdirectories (if exists) recursively.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|path|hsym|A path.|

## .qtk.import.addPackage

Add a package specified by a name and a path.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|name|symbol|Package name.|
|path|string \| hsym|Path to the package.|

**Returns:**

|Type|Description|
|---|---|
|boolean|`1b` if the path is added; `0b` if the path already exists.|

**Throws:**

|Type|Description|
|---|---|
|DirectoryNotFoundError: [*]|If the path doesn't exist.|
|NotADirectoryError: [*]|If the path is not a directory.|

## .qtk.import.clearModules

Clear all loaded modules.

## .qtk.import.clearPackages

Clear all loaded packages.

## .qtk.import.listModules

List all loaded modules.

**Returns:**

|Type|Description|
|---|---|
|table|A table of loaded modules and their packages and paths.|

## .qtk.import.listPackages

List all loaded packages.

**Returns:**

|Type|Description|
|---|---|
|table|A table of loaded packages and their paths.|

## .qtk.import.loadModule

Load a module.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|name|string \| symbol|Module name.|
|package|symbol|Package where the module exists.|

**Returns:**

|Type|Description|
|---|---|
||`1b` if the module is loaded; `0b` if the module has already been loaded.|

**Throws:**

|Type|Description|
|---|---|
|PackageNotFoundError: [*]|If the package is not found.|
|ModuleNotFoundError: [*]|If the module is not found.|
|ModuleNameError: [*]|If the module name is not valid.|

## .qtk.import.reloadModule

Reload a module.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|name|string \| symbol|Module name.|

**Throws:**

|Type|Description|
|---|---|
|ModuleNotFoundError: [*]|If the module is not found.|

## .qtk.import.removePackage

Remove a package.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|name|symbol|Package name.|

**Returns:**

|Type|Description|
|---|---|
|boolean|`1b` if the package is unloaded; `0b` if the package wasn't loaded.|

## .qtk.import.searchModule

Search a module from a package.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|name|string \| symbol|Module name.|
|package|symbol|Package where the module exists.|

**Returns:**

|Type|Description|
|---|---|
|hsym|A path to the found module.|

**Throws:**

|Type|Description|
|---|---|
|PackageNotFoundError: [*]|If the package is not found.|
|ModuleNotFoundError: [*]|If the module is not found.|
|ModuleNameError: [*]|If the module name is not valid.|

## .qtk.import.unloadModule

Unload a module.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|name|string \| symbol|Module name.|

**Returns:**

|Type|Description|
|---|---|
||`1b` if the module is unloaded; `0b` if the module wasn't loaded.|
