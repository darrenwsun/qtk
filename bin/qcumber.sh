#!/usr/bin/env bash

QTK=$(readlink -f qtk)
export QTK

echo Running qcumber tests
rlwrap q "$AXLIBRARIES_HOME"/ws/qcumber.q_ -src qtk/init.q -test specs -out ../build/reports/qcumber.json -color -breakOnErrors
