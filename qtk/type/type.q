
.qtk.type.defaults:.[!;] flip (
  (" ";());
  ("b";0b);
  ("B";"B"$());
  ("g";0Ng);
  ("G";"G"$());
  ("x";0x00);
  ("X";"X"$());
  ("h";0Nh);
  ("H";"H"$());
  ("i";0Ni);
  ("I";"I"$());
  ("j";0Nj);
  ("J";"J"$());
  ("e";0Ne);
  ("E";"E"$());
  ("f";0n);
  ("F";"F"$());
  ("c";" ");
  ("C";"C"$());
  ("s";`);
  ("S";"S"$());
  ("p";0Np);
  ("P";"P"$());
  ("m";0Nm);
  ("M";"M"$());
  ("d";0Nd);
  ("D";"D"$());
  ("z";0Nz);
  ("Z";"Z"$());
  ("n";0Nn);
  ("N";"N"$());
  ("u";0Nu);
  ("U";"U"$());
  ("v";0Nv);
  ("V";"V"$());
  ("t";0Nt);
  ("t";"T"$())
  );

// @kind function
// @subcategory type
// @overview Rename a table.
// @param v {any} Any q object.
// @return {boolean} `1b` if `v` is a simple or keyed table, or name of a simple or keyed table; `0b` otherwise.
.qtk.type.isTable:{[v]
  val:$[-11h=type v; get v; v];
  if[98h=type val; :1b];
  $[99h=type val;
   (98h=type key val) and (98h=type value val);
   0b]
 };
