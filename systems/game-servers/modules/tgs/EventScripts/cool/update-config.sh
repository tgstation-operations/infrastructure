#!/usr/bin/env bash

cd "${TGS_INSTANCE_ROOT}/Configuration/GameStaticFiles"

CONFIG_URI="https://github.com/tgstation-operations/server-config-coolstation.git"
TARGET_DIR="${TGS_INSTANCE_ROOT}/Configuration/GameStaticFiles/config"

if [ ! -d $TARGET_DIR ]; then
  git clone $CONFIG_URI $TARGET_DIR
fi

cd $TARGET_DIR
git fetch
git checkout origin/main
git reset --hard origin/main
ln -sf /run/agenix/cool-apitoken apitoken.txt
curl -sf http://localhost:3903/health
if [ $? -ne 0 ]; then
  echo garage status check failed!
  exit
fi
