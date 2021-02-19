#!/usr/bin/env bash
#

set -ex


#
# Install system packages when those are acceptable for dependencies.
#
if [[ "$ASWF_ORG" != ""  ]] ; then
    # Using ASWF CentOS container

    export PATH=/opt/rh/devtoolset-6/root/usr/bin:/usr/local/bin:$PATH

    #ls /etc/yum.repos.d

    sudo yum install -y giflib giflib-devel && true
    sudo yum install -y opencv opencv-devel && true
    sudo yum install -y Field3D Field3D-devel && true
    sudo yum install -y ffmpeg ffmpeg-devel && true

else
    # Using native Ubuntu runner

    sudo add-apt-repository ppa:ubuntu-toolchain-r/test
    time sudo apt-get update

    time sudo apt-get -q install -y \
        git cmake ninja-build ccache g++ \
        libboost-dev libboost-thread-dev \
        libboost-filesystem-dev libboost-regex-dev \
        libilmbase-dev libopenexr-dev \
        python-dev python-numpy \
        libtbb-dev \
        libtiff-dev libgif-dev libpng-dev \
        opencolorio-tools


    export CMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu:$CMAKE_PREFIX_PATH

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
    elif [[ "$CXX" == "g++-10" ]] ; then
        time sudo apt-get install -y g++-10
    fi

fi



#
# If we're using clang to compile on native Ubuntu, we need to install it.
# If on an ASWF CentOS docker container, it already is installed.
#
if [[ "$CXX" == "clang++" && "$ASWF_ORG" == "" ]] ; then
    source src/build-scripts/build_llvm.bash
fi



#
# Packages we need to build from scratch.
#

source src/build-scripts/build_pybind11.bash

if [[ "$OPENEXR_VERSION" != "" ]] ; then
    source src/build-scripts/build_openexr.bash
fi

if [[ "$OPENCOLORIO_VERSION" != "" ]] ; then
    # Temporary (?) fix: GH ninja having problems, fall back to make
    CMAKE_GENERATOR="Unix Makefiles" \
    source src/build-scripts/build_opencolorio.bash
fi

if [[ "$OPENIMAGEIO_VERSION" != "" ]] ; then
    # There are many parts of OIIO we don't need to build
    export ENABLE_iinfo=0 ENABLE_iv=0 ENABLE_igrep=0
    export ENABLE_iconvert=0 ENABLE_testtex=0
    export ENABLE_BMP=0 ENABLE_cineon=0 ENABLE_DDS=0 ENABLE_DPX=0 ENABLE_FITS=0
    export ENABLE_ICO=0 ENABLE_iff=0 ENABLE_jpeg2000=0 ENABLE_PNM=0 ENABLE_PSD=0
    export ENABLE_RLA=0 ENABLE_SGI=0 ENABLE_SOCKET=0 ENABLE_SOFTIMAGE=0
    export ENABLE_TARGA=0 ENABLE_WEBP=0
    export OPENIMAGEIO_MAKEFLAGS="OIIO_BUILD_TESTS=0 USE_PYTHON=0 USE_OPENGL=0"
    source src/build-scripts/build_openimageio.bash
fi
export LD_LIBRARY_PATH=$OpenImageIO_ROOT/lib:$LD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$OpenImageIO_ROOT/lib:$DYLD_LIBRARY_PATH


# Save the env for use by other stages
src/build-scripts/save-env.bash
