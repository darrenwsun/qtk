

// @kind function
// @subcategory db
// @overview Load sym file in a database directory while keeping a backup of the original one in memory.
// @param dbDir {hsym} A database directory.
// @param sym {symbol} Name of sym file.
// @return {symbol} The name of sym file if it's loaded successfully; null symbol otherwise, e.g. if the sym file doesn't exist.
.qtk.db.loadSym:{[dbDir;sym]
  symFile:.Q.dd[dbDir;sym];
  if[not .qtk.os.path.isFile symFile; :`];
  if[sym in system enlist"v"; .qtk.db[sym]:get sym];
  load .Q.dd[dbDir;sym];
  sym
 };

// @kind function
// @subcategory db
// @overview Recover in-memory backup sym data.
// @param sym {symbol} Name of sym data.
// @return {symbol} The name of sym file if it's recovered successfully; null symbol otherwise, e.g. if there is no backup of such name.
.qtk.db.recoverSym:{[sym]
  oldSym:.qtk.db[sym];
  if[11h<>type oldSym; :`];
  sym set oldSym;
  delete sym from `.qtk.db;
  sym
 };

// @kind function
// @subcategory db
// @overview Load database in a given directory.
// @param dir {string | hsym} Directory.
// @see .qtk.db.reload
.qtk.db.load:{[dir]
  dirStr:$[10h=type dir; dir; 1_string dir];
  system "l ",dirStr;
 };

// @kind function
// @subcategory db
// @overview Reload current database.
// @see .qtk.db.load
.qtk.db.reload:{
  .qtk.db.load enlist".";
 };

// @kind function
// @private
// @overview Enumerate a value against sym.
// @param val {any} A value.
// @return {enum} Enumerated value against sym file in the current directory if the value is a symbol or a symbol vector;
//   otherwise the same value as-is.
.qtk.db._enumerate:{[val]
  .qtk.db._enumerateAgainst[`:.; `sym; val]
 };

// @kind function
// @private
// @overview Enumerate a value against a domain.
// @param dir {hsym} Handle to a directory.
// @param val {any} A value.
// @param domain {symbol} Name of domain.
// @return {enum} Enumerated value against the domain in the directory if the value is a symbol or a symbol vector;
//   otherwise the same value as-is.
.qtk.db._enumerateAgainst:{[dir;domain;val]
  if[11<>abs type val; :val];
  .Q.dd[dir; domain]?val
 };

// @kind function
// @private
// @overview Get all columns of an on-disk table.
// @param tablePath {hsym} Path to a splayed/partitioned table.
// @return {symbol[]} Columns of the table.
.qtk.db._getColumns:{[tablePath]
  get .Q.dd[tablePath; `.d]
 };

// @kind function
// @private
// @overview Save a table of data to an on-disk table.
// @param tablePath {hsym} Path to an on-disk table.
// @param tableData {table} A table of data.
// @return {hsym} The path to the table.
.qtk.db._saveTable:{[tablePath;tableData]
  columns:cols tableData;
  @[tablePath; columns; ,; tableData columns];
  if[not .qtk.db._dotDExists tablePath; @[tablePath; `.d; :; columns]];
  tablePath
 };

// @kind function
// @private
// @overview Get row count of an on-disk table. Count of the first column is used.
// @param tablePath {hsym} Path to an on-disk table.
// @return {long} Row count of the table.
.qtk.db._rowCount:{[tablePath]
  allColumns:.qtk.db._getColumns tablePath;
  count get .Q.dd[tablePath; first allColumns]
 };

// @kind function
// @private
// @overview Check if `.d` file exists in a path of a splayed/partitioned table.
// @param tablePath {hsym} Path to an on-disk table..
// @return {boolean} `1b` if `.d` exists; `0b` otherwise.
.qtk.db._dotDExists:{[tablePath]
  filesInPartition:.qtk.os.listDir tablePath;
  `.d in filesInPartition
 };

// @kind function
// @private
// @overview Get default value based on a path to a partitioned table and a column. The default value is type-specific
// null if it's a simple column, an empty typed list if it's a compound column, or an empty general list.
// @param tablePath {symbol} A file symbol to a partitioned table.
// @param column {symbol} A column name of the table.
// @return {any} Default value of the column.
.qtk.db._defaultValue:{[tablePath;column]
  columnValue:tablePath column;
  columnType:.Q.ty columnValue;
  $[columnType in .Q.a; first 0#columnValue;
    columnType in .Q.A; lower[columnType]$();
    ()
   ]
 };
