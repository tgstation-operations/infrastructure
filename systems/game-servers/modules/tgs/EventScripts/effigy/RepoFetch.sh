#!/usr/bin/env bash

set -e
export GH_TOKEN="$2"
export GH_REPO="effigy-se/effigy"

@NIX_GH_PATH@/bin/gh workflow run --ref main compile_changelogs.yml > /dev/null
@NIX_GH_PATH@/bin/gh run watch $(@NIX_GH_PATH@/bin/gh run list -wcompile_changelogs.yml --json databaseId --limit 1 -q ".[0].databaseId") > /dev/null
