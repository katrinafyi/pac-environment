#!/bin/bash

# downloads and compiles a build of LLVM with RTTI and EH enabled.

set -e

VERSION=15.0.3
NAME=llvm-project-$VERSION
FILE=$NAME.src.tar.xz
URL=https://github.com/llvm/llvm-project/releases/download/llvmorg-$VERSION/$FILE

wget -N $URL
tar xvf $FILE

cd $NAME.src
mkdir -p build
cd build

NEW_NAME=$NAME+rtti
PREFIX=`pwd`/$NEW_NAME

PATH=$PATH:$HOME
cmake -GNinja -DCMAKE_INSTALL_PREFIX="$PREFIX" -DLLVM_ENABLE_RTTI=ON -DLLVM_ENABLE_EH=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_PROJECTS="llvm;clang" ../llvm
ninja
ninja install

tar czf $NEW_NAME.tar.gz $PREFIX


