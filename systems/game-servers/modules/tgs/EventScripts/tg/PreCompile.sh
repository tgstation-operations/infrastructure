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
cargo update --precise 0.8.12 ahash || true # ensure ahash is up-to-date, else compile will fail due to https://github.com/tkaitchuck/aHash/pull/183
cargo build --release --target=i686-unknown-linux-gnu
cp target/i686-unknown-linux-gnu/release/libdreamluau.so "$1/libdreamluau.so"

cd "$work_directory"
echo "dreamluau: deployment finish"

echo "auxcpu: deployment begin"
if [ ! -d "auxcpu" ]; then
  echo "auxcpu: cloning"
  git clone https://github.com/spacestation13/auxcpu >/dev/null
  cd auxcpu
else
  echo "auxcpu: fetching"
  cd auxcpu
  git fetch >/dev/null
fi
echo "auxcpu: checkout"
git checkout main >/dev/null
echo "auxcpu: building"
cargo build -p auxcpu-byondapi --release --target=i686-unknown-linux-gnu
cp target/i686-unknown-linux-gnu/release/libauxcpu_byondapi.so "$1/libauxcpu_byondapi.so"

cd "$work_directory"
echo "auxcpu: deployment finish"

# compile byond-tracy / libprof.so
echo "byond-tracy: deployment begin"
if [ ! -d "byond-tracy" ]; then
  echo "byond-tracy: cloning"
  git clone https://github.com/ParadiseSS13/byond-tracy >/dev/null
  cd byond-tracy
else
  echo "byond-tracy: fetching"
  cd byond-tracy
  git fetch >/dev/null
fi
echo "byond-tracy: checkout"
git checkout master >/dev/null
echo "byond-tracy: building"
clang -D_FILE_OFFSET_BITS=64 -std=c11 -m32 -shared -fPIC -O3 -s -DNDEBUG prof.c -pthread -o libprof.so
cp ./libprof.so "$1/libprof.so"

cd "$work_directory"
echo "byond-tracy: deployment finish"

# compile tgui
echo "tgui: deployment begin"
cd "$1"
env TG_BOOTSTRAP_CACHE="$work_directory" CBT_BUILD_MODE="TGS" tools/bootstrap/javascript.sh tools/build/build.ts
echo "tgui: deployment finish"

# create symlinks for custom map persistence

mkdir -p "${TGS_INSTANCE_ROOT}/Configuration/event_maps"
mkdir -p "$1/_maps"
ln -sf "${TGS_INSTANCE_ROOT}/Configuration/event_maps" "$1/_maps/custom"
