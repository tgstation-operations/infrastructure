#!/usr/bin/env bash

work_directory="${TGS_INSTANCE_ROOT}/Configuration/EventScriptsScratch"

mkdir -p $work_directory
cd $work_directory

. "${TGS_INSTANCE_ROOT}/Configuration/EventScripts/parse-server.sh"

rsc_zip="tgstation.$SERVER.rsc.zip"
if [ -f "./$rsc_zip" ]; then
        rm $rsc_zip
fi
zip $rsc_zip "$1/tgstation.rsc" -9j
rclone copy -v --config="/run/agenix/rsc-cdn" --header-upload "Cache-Control: no-transform" $rsc_zip rsc:rsc
