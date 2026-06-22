#!/usr/bin/env bash

set -e
set -x

# move to deployment folder
cd "$1"

# load dependencies
. dependencies.sh

# create a dedicated folder for running the script
work_directory="${TGS_INSTANCE_ROOT}/Configuration/EventScriptsScratch"
mkdir -p $work_directory

cd $work_directory


echo "rust-g: deployment begin"
if [ ! -d "rust-g" ]; then
  echo "rust-g: cloning"
  git clone https://github.com/tgstation/rust-g >/dev/null
  cd rust-g
else
  echo "rust-g: fetching"
  cd rust-g
  git fetch >/dev/null
fi
echo "rust-g: checkout"
git checkout "$RUST_G_VERSION" >/dev/null
echo "rust-g: building"
cargo build --release --target=i686-unknown-linux-gnu --features all
mv target/i686-unknown-linux-gnu/release/librust_g.so "$1/librust_g.so"
cd "$work_directory"
echo "rust-g: deployment finish"

echo "auxmos: deployment begin"
if [ ! -d "auxmos" ]; then
  echo "auxmos: cloning"
  git clone https://github.com/shiptest-ss13/auxmos >/dev/null
  cd auxmos
else
  echo "auxmos: fetching"
  cd auxmos
  git fetch >/dev/null
fi
echo "auxmos: checkout"
git checkout "$RUST_G_VERSION" >/dev/null
echo "auxmos: building"
PKG_CONFIG_ALLOW_CROSS=1 RUSTFLAGS="-C target-cpu=native" cargo build --release --target=i686-unknown-linux-gnu --features "citadel_reactions,katmos"
mv target/i686-unknown-linux-gnu/release/libauxmos.so "$1/libauxmos.so"
cd "$work_directory"
echo "auxmos: deployment finish"

# compile tgui
echo "tgui: deployment begin"
cd "$1"
env TG_BOOTSTRAP_CACHE="$work_directory" CBT_BUILD_MODE="TGS" tools/bootstrap/javascript.sh tools/build/build.ts
echo "tgui: deployment finish"

# create symlinks for custom map persistence

mkdir -p "${TGS_INSTANCE_ROOT}/Configuration/event_maps"
mkdir -p "$1/_maps"
ln -sf "${TGS_INSTANCE_ROOT}/Configuration/event_maps" "$1/_maps/custom"
