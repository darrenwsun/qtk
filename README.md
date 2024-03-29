<h1 style="text-align:center">Q Toolkit</h1>
<p>
  <a href="https://qtk.readthedocs.io/en/latest/index.html" target="_blank">
    <img alt="Documentation" src="https://img.shields.io/badge/documentation-yes-brightgreen.svg" />
  </a>
  <a href="https://github.com/darrenwsun/qtk/blob/master/LICENSE" target="_blank">
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg" />
  </a>
</p>

> Libraries that ease q development

# Overview

Q Toolkit (QTK) is a set of libraries that ease development by q, a language for [kdb+](https://code.kx.com/q/). It provides the following tools:

- simple package/module management
- uniform APIs to interact with tables regardless of whether they are in-memory or on-disk
- database management utilities
- file system utilities
- structured error raising

# Getting Started

## Installation

1. Download the zipped file from the latest release.
2. Unzip it.
   ```shell
   unzip qtk-0.1.zip
   cd qtk-0.1
   ```
3. Export `QTK` environment variable and point it to the absolute path.
   ```shell
   export QTK=$(readlink -f .)
   ```
4. Start a `q` session and load `init.q`.
   ```shell
   # load the script via command line
   q init.q
   ```
   Alternatively load the script within a q session
   ```q
   system "l ",getenv[`QTK],"/init.q";
   ```

## Usage

Browse the [docs](https://qtk.readthedocs.io/en/latest/index.html) and search for what you may need. The following is a CRUD example.

```q
.qtk.import.loadModule["tbl";`qtk];  // Import tbl module from qtk package
tabRef:(`:/tmp/qtk/db; `date; `Table);  // A partitioned table ID that specifies database directory, partition field, and table name
.qtk.tbl.create[tabRef; ([] date:2022.01.01 2022.01.02; c1:1 2)]  // Create the partitioned table with given data
.qtk.tbl.load `:/tmp/qtk/db;
.qtk.tbl.update[`Table; (); 0b; (enlist`c1)!(enlist (*;`c1;2))];
.qtk.tbl.select[`Table; (); 0b; 0#`];
.qtk.tbl.drop `Table;
```

# Contributing

Contributions, issues and feature requests are welcome!<br />
Feel free to check [issues page](https://github.com/darrenwsun/qtk/issues). You can also take a look at the [contributing guide](https://github.com/darrenwsun/qtk#contributing).

# License

Copyright © 2023 [Darren Sun](https://github.com/darrenwsun).<br />
This project is [MIT](https://github.com/darrenwsun/qtk/blob/master/LICENSE) licensed.

***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_
