#!/usr/bin/env bash

rm -rf tempdocs
mkdir tempdocs

q $AXLIBRARIES_HOME/ws/qdoc.q_ -src src -out tempdocs -map overview:fileoverview -render -config mkdocs.yml -index docs/index.md

mv tempdocs/md/* docs
rm -rf tempdocs
