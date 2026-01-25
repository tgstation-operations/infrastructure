#!/usr/bin/env bash

mkdir -p "${TGS_INSTANCE_ROOT}/Configuration/event_maps"
mkdir -p "$1/_maps"
ln -sf "${TGS_INSTANCE_ROOT}/Configuration/event_maps" "$1/_maps/custom"
