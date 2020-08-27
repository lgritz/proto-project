#!/usr/bin/env bash

# Important: set -ex causes this whole script to terminate with error if
# any command in it fails. This is crucial for CI tests.
set -ex

# This script is run when CI system first starts up.
# It expects that ci-setenv.bash was run first, so $PLATFORM and $ARCH
# have been set.

if [[ -e src/build-scripts/ci-setenv.bash ]] ; then
    source src/build-scripts/ci-setenv.bash
fi

mkdir -p build/$PLATFORM dist/$PLATFORM && true

if [[ "$USE_SIMD" != "" ]] ; then
    MY_CMAKE_FLAGS="$MY_CMAKE_FLAGS -DUSE_SIMD=$USE_SIMD"
fi
if [[ "$DEBUG" == "1" ]] ; then
    export CMAKE_BUILD_TYPE=Debug
fi

pushd build/$PLATFORM
cmake ../.. -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
        -DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH" \
        -DCMAKE_INSTALL_PREFIX="$Proto_ROOT" \
        -DPYTHON_VERSION="$PYTHON_VERSION" \
        -DCMAKE_INSTALL_LIBDIR="$Proto_ROOT/lib" \
        -DCMAKE_CXX_STANDARD="$CMAKE_CXX_STANDARD" \
        $MY_CMAKE_FLAGS -DVERBOSE=1
if [[ "$BUILDTARGET" != "none" ]] ; then
    echo "Parallel build " ${CMAKE_BUILD_PARALLEL_LEVEL}
    time cmake --build . --target ${BUILDTARGET:=install} --config ${CMAKE_BUILD_TYPE}
fi
popd

echo "Proto_ROOT $Proto_ROOT"
#ls -R -l "$Proto_ROOT"
#ls -R -l build

# Make sure it knows where to find OIIO
export LD_LIBRARY_PATH=$OpenImageIO_ROOT/lib:$LD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$OpenImageIO_ROOT/lib:$DYLD_LIBRARY_PATH

if [[ "${DEBUG_CI:=0}" != "0" ]] ; then
    echo "PATH=$PATH"
    echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
    echo "PYTHONPATH=$PYTHONPATH"
    echo "ldd protobin"
    ldd $Proto_ROOT/bin/protobin
fi

if [[ "${SKIP_TESTS:=0}" == "0" ]] ; then
    $Proto_ROOT/bin/protobin --help || true
    PYTHONPATH=${PWD}/build/$PLATFORM/lib/python/site-packages:$PYTHONPATH
    PYTHONPATH=${PWD}/build/$PLATFORM/lib/python/site-packages/${CMAKE_BUILD_TYPE}:$PYTHONPATH
    TESTSUITE_CLEANUP_ON_SUCCESS=1
    pushd build/$PLATFORM
    ctest -C ${CMAKE_BUILD_TYPE} -E broken --force-new-ctest-process --output-on-failure
    popd
fi

if [[ "$BUILDTARGET" == clang-format ]] ; then
    git diff --color
    THEDIFF=`git diff`
    if [[ "$THEDIFF" != "" ]] ; then
        echo "git diff was not empty. Failing clang-format or clang-tidy check."
        exit 1
    fi
fi

# if [[ "$CODECOV" == 1 ]] ; then
#     bash <(curl -s https://codecov.io/bash)
# fi
