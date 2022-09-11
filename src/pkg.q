
// get q package root from command-line argument or environment variable
.pkg._getRootDir:{
  args:.Q.opt .z.x;
  $[`qpr in key args;
    raze system "realpath ",raze args`qpr;
    not ""~qpr:getenv `qpr;
    qpr;
    ' "Unknown q package root"
   ]
 };

if[()~key `.pkg.rootDir;
   .pkg.rootDir:.pkg._getRootDir[];
 ];
if[()~key `.pkg.imported;
   .pkg.imported:`u#();
 ];

.q.import:{[lib]
  if[10h<>type lib; ' "TypeError: expect string for lib"];
  libPath:hsym `$.pkg.rootDir,"/",lib;
  subLibs:key libPath;
  $[()~subLibs; ' "FileNotFoundError: ",lib;
    11h=type subLibs; .q.import each (lib,"/") ,/: string subLibs;
    [
      libSym:`$lib;
      if[libSym in .pkg.imported; : 1b];
      system "l ",.pkg.rootDir,"/",lib;
      .pkg.imported,:libSym;
    ]
   ];
 };
