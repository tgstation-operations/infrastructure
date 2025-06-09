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
cargo build --ignore-rust-version --release --target=i686-unknown-linux-gnu --features all
mv target/i686-unknown-linux-gnu/release/librust_g.so "$1/librust_g.so"
cd "$work_directory"
echo "rust-g: deployment finish"

echo "dreamluau: deployment begin"
if [ ! -d "dreamluau" ]; then
  echo "dreamluau: cloning"
  git clone https://github.com/tgstation/dreamluau >/dev/null
  cd dreamluau
else
  echo "dreamluau: fetching"
  cd dreamluau
  git fetch >/dev/null
fi
echo "dreamluau: checkout"
git checkout "$DREAMLUAU_VERSION" >/dev/null
echo "dreamluau: building"
env LIBCLANG_PATH="$(find /nix/store -name *-clang-*-lib)/lib" cargo build --ignore-rust-version --release --target=i686-unknown-linux-gnu
cp target/i686-unknown-linux-gnu/release/libdreamluau.so "$1/libdreamluau.so"

# EMERGENCY FIX, SOMETHING IS WRONG WITH THE ABOVE
cp "${TGS_INSTANCE_ROOT}/Configuration/EventScripts.old/libdreamluau.so" "$1/libdreamluau.so"

cd "$work_directory"
echo "dreamluau: deployment finish"

echo "auxcpu: deployment begin"
if [ ! -d "auxcpu" ]; then
  echo "auxcpu: cloning"
  git clone https://github.com/Absolucy/auxcpu >/dev/null
  cd auxcpu
else
  echo "auxcpu: fetching"
  cd auxcpu
  git fetch >/dev/null
fi
echo "auxcpu: checkout"
git checkout main >/dev/null
echo "auxcpu: building"
env LIBCLANG_PATH="$(find /nix/store -name *-clang-*-lib)/lib" cargo build --ignore-rust-version --release --target=i686-unknown-linux-gnu
cp target/i686-unknown-linux-gnu/release/libauxcpu_byondapi.so "$1/libauxcpu_byondapi.so"

cd "$work_directory"
echo "auxcpu: deployment finish"

# Get unzip
apt-get install -y unzip

# compile tgui
echo "tgui: deployment begin"
cd "$1"
env TG_BOOTSTRAP_CACHE="$work_directory" CBT_BUILD_MODE="TGS" tools/bootstrap/javascript.sh tools/build/build.js
echo "tgui: deployment finish"
