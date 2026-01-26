#!/usr/bin/env bash

export GH_TOKEN=$2

@NIX_GH_PATH@/bin/gh -R tgstation/tgstation workflow run compile_changelogs.yml

# the ghetto
@NIX_COREUTILS_PATH@/bin/sleep 45
