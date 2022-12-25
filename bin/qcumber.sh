#!/usr/bin/env bash

echo Running qcumber tests
rlwrap q "$AXLIBRARIES_HOME"/ws/qcumber.q_ -src qtk/pkg.q -test specs -out ../build/reports/qcumber.json -color -breakOnErrors -qpkgdir qtk "$AXLIBRARIES_HOME"/ws
