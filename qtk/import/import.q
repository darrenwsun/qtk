
if[()~key `.qtk.import.Package;
   .qtk.import.Package:([name:`$()]
                         path:`$()
   )
 ];

if[()~key `.qtk.import.Module;
   .qtk.import.Module:([name:`$()]
                        package:`.qtk.import.Package$`$();
                        path:`$()
   )
 ];

// @kind function
// @subcategory import
// @overview Add a package specified by a name and a path.
// @param name {symbol} Package name.
// @param path {string | hsym} Path to the package.
// @return {boolean} `1b` if the path is added; `0b` if the path already exists.
// @throws {DirectoryNotFoundError: [*]} If the path doesn't exist.
// @throws {NotADirectoryError: [*]} If the path is not a directory.
.qtk.import.addPackage:{[name;path]
  if[name in exec name from .qtk.import.Package; :0b];
  if[not .qtk.os.path.exists path; '.qtk.err.compose[`DirectoryNotFoundError; .qtk.os.path.string path]];
  if[not .qtk.os.path.isDir path; '.qtk.err.compose[`NotADirectoryError; .qtk.os.path.string path]];
/  if[()~subDirs:key pathHsym; '.qtk.err.compose[`DirectoryNotFoundError; .qtk.os.path.string path]];
/  if[11h<>type subDirs; '.qtk.err.compose[`NotADirectoryError; .qtk.os.path.string path]];

  pathHsym:$[-11h=type path; path; hsym `$path];
  `.qtk.import.Package upsert (name; pathHsym);
  1b
 };

// @kind function
// @subcategory import
// @overview Remove a package.
// @param name {symbol} Package name.
// @return {boolean} `1b` if the package is unloaded; `0b` if the package wasn't loaded.
.qtk.import.removePackage:{[name]
  if[not name in exec name from .qtk.import.Package; :0b];
  ![`.qtk.import.Package; enlist(=;`name;enlist name); 0b; `$()];
  1b
 };

// @kind function
// @subcategory import
// @overview List all loaded packages.
// @return {table} A table of loaded packages and their paths.
.qtk.import.listPackages:{
  .qtk.import.Package
 };

// @kind function
// @subcategory import
// @overview Clear all loaded packages.
.qtk.import.clearPackages:{
  delete from `.qtk.import.Package;
 };

// @kind function
// @subcategory import
// @overview Load a module.
// @param name {string | symbol} Module name.
// @param package {symbol} Package where the module exists.
// @return `1b` if the module is loaded; `0b` if the module has already been loaded.
// @throws {PackageNotFoundError: [*]} If the package is not found.
// @throws {ModuleNotFoundError: [*]} If the module is not found.
// @throws {ModuleNameError: [*]} If the module name is not valid.
.qtk.import.loadModule:{[name;package]
  if[count .qtk.import.Module;
     if[any name like/: exec (string[name],\:"/*") from .qtk.import.Module; :0b]
  ];

  nameSym:$[-11h=type name; name; `$name];
  modulePath:.qtk.import.searchModule[nameSym;package];
  .qtk.import._loadModule modulePath;
  `.qtk.import.Module upsert (nameSym; package; modulePath);
  1b
 };

// @kind function
// @private
// @subcategory import
// @overview Load modules under a path and its subdirectories (if exists) recursively.
// @param path {hsym} A path.
.qtk.import._loadModule:{[path]
  // One might load a submodule before a parent module
  if[path in exec path from .qtk.import.Module; :(::)];

  submodules:key path;
  $[11h=type submodules;
    .qtk.import._loadModule each .Q.dd[path; ] each submodules;
    any path like/: ("*.q";"*.q_");
    system "l ",1_string path
    // ignore non-q scripts
   ];
 };

// @kind function
// @subcategory import
// @overview Search a module from a package.
// @param name {string | symbol} Module name.
// @param package {symbol} Package where the module exists.
// @return {hsym} A path to the found module.
// @throws {PackageNotFoundError: [*]} If the package is not found.
// @throws {ModuleNotFoundError: [*]} If the module is not found.
// @throws {ModuleNameError: [*]} If the module name is not valid.
.qtk.import.searchModule:{[name;package]
  packagePath:.qtk.import.Package[package;`path];
  if[null packagePath; '.qtk.err.compose[`PackageNotFoundError; string package]];

  nameSym:$[-11h=type name; name; `$name];
  modulePath:.Q.dd[packagePath; nameSym];
  if[.qtk.os.path.exists modulePath;
    // expect a directory without suffix
    $[.qtk.os.path.isDir modulePath; :modulePath; '.qtk.err.compose[`ModuleNameError; string nameSym]]
   ]

  possiblePaths:.Q.dd[packagePath; ] each (`$string[nameSym],".q";`$string[nameSym],".q_");
  modulePath:first possiblePaths where .qtk.os.path.exists each possiblePaths;
  if[null modulePath; '.qtk.err.compose[`ModuleNotFoundError; string nameSym]];
  modulePath
 };

// @kind function
// @subcategory import
// @overview Unload a module.
// @param name {string | symbol} Module name.
// @return `1b` if the module is unloaded; `0b` if the module wasn't loaded.
.qtk.import.unloadModule:{[name]
  nameSym:$[-11h=type name; name; `$name];
  if[not nameSym in exec name from .qtk.import.Module; :0b];
  ![`.qtk.import.Module; enlist(or;(=;`name;enlist nameSym);(like;`name;string[nameSym],"/*")); 0b; `$()];
  1b
 };

// @kind function
// @subcategory import
// @overview Reload a module.
// @param name {string | symbol} Module name.
// @throws {ModuleNotFoundError: [*]} If the module is not found.
.qtk.import.reloadModule:{[name]
  nameSym:$[-11h=type name; name; `$name];
  modulePath:.qtk.import.Module[nameSym;`path];

  if[null modulePath; '.qtk.err.compose[`ModuleNotFoundError; string nameSym]];

  .qtk.import._loadModule modulePath;
 };

// @kind function
// @subcategory import
// @overview List all loaded modules.
// @return {table} A table of loaded modules and their packages and paths.
.qtk.import.listModules:{
  .qtk.import.Module
 };

// @kind function
// @subcategory import
// @overview Clear all loaded modules.
.qtk.import.clearModules:{
  delete from `.qtk.import.Module;
 };
