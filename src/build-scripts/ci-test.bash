#!/usr/bin/env bash

# Important: set -ex causes this whole script to terminate with error if
# any command in it fails. This is crucial for CI tests.
set -ex

$Proto_ROOT/bin/protobin --help || true

PYTHONPATH=${PWD}/build/$PLATFORM/lib/python/site-packages:$PYTHONPATH
PYTHONPATH=${PWD}/build/$PLATFORM/lib/python/site-packages/${CMAKE_BUILD_TYPE}:$PYTHONPATH

pushd build/$PLATFORM
ctest -C ${CMAKE_BUILD_TYPE} -E broken --force-new-ctest-process --output-on-failure
popd
