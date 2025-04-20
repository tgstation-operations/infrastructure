#!/usr/bin/env bash

rsc_zip="tgmc.rsc.zip"
if [ -f "./$rsc_zip" ]; then
        rm $rsc_zip
fi
zip $rsc_zip "$1/tgmc.rsc" -9j
rclone copy -v --config="/run/agenix/rsc-cdn" --header-upload "Cache-Control: no-transform" $rsc_zip rsc:rsc
