#!/usr/bin/env bash

set -e
set -x

original_dir="${TGS_INSTANCE_ROOT}/Configuration/EventScriptsScratch"
cd "$1"
. dependencies.sh

mkdir -p "$original_dir"
cd "$original_dir"

if [ ! -d "rust-g" ]; then
        echo "Cloning rust-g..."
        git clone https://github.com/tgstation/rust-g
        cd rust-g
else
        echo "Fetching rust-g..."
        cd rust-g
        git fetch
fi

echo "Deploying rust-g..."
git checkout "$RUST_G_VERSION"

cargo build --release --target=i686-unknown-linux-gnu --features all
mv target/i686-unknown-linux-gnu/release/librust_g.so "$1/librust_g.so"

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

cd "$original_dir"
echo "byond-tracy: deployment finish"

# compile tgui
echo "Compiling tgui..."
cd "$1"
chmod +x tools/bootstrap/node  # Workaround for https://github.com/tgstation/tgstation-server/issues/1167
env TG_BOOTSTRAP_CACHE="$original_dir" TG_BOOTSTRAP_NODE_LINUX=1 CBT_BUILD_MODE="TGS" tools/bootstrap/node tools/build/build.js
