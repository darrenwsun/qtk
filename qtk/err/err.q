

// @kind data
// @overview Error types.
.qtk.err.Error:`u#
  `ColumnExistsError`ColumnNameError`ColumnNotFoundError,
  `DirectoryNotFoundError`FileNotFoundError`ImportError,
  `ModuleNameError`ModuleNotFoundError`NameError`NameExistsError`NotADirectoryError`PackageNotFoundError`RuntimeError`ValueError`SchemaError,
  `TableNameError`TableTypeError`TypeError`UnknownError;


// @kind function
// @subcategory err
// @overview Compose an error message.
// @param errorType {symbol} Error type, which should be one of `.qtk.err.Error`.
// @param description {string} Error description.
// @return {string} An error message of format "{errorType}: {msg}".
// @throws {UnknownError: error type [*] not in .qtk.err.Error} If `errorType` is not one of `.qtk.err.Error`.
.qtk.err.compose:{[errorType;description]
  if[not errorType in .qtk.err.Error; '"UnknownError: error type [",string[errorType],"] not in .qtk.err.Error"];
  string[errorType],": ",description
 };
