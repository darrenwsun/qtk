
// @kind function
// @subcategory os
// @overview Check if the path points to a file.
// It's an alias of [key](https://code.kx.com/q/ref/key/#whether-a-file-exists).
// @param path {hsym | string} A file symbol or string representing a path.
// @return `1b` if the path points to a file; `0b` otherwise.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
//
// .qtk.os.path.isFile `:/bin/bash
.qtk.os.path.isFile:{[path]
  pathHsym:$[-11h=type path; path; hsym `$path];
  pathHsym~key pathHsym
 };

// @kind function
// @subcategory os
// @overview Check if the path points to a directory.
// It's an alias of [key](https://code.kx.com/q/ref/key/#whether-a-folder-exists).
// @param path {hsym | string} A file symbol or string representing a path.
// @return {boolean} `1b` if this entry is a directory or a symbolic link pointing to a directory; return `0b` otherwise.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
//
// .qtk.os.path.isDir `:/tmp
.qtk.os.path.isDir:{[path]
  pathHsym:$[-11h=type path; path; hsym `$path];
  11h=type key pathHsym
 };

// @kind function
// @subcategory os
// @overview Check if the path exists.
// @param path {hsym | string} A file symbol or string representing a path.
// @return `1b` if the path exists; `0b` otherwise.
.qtk.os.path.exists:{[path]
  pathHsym:$[-11h=type path; path; hsym `$path];
  not ()~key pathHsym
 };

// @kind function
// @subcategory os
// @overview Get OS-compliant path of a file.
// @param path {symbol | string} A file path, of either symbol, file symbol, or string format.
// @return {string} OS-compliant path of the file.
.qtk.os.path.string:{[path]
  pathStr:$[10h=type path; path; string path];
  if[.qtk.os.isWindows; pathStr:ssr[pathStr; enlist"/"; "\\"]];
  (":"=first pathStr) _pathStr
 };
