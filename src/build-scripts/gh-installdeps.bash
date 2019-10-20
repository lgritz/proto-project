#!/usr/bin/env bash
#

set -ex

#dpkg --list

sudo add-apt-repository ppa:ubuntu-toolchain-r/test
time sudo apt-get update

time sudo apt-get -q install -y \
    git \
    cmake \
    ninja-build \
    g++ \
    ccache \
    libboost-dev libboost-thread-dev \
    libboost-filesystem-dev libboost-regex-dev \
    libtiff-dev \
    libilmbase-dev libopenexr-dev \
    python-dev python-numpy \
    libgif-dev \
    libpng-dev \
    opencolorio-tools


# Disable libheif on CI for now... seems to make crashes in CI tests.
# Works fine for me in real life. Investigate.
#if [[ "$USE_LIBHEIF" != "0" ]] ; then
#    sudo add-apt-repository ppa:strukturag/libde265
#    sudo add-apt-repository ppa:strukturag/libheif
#    time sudo apt-get -q install -y libheif-dev
#fi

if [[ "$CXX" == "g++-4.8" ]] ; then
    time sudo apt-get install -y g++-4.8
elif [[ "$CXX" == "g++-6" ]] ; then
    time sudo apt-get install -y g++-6
elif [[ "$CXX" == "g++-7" ]] ; then
    time sudo apt-get install -y g++-7
elif [[ "$CXX" == "g++-8" ]] ; then
    time sudo apt-get install -y g++-8
elif [[ "$CXX" == "g++-9" ]] ; then
    time sudo apt-get install -y g++-9
fi

# time sudo apt-get install -y clang
# time sudo apt-get install -y llvm
#time sudo apt-get install -y libopenjpeg-dev
#time sudo apt-get install -y libjpeg-turbo8-dev

#dpkg --list

CMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu:$CMAKE_PREFIX_PATH


CXX="ccache $CXX" source src/build-scripts/build_openexr.bash
CXX="ccache $CXX" source src/build-scripts/build_ocio.bash

OPENIMAGEIO_MAKEFLAGS="OIIO_BUILD_TESTS=0 USE_PYTHON=0 USE_OPENGL=0"
source src/build-scripts/build_openimageio.bash
