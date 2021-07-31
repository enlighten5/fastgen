#!/bin/bash
BIN_PATH=$(readlink -f "$0")
ROOT_DIR=$(dirname $(dirname $BIN_PATH))

set -euxo pipefail

PREFIX1=${PREFIX:-${ROOT_DIR}/bin/}
PREFIX2=${PREFIX:-${ROOT_DIR}/bin_ang/}

unset CXXFLAGS
unset CFLAGS
cd fuzzer/cpp_core
rm -rf build
mkdir -p build
cd build
cmake .. && make -j
cd ../../..

cargo build
cargo build --release

rm -rf ${PREFIX2}
mkdir -p ${PREFIX2}
mkdir -p ${PREFIX2}/lib
#cp target/release/fuzzer ${PREFIX2}
cp target/release/*.a ${PREFIX2}/lib


pushd llvm_mode
rm -rf build
mkdir -p build
pushd build
CC=clang-6.0 CXX=clang++-6.0 cmake -DCMAKE_INSTALL_PREFIX=${PREFIX1} -DCMAKE_BUILD_TYPE=Release ..
make -j
make install
popd
popd

pushd llvm_mode_angora
rm -rf build
mkdir -p build
pushd build
CC=clang-6.0 CXX=clang++-6.0 cmake -DCMAKE_INSTALL_PREFIX=${PREFIX2} -DCMAKE_BUILD_TYPE=Release ..
make -j
make install
popd
popd
