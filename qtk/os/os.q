
// @kind data
// @overview `1b` if the underlying OS is Windows; `0b` otherwise.
.qtk.os.isWindows:.z.o in `w32`w64;

// @kind function
// @subcategory os
// @overview Get OS-compliant path of a file.
// @param file {symbol | string} A file path, of either symbol, file symbol, or string format.
// @return {string} OS-compliant path of the file.
.qtk.os.getPath:{[file]
  path:$[10h=type file; file; string file];
  if[.qtk.os.isWindows; path:ssr[path; "/"; "\\"]];
  (":"=first path) _ path
 };

// @kind function
// @overview Create directory.
// @param dir {symbol} A file symbol representing a directory.
.qtk.os.mkdir:{[dir]
  sourcePath:.qtk.os.getPath dir;
  cmd:$[.qtk.os.isWindows; "mkdir"; "mkdir -p"];
  system cmd," ",sourcePath;
 };

// @kind function
// @overview List files and directories under a path.
// @param dir {symbol} A file symbol representing a directory.
// @return {symbol[]} Items under the directory in ascending order.
// @throws {FileNotFoundError: *} If the directory doesn't exist.
// @throws {NotADirectoryError: *} If the input argument is not a directory.
.qtk.os.listDir:{[dir]
  files:key dir;
  if[()~files; '"FileNotFoundError: ",.qtk.os.getPath dir];
  if[dir~files; '"NotADirectoryError: ",.qtk.os.getPath dir];
  files
 };

// @kind function
// @overview Copy a file from a source to a target.
// @param source {symbol | string} Source file path, of either symbol, file symbol, or string format.
// @param target {symbol | string} Target file path, of either symbol, file symbol, or string format.
.qtk.os.copy:{[source;target]
  sourcePath:.qtk.os.getPath source;
  targetPath:.qtk.os.getPath target;
  copyCmd:$[.qtk.os.isWindows; "copy /v /z"; "cp"];
  system copyCmd," ",sourcePath," ",targetPath;
 };

// @kind function
// @overview Move a file from a source to a target.
// @param source {symbol | string} Source file path, of either symbol, file symbol, or string format.
// @param target {symbol | string} Target file path, of either symbol, file symbol, or string format.
.qtk.os.move:{[source;target]
  sourcePath:.qtk.os.getPath source;
  targetPath:.qtk.os.getPath target;
  moveCmd:$[.qtk.os.isWindows; "move"; "mv"];
  system moveCmd," ",sourcePath," ",targetPath;
 };

// @kind function
// @overview remove a file.
// @param file {symbol | string} File path, of either symbol, file symbol, or string format.
.qtk.os.remove:{[file]
  filePath:.qtk.os.getPath file;
  removeCmd:$[.qtk.os.isWindows; "del /q /f"; "rm -f"];
  system removeCmd," ",filePath;
 };

// @kind function
// @overview remove a directory and all nested items within it.
// @param dir {symbol | string} Directory path, of either symbol, file symbol, or string format.
.qtk.os.rmtree:{[dir]
  filePath:.qtk.os.getPath dir;
  removeCmd:$[.qtk.os.isWindows; "rmdir /s"; "rm -rf"];
  system removeCmd," ",filePath;
 };
