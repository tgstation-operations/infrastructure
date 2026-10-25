#!/usr/bin/env bash

dirs=$(find . -type d -name 'secrets')
for d in $dirs; do
        pushd $d || exit 1
        agenix -r
        popd || exit 1
done
