# Getting Started

## Installation

1. Download the zipped file from the latest release.
2. Unzip it.

        unzip qtk-0.1.zip

3. Export `QTK` environment variable and point it to the absolute path.

        export QTK=$(readlink -f qtk-0.1)

4. Start a `q` session and load `init.q`.

        // load the script via command line
        q init.q
        // Alternatively load the script within a q session
        system "l ",getenv[`QTK],"/init.q";

## Usage

Browse the [docs](https://qtk.readthedocs.io/en/latest/index.html) and search for what you may need. The following is a CRUD example for partitioned tables.

```q
.qtk.import.loadModule["tbl";`qtk];  // Import module tbl from package qtk

// Create the partitioned table with given data
.qtk.tbl.create[
  `:/tmp/qtk/db`date`Table;  // A partitioned table ID that specifies database directory, partition field, and table name
  ([] date:2022.01.01 2022.01.02; c1:1 2)];
.qtk.db.load `:/tmp/qtk/db;

// Double values in column c1
.qtk.tbl.update[`Table; (); 0b; (enlist`c1)!(enlist (*;`c1;2))];

// Select the whole table
.qtk.tbl.select[`Table; (); 0b; 0#`];

// Drop the table
.qtk.tbl.drop `Table;
```
