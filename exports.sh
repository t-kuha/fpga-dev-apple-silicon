#!/bin/sh

function make_dir () {
    if [ ! -e $1 ]; then
        mkdir -p $1
    fi
}


echo "[INFO] exporting PATH etc."

# num. of CPU cores
NCPU=$(sysctl -n hw.ncpu)

# create directories
TOP_DIR=$(dirname $(realpath $0))
TOOLS_DIR=${TOP_DIR}/tools
TOOLS_BIN_DIR=${TOOLS_DIR}/bin
WORK_DIR=${TOP_DIR}/_work
SRC_DIR=${WORK_DIR}/src
BUILD_DIR=${WORK_DIR}/build

# create directories
make_dir ${TOOLS_DIR}
make_dir ${TOOLS_BIN_DIR}
make_dir ${WORK_DIR}
make_dir ${SRC_DIR}
make_dir ${BUILD_DIR}

# update PATH env. variable
export PATH=${TOOLS_DIR}/bin:${TOOLS_DIR}/bin/CMake.app/Contents/bin:${PATH}

# Python virtual env.
source ${TOP_DIR}/.venv/bin/activate

echo "[INFO] done."
