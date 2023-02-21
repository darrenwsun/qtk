

## .qtk.list.getEnumDomain

Get the enumeration domain of a list.
It's an alias of [key](https://code.kx.com/q/ref/key/#enumerator-of-a-list).

**Parameter:**

|Name|Type|Description|
|---|---|---|
|list|list|A list.|

**Returns:**

|Type|Description|
|---|---|
|symbol|The enumeration domain if the list is enumerated, or null symbol otherwise.|

## .qtk.list.getTypeName

Get type name of a list.
It's an alias of [key](https://code.kx.com/q/ref/key/#type-of-a-vector).

**Parameter:**

|Name|Type|Description|
|---|---|---|
|list|list|A list.|

**Returns:**

|Type|Description|
|---|---|
|symbol|Type name if the list is a vector, or null symbol otherwise.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["list";`qtk];

 `symbol=.qtk.list.getTypeName `a`b
```
