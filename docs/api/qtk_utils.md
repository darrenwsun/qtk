

## .qtk.utils.nameExists

Check if a name is in use.
It's an alias of [key](https://code.kx.com/q/ref/key/#whether-a-name-is-defined).

**Parameter:**

|Name|Type|Description|
|---|---|---|
|name|symbol|Variable name.|

**Returns:**

|Type|Description|
|---|---|
|boolean|`1b` if the name is in use; `0b` otherwise.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["tbl";`qtk];

 not .qtk.utils.nameExists `noexist
```

## .qtk.utils.raiseIfNameExists

Raise NameExistsError if a name is in use.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|name|symbol|Variable name.|

**Throws:**

|Type|Description|
|---|---|
|NameExistsError|If the name is in use.|
