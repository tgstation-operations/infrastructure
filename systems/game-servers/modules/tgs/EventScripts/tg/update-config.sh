#!/usr/bin/env bash

. parse-server.sh

CONFIG_URI="https://github.com/tgstation-operations/server-config.git"
TARGET_DIR="${TGS_INSTANCE_ROOT}/Configuration/GameStaticFiles/config"

if [ ! -d $TARGET_DIR ]; then
  git clone $CONFIG_URI $TARGET_DIR
fi

cd $TARGET_DIR
git fetch
git checkout origin/main
git sparse-checkout set $SERVER/ title_screens/
git reset --hard origin/main
ln -sf $SERVER/motd.txt motd.txt
ln -sf $SERVER/dynamic.json dynamic.json
ln -sf $SERVER/jobconfig.toml jobconfig.toml
ln -sf /run/agenix/tg13-comms comms.txt
ln -sf /run/agenix/tg13-dbconfig dbconfig.txt
ln -sf /run/agenix/tg13-tts_secrets tts_secrets.txt
ln -sf /run/agenix/tg13-webhooks webhooks.txt
#Check garage is alive before rcloning from it
curl -sf http://localhost:3903/health
if [ $? -ne 0 ]; then
  echo garage status check failed!
  exit
fi
mkdir -p title_music && rclone --no-check-certificate --config="/run/agenix/tg13-extra_config-rclone" -vvvv copy garage:tg13-extra-config/title_music title_music
mkdir -p reboot_themes && rclone --no-check-certificate --config="/run/agenix/tg13-extra_config-rclone" -vvvv copy garage:tg13-extra-config/reboot_themes reboot_themes
mkdir -p jukebox_music && rclone --no-check-certificate --config="/run/agenix/tg13-extra_config-rclone" -vvvv copy garage:tg13-extra-config/jukebox_music jukebox_music
rclone --no-check-certificate --config="/run/agenix/tg13-extra_config-rclone" -vvvv copy garage:tg13-extra-config/word_filter.toml .
