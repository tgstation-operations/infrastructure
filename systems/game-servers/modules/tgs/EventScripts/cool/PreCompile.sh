#!/usr/bin/env bash

set -ex

# move to deployment folder
cd "$1"

# load dependencies
. dependencies.sh

# create a dedicated folder for running the script
work_directory="${TGS_INSTANCE_ROOT}/Configuration/EventScriptsScratch"
mkdir -p $work_directory

cd $work_directory

export TARGET_CC=$(which clang)
export TARGET_CXX=$(which clang++)
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
#cargo build --ignore-rust-version --release --target=i686-unknown-linux-gnu
#cp target/i686-unknown-linux-gnu/release/libauxcpu_byondapi.so "$1/libauxcpu_byondapi.so"

# EMERGENCY FIX, SOMETHING IS WRONG WITH THE ABOVE
cp "${TGS_INSTANCE_ROOT}/Configuration/EventScripts.old/libauxcpu_byondapi.so" "$1/libauxcpu_byondapi.so"

cd "$work_directory"
echo "auxcpu: deployment finish"

# Change the build day & month, and all that, so we get nice snazzy holiday/event
# stuff. (e.g. Halloween, Xmas, etc.)


# match    V   this       V  & 1 or more nums - replace with matched bit in parens, plus the relevant day/month/hour/minute
sed -Ei "s/(BUILD_TIME_DAY)\s+[[:digit:]]+/\1 `date +%-d`/" "${1}/_std/__build.dm"
sed -Ei "s/(BUILD_TIME_MONTH)\s+[[:digit:]]+/\1 `date +%-m`/" "${1}/_std/__build.dm"
sed -Ei "s/(BUILD_TIME_HOUR)\s+[[:digit:]]+/\1 `date +%-H`/" "${1}/_std/__build.dm"
sed -Ei "s/(BUILD_TIME_MINUTE)\s+[[:digit:]]+/\1 `date +%-M`/" "${1}/_std/__build.dm"

RSC_URL="https\:\/\/rsc.tgstation13.org\/coolstation.rsc.zip"
sed -Er "s/(\#define.PRELOAD_RSC_URL\s+).+/\1\"${RSC_URL}\"/g" "${1}/_std/__build.dm"

echo "injected time and date to build.dm"
