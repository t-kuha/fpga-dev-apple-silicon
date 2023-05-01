#!/bin/sh

function make_dir () {
    if [ ! -e $1 ]; then
        mkdir $1
    fi
}

# num. of CPU cores
NCPU=$(sysctl -n hw.ncpu)

# create temp. directory
TOP_DIR=$(dirname $(realpath "${BASH_SOURCE[0]}"))
TOOLS_DIR=${TOP_DIR}/tools
LITEX_DIR=${TOP_DIR}/litex
WORK_DIR=${TOP_DIR}/_work
BUILD_DIR=${WORK_DIR}/build
REPOS_DIR=${WORK_DIR}/repos

make_dir ${WORK_DIR}
make_dir ${TOOLS_DIR}
make_dir ${LITEX_DIR}
make_dir ${BUILD_DIR}
make_dir ${REPOS_DIR}

# update PATH env. variable
export PATH=${TOOLS_DIR}/bin:${TOOLS_DIR}/bin/CMake.app/Contents/bin:${PATH}

# sources
if [ ! -e ${REPOS_DIR}/nextpnr ]; then
    git clone https://github.com/YosysHQ/nextpnr.git ${REPOS_DIR}/nextpnr -b 051bdb1
fi

# install necessary Python package
pip3 install apycula meson
pip3 cache purge

# ----- build
# nextpnr
cmake -S ${REPOS_DIR}/nextpnr -B ${BUILD_DIR}/nextpnr -DCMAKE_PREFIX_PATH=${TOOLS_DIR} -DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release -DARCH=gowin
cmake --build ${BUILD_DIR}/nextpnr -- -j${NCPU}
# something bad happens during install, so just copy the compiled artifact
cp ${BUILD_DIR}/nextpnr/nextpnr-gowin ${TOOLS_DIR}/bin
# cmake --install ${BUILD_DIR}/nextpnr

# LiteX
pushd ${TOP_DIR} > /dev/null
cd ${LITEX_DIR}
if [ ! -e litex_setup.py ]; then
    curl -o litex_setup.py https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py
    chmod +x litex_setup.py
fi
./litex_setup.py --init --install
popd > /dev/null