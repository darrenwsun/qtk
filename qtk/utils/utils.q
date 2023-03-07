
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
// @overview Get integer representation of a vector by given base.
// It's the reverse of [.qtk.utils.intToVectorByBase](#qtkutilsinttovectorbybase), and
// It's an alias of [sv](https://code.kx.com/q/ref/sv/#base-to-integer).
// @param base {short | int | long} Base.
// @param vector {byte[] | short[] | int[] | long[]} Encoded vector.
// @return {long} An integer by evaluating the vector to the base.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["utils";`qtk];
//
// 2357=.qtk.utils.vectorToIntByBase[10; 2 3 5 7]
.qtk.utils.vectorToIntByBase:{[base;vector] base sv vector };

// @kind function
// @subcategory utils
// @overview Get vector representation of an integer by given base.
// It's the reverse of [.qtk.utils.vectorToIntByBase](#qtkutilsvectortointbybase), and
// It's an alias of [vs](https://code.kx.com/q/ref/vs/#base-x-representation).
// @param base {short | int | long} Base.
// @param int {short | int | long} An integer.
// @return {long[]} Vector representation of the integer by the base.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["utils";`qtk];
//
// 2 3 5 7~.qtk.utils.intToVectorByBase[10; 2357]
.qtk.utils.intToVectorByBase:{[base;int] base vs int};

// @kind function
// @subcategory utils
// @overview Get integer representation of an vector by given bases.
// It's the reverse of [.qtk.utils.intToVectorByBases](#qtkutilsinttovectorbybases), and
// It's an alias of [sv](https://code.kx.com/q/ref/sv/#base-to-integer).
// @param bases {short[] | int[] | long[]} Bases.
// @param vector {byte[] | short[] | int[] | long[]} Encoded vector.
// @return {long} Integer representation of the vector by the bases. The first of the bases is not used in the calculation,
// as the coefficient for the last of the vector is always 1.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["utils";`qtk];
//
// 183907=.qtk.utils.vectorToIntByBase[0W 24 60 60; 2 3 5 7]  // 2 days, 3 hours, 5 minutes, 7 seconds
.qtk.utils.vectorToIntByBases:{[bases;vector] bases sv vector };

// @kind function
// @subcategory utils
// @overview Get vector representation of an integer by given bases.
// It's the reverse of [.qtk.utils.vectorToIntByBases](#qtkutilsvectortointbybases), and
// It's an alias of [vs](https://code.kx.com/q/ref/vs/#base-x-representation).
// @param bases {short[] | int[] | long[]} Bases.
// @param int {short | int | long} An integer.
// @return {long[]} Vector representation of the integer by given bases.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["utils";`qtk];
//
// 2 3 5 7~.qtk.utils.intToVectorByBases[0W 24 60 60; 183907]  // 2 days, 3 hours, 5 minutes, 7 seconds
.qtk.utils.intToVectorByBases:{[bases;int] bases vs int};

// @kind function
// @subcategory utils
// @overview Get short/int/long from its byte representation.
// It's the reverse of [.qtk.utils.toBytesByInt](#qtkutilstobytesbyint), and
// similar to [sv](https://code.kx.com/q/ref/sv/#bytes-to-integer) but leaves out the first argument.
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
// @overview Get byte representation of a short/int/long.
// It's the reverse of [.qtk.utils.toIntByBytes](#qtkutilstointbybytes) and
// similar to [vs](https://code.kx.com/q/ref/vs/#byte-representation) but leaves out the first argument.
// @param int {short | int | long} A short/int/long integer.
// @return {byte[]} Byte representation of the integer.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["utils";`qtk];
//
// 0x0101~.qtk.utils.toBytesByInt 257h
.qtk.utils.toBytesByInt:{[int] 0x0 vs int};

// @kind function
// @subcategory utils
// @overview Get byte/short/int/long from its bit (boolean) representation.
// It's the reverse of [.qtk.utils.toBoolsByInt](#qtkutilstoboolsbyint) and
// similar to [sv](https://code.kx.com/q/ref/sv/#bits-to-integer) but leaves out the first argument.
// @param vector {boolean[]} Length-8/16/32/64 boolean vector.
// @return {byte | short | int | long} The corresponding byte or integer represented by the boolean array.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["utils";`qtk];
//
// 0xff=.qtk.utils.toIntByBools 8#1b
.qtk.utils.toIntByBools:{[vector] 0b sv vector };

// @kind function
// @subcategory utils
// @overview Get bit (boolean) representation of a byte/short/int/long.
// It's the reverse of [.qtk.utils.toIntByBools](#qtkutilstointbybools) and
// similar to [vs](https://code.kx.com/q/ref/vs/#bit-representation) but leave out the first argument.
// @param int {byte | short | int | long} A byte or short/int/long integer.
// @return {boolean[]} Bit representation of the byte or integer.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["utils";`qtk];
//
// (8#1b)~.qtk.utils.toBoolsByInt 0xff
.qtk.utils.toBoolsByInt:{[int] 0b vs int };
