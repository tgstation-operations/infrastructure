#!/usr/bin/env bash

cd "${TGS_INSTANCE_ROOT}/Configuration/GameStaticFiles"

CONFIG_URI="https://github.com/tgstation-operations/server-config-effigy.git"
TARGET_DIR="${TGS_INSTANCE_ROOT}/Configuration/GameStaticFiles/config"

if [ ! -d $TARGET_DIR ]; then
  git clone $CONFIG_URI $TARGET_DIR
fi

cd $TARGET_DIR
git fetch
git checkout origin/main
git reset --hard origin/main
ln -sf /run/agenix/effigy-comms comms.txt
ln -sf /run/agenix/effigy-dbconfig dbconfig.txt
#ln -sf /run/agenix/effigy-tts_secrets tts_secrets.txt BE careful with this, only enable when that stuff may or may not be worked out.
#Check garage is alive before rcloning from it
curl -sf http://localhost:3903/health
if [ $? -ne 0 ]; then
  echo garage status check failed!
  exit
fi
mkdir -p title_music && rclone --no-check-certificate --config="/run/agenix/effigy-extra_config-rclone" -vvvv copy garage:effigy-extra-config/title_music title_music
mkdir -p reboot_themes && rclone --no-check-certificate --config="/run/agenix/effigy-extra_config-rclone" -vvvv copy garage:effigy-extra-config/reboot_themes reboot_themes
mkdir -p jukebox_music && rclone --no-check-certificate --config="/run/agenix/effigy-extra_config-rclone" -vvvv copy garage:effigy-extra-config/jukebox_music jukebox_music
rclone --no-check-certificate --config="/run/agenix/effigy-extra_config-rclone" -vvvv copy garage:effigy-extra-config/word_filter.toml .
