.qtk.version:"0.1"

// mandatory scripts to be loaded in the usual way
system "l ",getenv[`QTK],"/err/err.q";
system "l ",getenv[`QTK],"/os/os.q";
system "l ",getenv[`QTK],"/os/path.q";
system "l ",getenv[`QTK],"/import/import.q";

.qtk.import.addPackage[`qtk; getenv[`QTK]];

// load the mandatory modules for completeness
.qtk.import.loadModule["import";`qtk];
.qtk.import.loadModule["err";`qtk];
.qtk.import.loadModule["os"; `qtk];
