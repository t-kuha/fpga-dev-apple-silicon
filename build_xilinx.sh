#!/bin/sh
#
# TODO: add Ultrascale+ support
#

# functions
function make_dir () {
    if [ ! -e $1 ]; then
        mkdir $1
    fi
}

function downloadsrc () {
    # usage: downloadsrc <url> <tar_name w/o version>
    url=$1
    tar_name=$2
    lib_name=${tar_name%%.*}
    # donwload
    if [ ! -e ${SRC_DIR}/${tar_name} ]; then
        curl -L -o ${SRC_DIR}/${tar_name} ${url}
    fi
    # extract
    if [ ! -e ${DEPS_DIR}/${lib_name} ]; then
        mkdir ${DEPS_DIR}/${lib_name}
        tar xf ${SRC_DIR}/${tar_name} -C ${DEPS_DIR}/${lib_name} --strip-components 1
    fi
}

# num. of CPU cores
NCPU=$(sysctl -n hw.ncpu)

# create temp. directory
TOP_DIR=$(dirname $(realpath "${BASH_SOURCE[0]}"))
TOOLS_DIR=${TOP_DIR}/tools
WORK_DIR=${TOP_DIR}/_work
DEPS_DIR=${WORK_DIR}/deps
SRC_DIR=${WORK_DIR}/src
BUILD_DIR=${WORK_DIR}/build
REPOS_DIR=${WORK_DIR}/repos

# create working directories
make_dir ${WORK_DIR}
make_dir ${DEPS_DIR}
make_dir ${SRC_DIR}
make_dir ${TOOLS_DIR}
make_dir ${BUILD_DIR}
make_dir ${REPOS_DIR}

export PATH=${TOOLS_DIR}/bin:${TOOLS_DIR}/bin/CMake.app/Contents/bin:${PATH}

# prjxray
if [ ! -e ${REPOS_DIR}/prjxray ]; then
    pushd ${TOP_DIR} > /dev/null
    git clone https://github.com/f4pga/prjxray.git ${REPOS_DIR}/prjxray
    cd ${REPOS_DIR}/prjxray
    git submodule update --init --recursive
    popd > /dev/null
fi
cmake -S ${REPOS_DIR}/prjxray -B ${BUILD_DIR}/prjxray -DCMAKE_PREFIX_PATH=${TOOLS_DIR} -DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=14
cmake --build ${BUILD_DIR}/prjxray -- -j${NCPU}
cmake --install ${BUILD_DIR}/prjxray

pushd ${TOP_DIR} > /dev/null
cd ${REPOS_DIR}/prjxray
./download-latest-db.sh
popd > /dev/null

# nexpnr-xilinx
if [ ! -e ${REPOS_DIR}/nextpnr-xilinx ]; then
    pushd ${TOP_DIR} > /dev/null
    git clone https://github.com/gatecat/nextpnr-xilinx.git ${REPOS_DIR}/nextpnr-xilinx

    cd ${REPOS_DIR}/nextpnr-xilinx
    git submodule update --init --recursive
    popd > /dev/null
fi
cmake -S ${REPOS_DIR}/nextpnr-xilinx -B ${BUILD_DIR}/nextpnr-xilinx -DCMAKE_PREFIX_PATH=${TOOLS_DIR} -DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release -DARCH=xilinx
cmake --build ${BUILD_DIR}/nextpnr-xilinx -- -j${NCPU}
# FIXME: rpath
# cmake --install ${BUILD_DIR}/nextpnr-xilinx
cp ${BUILD_DIR}/nextpnr-xilinx/nextpnr-xilinx ${TOOLS_DIR}/bin
cp ${BUILD_DIR}/nextpnr-xilinx/bba/bbasm ${TOOLS_DIR}/bin
