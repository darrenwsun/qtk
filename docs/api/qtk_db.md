

## .qtk.db.load

Load database in a given directory.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|dir|string \| hsym|Directory.|

**See Also:** [ .qtk.db.reload ]( qtk_db.md#qtkdbreload )

## .qtk.db.loadSym

Load sym file in a database directory while keeping a backup of the original one in memory.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|dbDir|hsym|A database directory.|
|sym|symbol|Name of sym file.|

**Returns:**

|Type|Description|
|---|---|
|symbol|The name of sym file if it's loaded successfully; null symbol otherwise, e.g. if the sym file doesn't exist.|

## .qtk.db.recoverSym

Recover in-memory backup sym data.

**Parameter:**

|Name|Type|Description|
|---|---|---|
|sym|symbol|Name of sym data.|

**Returns:**

|Type|Description|
|---|---|
|symbol|The name of sym file if it's recovered successfully; null symbol otherwise, e.g. if there is no backup of such name.|

## .qtk.db.reload

Reload current database.

**See Also:** [ .qtk.db.load ]( qtk_db.md#qtkdbload )
