#!/bin/sh
#
# reference: https://msyksphinz.hatenablog.com/entry/2022/05/23/040000
#

# num. of CPU cores
NCPU=$(sysctl -n hw.ncpu)

# create temp. directory
TOP_DIR=$(dirname $(realpath "${BASH_SOURCE[0]}"))
TOOLS_DIR=${TOP_DIR}/tools
WORK_DIR=${TOP_DIR}/_work

if [ ! -e ${TOOLS_DIR} ]; then
    echo "tools directory not found, exitting..."
    exit
fi
if [ ! -e ${WORK_DIR} ]; then
    mkdir -p ${WORK_DIR}
fi

export PATH=${TOOLS_DIR}/bin:${PATH}

# ----- install Ninja
pip install ninja

# ----- gcc
export RISCV=${TOOLS_DIR}

if [ -e ${WORK_DIR}/riscv-gnu-toolchain ]; then
    rm -rf ${WORK_DIR}/riscv-gnu-toolchain
fi
git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git ${WORK_DIR}/riscv-gnu-toolchain -b 2023.07.07
pushd ${TOP_DIR} > /dev/null
cd ${WORK_DIR}/riscv-gnu-toolchain
git submodule sync
git submodule update --init --recursive

if [ -e build ]; then
    rm -rf build
fi
mkdir build && cd build
../configure --prefix=${TOOLS_DIR} --enable-multilib
make -j${NCPU}
popd > /dev/null
