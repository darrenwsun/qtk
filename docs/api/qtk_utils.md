

## .qtk.utils.intToVectorByBase

Get vector representation of an integer by given base.
It's the reverse of [.qtk.utils.vectorToIntByBase](#qtkutilsvectortointbybase), and
It's an alias of [vs](https://code.kx.com/q/ref/vs/#base-x-representation).

**Parameters:**

|Name|Type|Description|
|---|---|---|
|base|short \| int \| long|Base.|
|int|short \| int \| long|An integer.|

**Returns:**

|Type|Description|
|---|---|
|long[]|Vector representation of the integer by the base.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["utils";`qtk];

 2 3 5 7~.qtk.utils.intToVectorByBase[10; 2357]
```

## .qtk.utils.intToVectorByBases

Get vector representation of an integer by given bases.
It's the reverse of [.qtk.utils.vectorToIntByBases](#qtkutilsvectortointbybases), and
It's an alias of [vs](https://code.kx.com/q/ref/vs/#base-x-representation).

**Parameters:**

|Name|Type|Description|
|---|---|---|
|bases|short[] \| int[] \| long[]|Bases.|
|int|short \| int \| long|An integer.|

**Returns:**

|Type|Description|
|---|---|
|long[]|Vector representation of the integer by given bases.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["utils";`qtk];

 2 3 5 7~.qtk.utils.intToVectorByBases[0W 24 60 60; 183907]  // 2 days, 3 hours, 5 minutes, 7 seconds
```

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

## .qtk.utils.toBoolsByInt

Get bit (boolean) representation of a byte/short/int/long.
It's the reverse of [.qtk.utils.toIntByBools](#qtkutilstointbybools) and
similar to [vs](https://code.kx.com/q/ref/vs/#bit-representation) but leave out the first argument.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|int|byte \| short \| int \| long|A byte or short/int/long integer.|

**Returns:**

|Type|Description|
|---|---|
|boolean[]|Bit representation of the byte or integer.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["utils";`qtk];

 (8#1b)~.qtk.utils.toBoolsByInt 0xff
```

## .qtk.utils.toBytesByInt

Get byte representation of a short/int/long.
It's the reverse of [.qtk.utils.toIntByBytes](#qtkutilstointbybytes) and
similar to [vs](https://code.kx.com/q/ref/vs/#byte-representation) but leaves out the first argument.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|int|short \| int \| long|A short/int/long integer.|

**Returns:**

|Type|Description|
|---|---|
|byte[]|Byte representation of the integer.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["utils";`qtk];

 0x0101~.qtk.utils.toBytesByInt 257h
```

## .qtk.utils.toIntByBools

Get byte/short/int/long from its bit (boolean) representation.
It's the reverse of [.qtk.utils.toBoolsByInt](#qtkutilstoboolsbyint) and
similar to [sv](https://code.kx.com/q/ref/sv/#bits-to-integer) but leaves out the first argument.

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

Get short/int/long from its byte representation.
It's the reverse of [.qtk.utils.toBytesByInt](#qtkutilstobytesbyint), and
similar to [sv](https://code.kx.com/q/ref/sv/#bytes-to-integer) but leaves out the first argument.

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

## .qtk.utils.vectorToIntByBase

Get integer representation of a vector by given base.
It's the reverse of [.qtk.utils.intToVectorByBase](#qtkutilsinttovectorbybase), and
It's an alias of [sv](https://code.kx.com/q/ref/sv/#base-to-integer).

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

 2357=.qtk.utils.vectorToIntByBase[10; 2 3 5 7]
```

## .qtk.utils.vectorToIntByBases

Get integer representation of an vector by given bases.
It's the reverse of [.qtk.utils.intToVectorByBases](#qtkutilsinttovectorbybases), and
It's an alias of [sv](https://code.kx.com/q/ref/sv/#base-to-integer).

**Parameters:**

|Name|Type|Description|
|---|---|---|
|bases|short[] \| int[] \| long[]|Bases.|
|vector|byte[] \| short[] \| int[] \| long[]|Encoded vector.|

**Returns:**

|Type|Description|
|---|---|
|long|Integer representation of the vector by the bases. The first of the bases is not used in the calculation,  as the coefficient for the last of the vector is always 1.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["utils";`qtk];

 183907=.qtk.utils.vectorToIntByBase[0W 24 60 60; 2 3 5 7]  // 2 days, 3 hours, 5 minutes, 7 seconds
```
