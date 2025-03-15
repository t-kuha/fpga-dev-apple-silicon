#!/bin/sh

echo "[INFO] exporting PATH etc."

# num. of CPU cores
NCPU=$(sysctl -n hw.ncpu)

# create directories
TOP_DIR=$(dirname $(realpath $0))
TOOLS_DIR=${TOP_DIR}/tools
WORK_DIR=${TOP_DIR}/_work
SRC_DIR=${WORK_DIR}/src
BUILD_DIR=${WORK_DIR}/build

# update PATH env. variable
export PATH=${TOOLS_DIR}/bin:${TOOLS_DIR}/bin/CMake.app/Contents/bin:${PATH}

echo "[INFO] done."
