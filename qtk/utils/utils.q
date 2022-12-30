
// @kind function
// @private
// @overview Check if a name is in use.
// @param name {symbol} Variable name.
// @return `1b` if the name is in use; `0b` otherwise.
.qtk.utils.nameExists:{[name] not ()~key name };

// @kind function
// @private
// @overview Raise NameExistsError if a name is in use.
// @param name {symbol} Variable name.
// @throws {NameExistsError} If the name is in use.
.qtk.utils.raiseIfNameExists:{[name]
  if[.qtk.utils.nameExists name;
     '.qtk.err.compose[`NameExistsError; string name]
   ];
 };
