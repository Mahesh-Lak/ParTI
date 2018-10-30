#!/bin/bash

set -e

echo "This script will do an out-of-tree build of ParTI into the 'build' directory."

# If you have GCC >= 6.0 and CUDA <= 8.0,
# write this into 'build.config': -DCUDA_HOST_COMPILER=gcc-5
# You can also write other configuation flags into 'build.config'
declare -a CMAKE_FLAGS
[ -e build.config ] && CMAKE_FLAGS=("${CMAKE_FLAGS[@]}" $(<build.config))
CMAKE_FLAGS=("${CMAKE_FLAGS[@]}" "$@")
# CMAKE_FLAGS=("${CMAKE_FLAGS[@]}" "-DUSE_ICC=ON" "$@")

mkdir -p build
cd build

CC=icc CXX=icpc cmake "${CMAKE_FLAGS[@]}" ..
# CC=gcc CXX=g++ cmake "${CMAKE_FLAGS[@]}" ..
# cmake "${CMAKE_FLAGS[@]}" .. 		# Use Default cc and CC

make

echo "Finished. Check the 'build' directory for results."