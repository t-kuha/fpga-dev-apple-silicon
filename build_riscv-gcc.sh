#!/bin/sh
#
# reference: https://msyksphinz.hatenablog.com/entry/2022/05/23/040000
#

# create temp. directory
TOP_DIR=$(dirname $(realpath "${BASH_SOURCE[0]}"))
source ${TOP_DIR}/exports.sh

if [ ! -e ${TOOLS_DIR} ]; then
    echo "tools directory not found, exitting..."
    exit
fi
mkdir -p ${WORK_DIR}

# ----- install Ninja
uv pip install ninja

# ----- gcc
export RISCV=${TOOLS_DIR}

if [ -e ${WORK_DIR}/riscv-gnu-toolchain ]; then
    rm -rf ${WORK_DIR}/riscv-gnu-toolchain
fi
git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git ${WORK_DIR}/riscv-gnu-toolchain -b 2025.01.20
pushd ${WORK_DIR}/riscv-gnu-toolchain > /dev/null
git submodule sync
git submodule update --init --recursive

if [ -e build ]; then
    rm -rf build
fi
mkdir build && pushd build > /dev/null
../configure --prefix=${TOOLS_DIR} --enable-multilib --disable-gdb
make -j${NCPU}
popd > /dev/null
