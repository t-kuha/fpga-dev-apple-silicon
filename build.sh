#!/bin/sh

# num. of CPU cores
NCPU=$(sysctl -n hw.ncpu)

# create temp. directory
TOP_DIR=$(dirname $(realpath "${BASH_SOURCE[0]}"))
TOOLS_DIR=${TOP_DIR}/tools
LITEX_DIR=${TOP_DIR}/litex
WORK_DIR=${TOP_DIR}/_work
BUILD_DIR=${WORK_DIR}/build
REPOS_DIR=${WORK_DIR}/repos

if [ ! -e ${WORK_DIR} ]; then
    mkdir ${WORK_DIR}
fi
if [ ! -e ${TOOLS_DIR} ]; then
    mkdir ${TOOLS_DIR}
fi
if [ ! -e ${LITEX_DIR} ]; then
    mkdir ${LITEX_DIR}
fi
if [ ! -e ${BUILD_DIR} ]; then
    mkdir ${BUILD_DIR}
fi
if [ ! -e ${REPOS_DIR} ]; then
    mkdir ${REPOS_DIR}
fi

# update PATH env. variable
export PATH=${TOOLS_DIR}/bin:${TOOLS_DIR}/bin/CMake.app/Contents/bin:${PATH}

# sources
if [ ! -e ${REPOS_DIR}/openFPGALoader ]; then
    git clone https://github.com/trabucayre/openFPGALoader.git ${REPOS_DIR}/openFPGALoader -b v0.10.0
fi
if [ ! -e ${REPOS_DIR}/yosys ]; then
    git clone https://github.com/YosysHQ/yosys.git ${REPOS_DIR}/yosys -b yosys-0.28
fi
if [ ! -e ${REPOS_DIR}/nextpnr ]; then
    git clone https://github.com/YosysHQ/nextpnr.git ${REPOS_DIR}/nextpnr -b 051bdb1
fi

# install necessary Python package
pip3 install apycula meson
pip3 cache purge

# ----- build
# openFPGALoader
cmake -S ${REPOS_DIR}/openFPGALoader -B ${BUILD_DIR}/ofl -DCMAKE_PREFIX_PATH=${TOOLS_DIR} -DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release
cmake --build ${BUILD_DIR}/ofl -- -j${NCPU}
cmake --install ${BUILD_DIR}/ofl

# yosys
pushd ${TOP_DIR} > /dev/null
cd ${REPOS_DIR}/yosys
make -j${NCPU} install PREFIX=${TOOLS_DIR} 
popd > /dev/null

# nextpnr
cmake -S ${REPOS_DIR}/nextpnr -B ${BUILD_DIR}/nextpnr -DCMAKE_PREFIX_PATH=${TOOLS_DIR} -DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release -DARCH=gowin
cmake --build ${BUILD_DIR}/nextpnr -- -j${NCPU}
# something bad happens during install, so just copy the compiled artifact
cp ${BUILD_DIR}/nextpnr/nextpnr-gowin ${TOOLS_DIR}/bin
# cmake --install ${BUILD_DIR}/nextpnr

pushd ${TOP_DIR} > /dev/null
cd ${LITEX_DIR}
if [ ! -e litex_setup.py ]; then
    curl -o litex_setup.py https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py
    chmod +x litex_setup.py
fi
./litex_setup.py --init --install
popd > /dev/null
