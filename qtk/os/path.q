
// @kind function
// @overview Check if the path points to a file.
// @param path {hsym | string} A file symbol or string representing a path.
// @return `1b` if the path points to a file; `0b` otherwise.
.qtk.os.path.isFile:{[path]
  pathHsym:$[-11h=type path; path; hsym `$path];
  pathHsym~key pathHsym
 };

// @kind function
// @overview Check if the path points to a directory.
// @param path {hsym | string} A file symbol or string representing a path.
// @return {bool} `1b` if this entry is a directory or a symbolic link pointing to a directory; return `0b` otherwise.
.qtk.os.path.isDir:{[path]
  pathHsym:$[-11h=type path; path; hsym `$path];
  11h=type key pathHsym
 };

// @kind function
// @overview Check if the path exists.
// @param path {hsym | string} A file symbol or string representing a path.
// @return `1b` if the path exists; `0b` otherwise.
.qtk.os.path.exists:{[path]
  pathHsym:$[-11h=type path; path; hsym `$path];
  not ()~key pathHsym
 };
