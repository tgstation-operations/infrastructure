#!/usr/bin/env bash

set -e
set -x

#load dep exports
#need to switch to game dir for Dockerfile weirdness
original_dir="${TGS_INSTANCE_ROOT}/Configuration/EventScriptsScratch"
cd "$1"
. dependencies.sh
mkdir -p "$original_dir"
cd "$original_dirh"

# update rust-g
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

cargo build --ignore-rust-version --release --target=i686-unknown-linux-gnu --features all
mv target/i686-unknown-linux-gnu/release/librust_g.so "$1/librust_g.so"

#cd "$original_dir"

# update dreamluau
#if [ ! -d "dreamluau" ]; then
        #echo "Cloning dreamluau..."
        #git clone https://github.com/tgstation/dreamluau
        #cd dreamluau
#else
        #echo "Fetching dreamlaua..."
        #cd dreamluau
        #git fetch
#fi

echo "Deploying Dreamlaua..."
#git checkout "$DREAMLUAU_VERSION"

# cargo build --ignore-rust-version --release --target=i686-unknown-linux-gnu
# mv target/i686-unknown-linux-gnu/release/libdreamluau.so "$1/libdreamluau.so"

# Temporary workaround. Expecting prebuild libdreamluau.so in Configuration directory
cp ../../libdreamluau.so "$1/libdreamluau.so"

# compile tgui
echo "Compiling tgui..."
cd "$1"
env TG_BOOTSTRAP_CACHE="$original_dir" TG_BOOTSTRAP_NODE_LINUX=1 CBT_BUILD_MODE="TGS" tools/bootstrap/node tools/build/build.js
