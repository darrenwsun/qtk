

## .qtk.err.Error

A list of supported error types.

## .qtk.err.compose

Compose an error message composed of error type and description.

**Parameters:**

|Name|Type|Description|
|---|---|---|
|errorType|symbol|Error type, which should be one of [.qtk.err.Error](#qtkerrerror).|
|description|string|Error description.|

**Returns:**

|Type|Description|
|---|---|
|string|An error message of format "{errorType}: {msg}".|

**Throws:**

|Type|Description|
|---|---|
|UnknownError|If `errorType` is not supported.|
