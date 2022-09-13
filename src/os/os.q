
// @kind data
// @overview `1b` if the underlying OS is Windows; `0b` otherwise.
.os.isWindows:.z.o in `w32`w64;

// @kind function
// @overview Get OS-compliant path of a file.
// @param file {symbol | string} A file path, of either symbol, file symbol, or string format.
// @return {string} OS-compliant path of the file.
.os.getPath:{[file]
  path:$[10h=type file; file; string file];
  if[.os.isWindows; path:ssr[path; "/"; "\\"]];
  (":"=first path) _ path
 };

// @kind function
// @overview List files and directories under a path.
// @param dir {symbol} A file symbol representing a directory.
// @return {symbol[]} Items under the directory in ascending order.
// @throws {FileNotFoundError: *} If the directory doesn't exist.
// @throws {NotADirectoryError: *} If the input argument is not a directory.
.os.listDir:{[dir]
  files:key dir;
  if[()~files; '"FileNotFoundError: ",.os.getPath dir];
  if[dir~files; '"NotADirectoryError: ",.os.getPath dir];
  files
 };

// @kind function
// @overview Copy a file from a source to a target.
// @param source {symbol | string} Source file path, of either symbol, file symbol, or string format.
// @param target {symbol | string} Target file path, of either symbol, file symbol, or string format.
.os.copy:{[source;target]
  sourcePath:.os.getPath source;
  targetPath:.os.getPath target;
  copyCmd:$[.os.isWindows; "copy /v /z"; "cp"];
  system copyCmd," ",sourcePath," ",targetPath;
 };

// @kind function
// @overview Move a file from a source to a target.
// @param source {symbol | string} Source file path, of either symbol, file symbol, or string format.
// @param target {symbol | string} Target file path, of either symbol, file symbol, or string format.
.os.move:{[source;target]
  sourcePath:.os.getPath source;
  targetPath:.os.getPath target;
  moveCmd:$[.os.isWindows; "move"; "mv"];
  system moveCmd," ",sourcePath," ",targetPath;
 };

// @kind function
// @overview remove a file.
// @param file {symbol | string} file path, of either symbol, file symbol, or string format.
.os.remove:{[file]
  filePath:.os.getPath file;
  removeCmd:$[.os.isWindows; "del /q /f"; "rm -f"];
  system removeCmd," ",filePath;
 };
