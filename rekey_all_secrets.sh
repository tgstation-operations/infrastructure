#!/usr/bin/env bash

dirs=$(find . -type d -name 'secrets')
for d in $dirs; do
        pushd $d
        agenix -r
        popd
done
