
// @kind function
// @subcategory utils
// @overview Check if a name is in use.
// It's an alias of [key](https://code.kx.com/q/ref/key/#whether-a-name-is-defined).
// @param name {symbol} Variable name.
// @return {boolean} `1b` if the name is in use; `0b` otherwise.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["tbl";`qtk];
//
// not .qtk.utils.nameExists `noexist
.qtk.utils.nameExists:{[name] not ()~key name };

// @kind function
// @subcategory utils
// @overview Raise NameExistsError if a name is in use.
// @param name {symbol} Variable name.
// @throws {NameExistsError} If the name is in use.
.qtk.utils.raiseIfNameExists:{[name]
  if[.qtk.utils.nameExists name;
     '.qtk.err.compose[`NameExistsError; string name]
   ];
 };
