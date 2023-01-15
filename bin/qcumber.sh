#!/usr/bin/env bash

QTK=$(readlink -f qtk)
export QTK

rm -rf /tmp/hdb_*

echo Running qcumber tests
rlwrap q "$AXLIBRARIES_HOME"/ws/qcumber.q_ -src qtk/init.q -test specs -out build/reports/qcumber.json -color -breakOnErrors

rm -rf /tmp/hdb_*
