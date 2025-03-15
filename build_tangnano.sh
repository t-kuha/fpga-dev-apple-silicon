#!/bin/sh

# create LiteX directory etc.
TOP_DIR=$(dirname $(realpath "${BASH_SOURCE[0]}"))
LITEX_DIR=${TOP_DIR}/litex
source ${TOP_DIR}/exports.sh

mkdir -p ${LITEX_DIR}

# sources
# if [ -e ${SRC_DIR}/nextpnr ]; then
#     rm -rf ${SRC_DIR}/nextpnr
# fi
# git clone https://github.com/YosysHQ/nextpnr.git ${SRC_DIR}/nextpnr -b nextpnr-0.7

# install necessary Python packages
# uv pip install apycula meson
# uv cache clean

# ----- build
# nextpnr
# rm -rf ${BUILD_DIR}/nextpnr/_build          # remove existing build
# pushd ${SRC_DIR}/nextpnr > /dev/null
# patch <${TOP_DIR}/patches/nextpnr.patch     # fix coompilation error
# popd > /dev/null
# cmake -S ${SRC_DIR}/nextpnr -B ${BUILD_DIR}/nextpnr/_build \
# -DCMAKE_PREFIX_PATH=${TOOLS_DIR} -DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} \
# -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_RPATH=${TOOLS_DIR}/lib -DARCH=gowin
# cmake --build ${BUILD_DIR}/nextpnr/_build -- -j${NCPU}
# cmake --install ${BUILD_DIR}/nextpnr/_build

# LiteX
pushd ${LITEX_DIR} > /dev/null
if [ ! -e litex_setup.py ]; then
    curl -o litex_setup.py https://raw.githubusercontent.com/enjoy-digital/litex/2024.12/litex_setup.py
    chmod +x litex_setup.py 
    patch litex_setup.py <${TOP_DIR}/patches/litex.patch
fi
# ./litex_setup.py --init --install
popd > /dev/null
