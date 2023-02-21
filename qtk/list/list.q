
// @kind function
// @subcategory list
// @overview Get type name of a list.
// It's an alias of [key](https://code.kx.com/q/ref/key/#type-of-a-vector).
// @param list {list} A list.
// @return {symbol} Type name if the list is a vector, or null symbol otherwise.
// @doctest
// system "l ",getenv[`QTK],"/init.q";
// .qtk.import.loadModule["list";`qtk];
//
// `symbol=.qtk.list.getTypeName `a`b
.qtk.list.getTypeName:{[list]
  $[type[list] within 1 19; key list; `]
 };

// @kind function
// @subcategory list
// @overview Get the enumeration domain of a list.
// It's an alias of [key](https://code.kx.com/q/ref/key/#enumerator-of-a-list).
// @param list {list} A list.
// @return {symbol} The enumeration domain if the list is enumerated, or null symbol otherwise.
.qtk.list.getEnumDomain:{[list]
  $[20h=type list; key list; `]
 };
