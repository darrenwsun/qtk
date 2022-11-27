
// @kind function
// @overview Check if the path points to a file.
// @param path {hsym} A file symbol.
// @return `1b` if the path points to a file; `0b` otherwise.
.qtk.os.path.isFile:{[path]
  path~key path
 };

// @kind function
// @overview Check if the path points to a directory.
// @param path {hsym} A file symbol.
// @return {bool} `1b` if this entry is a directory or a symbolic link pointing to a directory; return `0b` otherwise.
.qtk.os.path.isDir:{[path] 11h=type key path };

// @kind function
// @overview Check if the path exists.
// @param path {symbol} A file symbol.
// @return `1b` if the path exists; `0b` otherwise.
.qtk.os.path.exists:{[path]
  not ()~key path
 };
