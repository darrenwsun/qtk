
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

// @kind function
// @subcategory utils
// @overview Decode an vector to integer by a base.
// It's an alias of [sv](https://code.kx.com/q/ref/sv/#decode).
// @param base {short | int | long} Base.
// @param vector {byte[] | short[] | int[] | long[]} Encoded vector.
// @return {long} An integer by evaluating the vector to the base.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["utils";`qtk];
//
// 2357=.qtk.utils.toIntByBase[10; 2 3 5 7]
.qtk.utils.toIntByBase:{[base;vector] base sv vector };

// @kind function
// @subcategory utils
// @overview Decode an vector to integer by bases.
// It's an alias of [sv](https://code.kx.com/q/ref/sv/#decode).
// @param bases {short[] | int[] | long[]} Bases.
// @param vector {byte[] | short[] | int[] | long[]} Encoded vector.
// @return {long} An integer by evaluating the vector to the bases. The first of the bases is not used in the calculation,
// as the coefficient for the last of the vector is always 1.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["utils";`qtk];
//
// 183907=.qtk.utils.toIntByBase[0 24 60 60; 2 3 5 7]  // 2 days, 3 hours, 5 minutes, 7 seconds
.qtk.utils.toIntByBases:{[bases;vector] bases sv vector };

// @kind function
// @subcategory utils
// @overview Decode a length-2/4/8 byte vector to short/int/long.
// It's an alias of [sv](https://code.kx.com/q/ref/sv/#decode).
// @param vector {byte[]} Length-2/4/8 byte vector.
// @return {short | int | long} The corresponding integer represented by the byte array.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["utils";`qtk];
//
// 257h=.qtk.utils.toIntByBytes 0x0101
.qtk.utils.toIntByBytes:{[vector] 0x0 sv vector };

// @kind function
// @subcategory utils
// @overview Decode a length-8/16/32/64 boolean vector to byte/short/int/long.
// It's an alias of [sv](https://code.kx.com/q/ref/sv/#decode).
// @param vector {boolean[]} Length-8/16/32/64 boolean vector.
// @return {byte | short | int | long} The corresponding byte or integer represented by the boolean array.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["utils";`qtk];
//
// 0xff=.qtk.utils.toIntByBools 8#1b
.qtk.utils.toIntByBools:{[vector] 0b sv vector };
