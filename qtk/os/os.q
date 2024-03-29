
// @kind data
// @subcategory os
// @overview `1b` if the underlying OS is Windows; `0b` otherwise.
.qtk.os.isWindows:.z.o in `w32`w64;

// @kind function
// @subcategory os
// @overview Create directory.
// @param dir {symbol} A file symbol representing a directory.
.qtk.os.mkdir:{[dir]
  sourcePath:.qtk.os.path.string dir;
  cmd:$[.qtk.os.isWindows; "mkdir"; "mkdir -p"];
  system cmd," ",sourcePath;
 };

// @kind function
// @subcategory os
// @overview List files and directories under a path, in ascending order.
// It's similar to [key](https://code.kx.com/q/ref/key/#files-in-a-folder) but raises errors if the directory doesn't exist
// or the argument isn't a directory.
// @param dir {hsym} A file symbol representing a directory.
// @return {symbol[]} Items under the directory in ascending order.
// @throws {FileNotFoundError} If the directory doesn't exist.
// @throws {NotADirectoryError} If the input argument is not a directory.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
//
// "FileNotFoundError: /not/a/directory"~@[.qtk.os.listDir; `:/not/a/directory; {x}]
.qtk.os.listDir:{[dir]
  files:key dir;
  if[()~files; '"FileNotFoundError: ",.qtk.os.path.string dir];
  if[dir~files; '"NotADirectoryError: ",.qtk.os.path.string dir];
  files
 };

// @kind function
// @subcategory os
// @overview Copy a file from a source to a target.
// @param source {symbol | string} Source file path, of either symbol, file symbol, or string format.
// @param target {symbol | string} Target file path, of either symbol, file symbol, or string format.
.qtk.os.copy:{[source;target]
  sourcePath:.qtk.os.path.string source;
  targetPath:.qtk.os.path.string target;
  copyCmd:$[.qtk.os.isWindows; "copy /v /z"; "cp"];
  system copyCmd," ",sourcePath," ",targetPath;
 };

// @kind function
// @subcategory os
// @overview Move a file from a source to a target.
// @param source {symbol | string} Source file path, of either symbol, file symbol, or string format.
// @param target {symbol | string} Target file path, of either symbol, file symbol, or string format.
.qtk.os.move:{[source;target]
  sourcePath:.qtk.os.path.string source;
  targetPath:.qtk.os.path.string target;
  moveCmd:$[.qtk.os.isWindows; "move"; "mv"];
  system moveCmd," ",sourcePath," ",targetPath;
 };

// @kind function
// @subcategory os
// @overview remove a file.
// @param file {symbol | string} File path, of either symbol, file symbol, or string format.
.qtk.os.remove:{[file]
  filePath:.qtk.os.path.string file;
  removeCmd:$[.qtk.os.isWindows; "del /q /f"; "rm -f"];
  system removeCmd," ",filePath;
 };

// @kind function
// @subcategory os
// @overview remove a directory and all nested items within it.
// @param dir {symbol | string} Directory path, of either symbol, file symbol, or string format.
.qtk.os.rmtree:{[dir]
  filePath:.qtk.os.path.string dir;
  removeCmd:$[.qtk.os.isWindows; "rmdir /s"; "rm -rf"];
  system removeCmd," ",filePath;
 };
