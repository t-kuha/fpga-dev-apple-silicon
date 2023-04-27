#!/bin/sh
#
# reference: https://msyksphinz.hatenablog.com/entry/2022/05/23/040000
#

# create temp. directory
TOP_DIR=$(dirname $(realpath "${BASH_SOURCE[0]}"))
TOOLS_DIR=${TOP_DIR}/tools
GCC_DIR=${TOP_DIR}/_work/gcc

if [ ! -e ${TOOLS_DIR} ]; then
    echo "tools directory not found, exitting..."
    exit
fi
if [ ! -e ${GCC_DIR} ]; then
    mkdir -p ${GCC_DIR}
fi

export PATH=${TOOLS_DIR}/bin:${PATH}

# ----- 
pip install ninja

# ----- gcc
export RISCV=${TOOLS_DIR}
if [ ! -e ${GCC_DIR}/riscv-gnu-toolchain ]; then
    mkdir -p ${GCC_DIR}
    git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git ${GCC_DIR}/riscv-gnu-toolchain -b 2022.05.15
    pushd ${TOP_DIR} > /dev/null
    cd ${GCC_DIR}/riscv-gnu-toolchain
    git submodule sync
    git submodule update --init --recursive
    popd > /dev/null
fi
pushd ${TOP_DIR} > /dev/null
cd ${GCC_DIR}/riscv-gnu-toolchain
if [ ! -e build ]; then
    mkdir build
fi
cd build
../configure --prefix=${TOOLS_DIR}
make -j8
popd > /dev/null
