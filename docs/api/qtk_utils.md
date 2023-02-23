

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

## .qtk.utils.toIntByBase

Decode an vector to integer by a base.
It's an alias of [sv](https://code.kx.com/q/ref/sv/#decode).

**Parameters:**

|Name|Type|Description|
|---|---|---|
|base|short \| int \| long|Base.|
|vector|byte[] \| short[] \| int[] \| long[]|Encoded vector.|

**Returns:**

|Type|Description|
|---|---|
|long|An integer by evaluating the vector to the base.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["utils";`qtk];

 2357=.qtk.utils.toIntByBase[10; 2 3 5 7]
```

## .qtk.utils.toIntByBases

Decode an vector to integer by bases.
It's an alias of [sv](https://code.kx.com/q/ref/sv/#decode).

**Parameters:**

|Name|Type|Description|
|---|---|---|
|bases|short[] \| int[] \| long[]|Bases.|
|vector|byte[] \| short[] \| int[] \| long[]|Encoded vector.|

**Returns:**

|Type|Description|
|---|---|
|long|An integer by evaluating the vector to the bases. The first of the bases is not used in the calculation,  as the coefficient for the last of the vector is always 1.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["utils";`qtk];

 183907=.qtk.utils.toIntByBase[0 24 60 60; 2 3 5 7]  // 2 days, 3 hours, 5 minutes, 7 seconds
```

## .qtk.utils.toIntByBools

Decode a length-8/16/32/64 boolean vector to byte/short/int/long.
It's an alias of [sv](https://code.kx.com/q/ref/sv/#decode).

**Parameter:**

|Name|Type|Description|
|---|---|---|
|vector|boolean[]|Length-8/16/32/64 boolean vector.|

**Returns:**

|Type|Description|
|---|---|
|byte \| short \| int \| long|The corresponding byte or integer represented by the boolean array.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["utils";`qtk];

 0xff=.qtk.utils.toIntByBools 8#1b
```

## .qtk.utils.toIntByBytes

Decode a length-2/4/8 byte vector to short/int/long.
It's an alias of [sv](https://code.kx.com/q/ref/sv/#decode).

**Parameter:**

|Name|Type|Description|
|---|---|---|
|vector|byte[]|Length-2/4/8 byte vector.|

**Returns:**

|Type|Description|
|---|---|
|short \| int \| long|The corresponding integer represented by the byte array.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["utils";`qtk];

 257h=.qtk.utils.toIntByBytes 0x0101
```
