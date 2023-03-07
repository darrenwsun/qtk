
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
// @overview Join path segments. It's similar to [filepath-components overload of sv](https://code.kx.com/q/ref/sv/#filepath-components)
// but moving the file handle out as a standalone argument.
// @param base {hsym} Base path.
// @param segments {symbol | symbol[]} Path segments.
// @return {hsym} A path by joining base path with the segments.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["os";`qtk];
//
// `:/tmp/seg1/seg2~.qtk.os.path.join[`:/tmp;`seg1`seg2]
.qtk.os.path.join:{[base;segments] ` sv base,segments };

// @kind function
// @subcategory os
// @overview Split a file path into directory and file parts. It's similar to [file handle overload of vs](https://code.kx.com/q/ref/vs/#file-handle)
// but leaves out the first argument.
// @param path {hsym} A file path.
// @return {symbol[]} Two-element symbol vector where the first is the directory part and the second the file part.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["os";`qtk];
//
// `:/tmp/dir`file~.qtk.os.path.split[`:/tmp/dir/file]
.qtk.os.path.split:{[path] ` vs path };

// @kind function
// @subcategory os
// @overview Get OS-compliant path of a file.
// @param path {symbol | hsym | string} A file path, of either symbol, file symbol, or string format.
// @return {string} OS-compliant path of the file.
.qtk.os.path.string:{[path]
  pathStr:$[10h=type path; path; string path];
  if[.qtk.os.isWindows; pathStr:ssr[pathStr; enlist"/"; "\\"]];
  (":"=first pathStr) _pathStr
 };

// @kind function
// @subcategory os
// @overview Get canonical path eliminating symlinks and up-level references.
// @param path {symbol | hsym | string} A file path, of either symbol, file symbol, or string format.
// @return {string} Canonical path eliminating symlinks and up-level references.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["os";`qtk];
//
// "/home"~.qtk.os.path.realpath[`:/tmp/.././home]
.qtk.os.path.realpath:{[path]
  pathStr:.qtk.os.path.string path;
  r:$[.qtk.os.isWindows;
    @[system; ssr["powershell \"(Resolve-Path $PATH).Path\""; "$PATH"; pathStr]; ""];
    @[system; "realpath ",pathStr; ""]];
  if[r~""; '.qtk.err.compose[`FileNotFoundError; pathStr]];
  raze r
 };


// @kind function
// @subcategory os
// @overview Check if two paths point to the same file or directory.
// @param path1 {symbol | hsym | string} A file path, of either symbol, file symbol, or string format.
// @param path2 {symbol | hsym | string} A file path, of either symbol, file symbol, or string format.
// @return {boolean} `1b` if the two paths point to the same file or directory, `0b` otherwise.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["os";`qtk];
//
// .qtk.os.path.samefile[`:/tmp/.././home; `:/home]
.qtk.os.path.samefile:{[path1;path2]
  if[path1~path2; :1b];

  pathStr1:@[.qtk.os.path.realpath; path1; ""];
  if[pathStr1~""; :0b];
  pathStr2:@[.qtk.os.path.realpath; path2; ""];
  if[pathStr2~""; :0b];
  pathStr1~pathStr2
 };
