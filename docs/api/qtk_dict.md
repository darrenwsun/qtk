

## .qtk.dict.key

Return the key of a dictionary. It's an alias of [key](https://code.kx.com/q/ref/key/#key-of-a-dictionary).

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dict|dict|A dictionary.|

**Returns:**

|Type|Description|
|---|---|
|any[]|The key of a dictionary.|

**Example:**

```q
 system "l ",getenv[`QTK],"/init.q";
 .qtk.import.loadModule["dict";`qtk];

 `a`b~.qtk.dict.key `a`b!1 2
```
