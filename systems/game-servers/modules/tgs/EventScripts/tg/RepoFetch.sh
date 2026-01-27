#!/usr/bin/env bash

set -e
export GH_TOKEN="$2"
export GH_REPO="tgstation/tgstation"
alias gh=@NIX_GH_PATH@/bin/gh
gh workflow run compile_changelogs.yml > /dev/null
gh run watch $(gh run list -wcompile_changelogs.yml --json databaseId --limit 1 -q ".[0].databaseId") > /dev/null

# the ghetto
@NIX_COREUTILS_PATH@/bin/sleep 45
