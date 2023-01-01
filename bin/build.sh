#!/usr/bin/env bash

version=$(grep ".qtk.version" qtk/init.q | awk -F: '{print $2}' | tr -d '"')
echo Build for version "$version"
cd qtk || exit
git archive --format=zip --prefix=qtk_"$version"/ --output=../dist/qtk_"$version".zip HEAD
echo Build completed. Artifact is qtk_"$version".zip in dist directory
