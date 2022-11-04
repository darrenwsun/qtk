// get q package directories from command-line argument or environment variable
.pkg._getQpkgdir:{
  args:.Q.opt .z.x;
  qpkgdir:$[
           `qpkgdir in key args; {raze system "realpath ",x} each args`qpkgdir;
           not ""~envar:getenv `qpkgdir; ";" vs envar;
           enlist enlist"."
           ];
  {if[()~key x; '"NotADirectoryError: ",x]} each qpkgdir;
  {hsym `$x} qpkgdir
 };

.pkg.add:{[paths]
  .pkg.directories:({hsym `$raze system "realpath ",x} each paths),.pkg.directories;
 };

if[()~key `.pkg.directories;
   .pkg.directories:.pkg._getQpkgdir[];
  ];
if[()~key `.pkg.imported;
   .pkg.imported:`u#();
  ];

.q.import:{[lib]
  if[10h<>type lib; '"TypeError: expect string for lib"];
  libPath:.pkg.search lib;
  if[null libPath; '"ModuleNotFoundError: ",lib];
  subLibs:key libPath;
  $[11h=type subLibs;
    .q.import each (lib,"/"),/:string subLibs;
    [
      libSym:`$lib;
      if[libSym in .pkg.imported; :(::)];
      system "l ", 1_ string[libPath];
      .pkg.imported,:libSym;
      ]
   ];
 };

.pkg.search:{[lib]
  found:{not ()~key .Q.dd[x; `$y]}[; lib] each .pkg.directories;
  $[any found; .Q.dd[.pkg.directories[found?1b]; `$lib]; `]
 };
