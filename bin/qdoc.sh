#!/usr/bin/env bash

rm -rf /tmp/qtk

QTK=$(readlink -f qtk)
export QTK

rm -rf tempdocs
mkdir tempdocs

rlwrap q $AXLIBRARIES_HOME/ws/qdoc.q_ -src qtk -out tempdocs -map overview:fileoverview -group subcategory -docprivate -doctest -render -config mkdocs.yml -index docs/index.md -qpkgdir qtk "$AXLIBRARIES_HOME"/ws

mv tempdocs/md/* docs/api
rm -rf tempdocs

rm -rf /tmp/qtk
