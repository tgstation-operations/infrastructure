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

cargo build --ignore-rust-version --release --target=i686-unknown-linux-gnu --features all
mv target/i686-unknown-linux-gnu/release/librust_g.so "$1/librust_g.so"

# compile tgui
echo "Compiling tgui..."
cd "$1"
chmod +x tools/bootstrap/node  # Workaround for https://github.com/tgstation/tgstation-server/issues/1167
env TG_BOOTSTRAP_CACHE="$original_dir" TG_BOOTSTRAP_NODE_LINUX=1 CBT_BUILD_MODE="TGS" tools/bootstrap/node tools/build/build.js
