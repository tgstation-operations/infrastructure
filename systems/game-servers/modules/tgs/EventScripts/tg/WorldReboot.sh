#!/usr/bin/env bash

mkdir -p "${TGS_INSTANCE_ROOT}/Configuration/event_maps"
mkdir -p "${TGS_INSTANCE_ROOT}/Game/Live/_maps/custom"
cp "${TGS_INSTANCE_ROOT}/Game/Live/_maps/custom/*" "${TGS_INSTANCE_ROOT}/Configuration/event_maps"
