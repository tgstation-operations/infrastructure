#!/usr/bin/env bash

CONFIG_URI="https://github.com/tgstation-operations/server-config-tgmc.git"
TARGET_DIR="../GameStaticFiles/config"

if [ ! -d $TARGET_DIR ]; then
  git clone $CONFIG_URI $TARGET_DIR
fi

cd $TARGET_DIR
git fetch
git checkout origin/main
git reset --hard origin/main
ln -sf /run/agenix/tgmc-dbconfig dbconfig.txt
ln -sf /run/agenix/tgmc-tts_secrets tts_secrets.txt
# Try to check if garage is alive before we rclone from it
curl -sf http://localhost:3903/health
if [ $? -ne 0 ]; then
  echo garage status check failed!
  exit
fi
mkdir -p lobby_themes && rclone --no-check-certificate --config="/run/agenix/tgmc-extra_config-rclone" -v sync garage:tgmc-extra-config/lobby_themes lobby_themes
mkdir -p reboot_themes && rclone --no-check-certificate --config="/run/agenix/tgmc-extra_config-rclone" -v sync garage:tgmc-extra-config/reboot_themes reboot_themes
rclone --no-check-certificate --config="/run/agenix/tgmc-extra_config-rclone" -v copy garage:tgmc-extra-config/word_filter.toml .
