#!/bin/sh
#
# reference: https://msyksphinz.hatenablog.com/entry/2022/05/23/040000
#

# num. of CPU cores
NCPU=$(sysctl -n hw.ncpu)

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

# ----- install Ninja
pip install ninja

# ----- gcc
export RISCV=${TOOLS_DIR}
if [ -e ${GCC_DIR}/riscv-gnu-toolchain ]; then
    rm -rf ${GCC_DIR}/riscv-gnu-toolchain
fi
mkdir -p ${GCC_DIR}
git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git ${GCC_DIR}/riscv-gnu-toolchain -b 2023.07.07
pushd ${TOP_DIR} > /dev/null
cd ${GCC_DIR}/riscv-gnu-toolchain
git submodule sync
git submodule update --init --recursive
popd > /dev/null
pushd ${TOP_DIR} > /dev/null

cd ${GCC_DIR}/riscv-gnu-toolchain
if [ ! -e build ]; then
    mkdir build
fi
cd build
../configure --prefix=${TOOLS_DIR}
make -j${NCPU}
popd > /dev/null
