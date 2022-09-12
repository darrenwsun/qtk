
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
// @overview Copy a file from a source to a target.
// @param source {symbol | string} Source file path, of either symbol, file symbol, or string format.
// @param target {symbol | string} Target file path, of either symbol, file symbol, or string format.
.os.copy:{[source;target]
  sourcePath:.os.getPath source;
  targetPath:.os.getPath target;
  copyCmd:$[.os.isWindows; "copy /v /z"; "cp"];
  system copyCmd," ",sourcePath," ",targetPath;
 };
