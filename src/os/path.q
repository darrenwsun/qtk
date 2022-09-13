
// @kind function
// @overview Check if the path points to a file.
// @param path {symbol} A file symbol.
// @return `1b` if the path points to a file; `0b` otherwise.
.os.path.isFile:{[path]
   path~key path
 };

// @kind function
// @overview Check if the path exists.
// @param path {symbol} A file symbol.
// @return `1b` if the path exists; `0b` otherwise.
.os.path.exists:{[path]
  not ()~key path
 };
