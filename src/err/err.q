

// @kind data
// @overview Error types.
.err.Error:`u#`ColumnExistsError`ColumnNotFoundError`FileNotFoundError`NameError`NotADirectoryError`RuntimeError,
  `SchemaError`TableTypeError`UnknownError;


// @kind function
// @overview Compose an error message.
// @param errorType {symbol} Error type, which should be one of `.err.Error`.
// @param description {string} Error description.
// @return {string} An error message of format "{errorType}: {msg}".
// @throws {UnknownError: error type [*] not in .err.Error} If `errorType` is not one of `.err.Error`.
.err.compose:{[errorType;description]
  if[not errorType in .err.Error; '"UnknownError: error type [",string[errorType],"] not in .err.Error"];
  string[errorType],": ",description
 };
