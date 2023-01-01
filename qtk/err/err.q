
// @kind data
// @subcategory err
// @overview A list of supported error types.
.qtk.err.Error:`u#
  `ColumnExistsError`ColumnNameError`ColumnNotFoundError,
  `DirectoryNotFoundError`FileNotFoundError`ImportError,
  `ModuleNameError`ModuleNotFoundError`NameExistsError`NotADirectoryError`PackageNotFoundError`RuntimeError`ValueError`SchemaError,
  `TableNameError`TableTypeError`TypeError`UnknownError;


// @kind function
// @subcategory err
// @overview Compose an error message composed of error type and description.
// @param errorType {symbol} Error type, which should be one of [.qtk.err.Error](#qtkerrerror).
// @param description {string} Error description.
// @return {string} An error message of format "{errorType}: {msg}".
// @throws {UnknownError} If `errorType` is not supported.
.qtk.err.compose:{[errorType;description]
  if[not errorType in .qtk.err.Error; '"UnknownError: ",string errorType];
  string[errorType],": ",description
 };
