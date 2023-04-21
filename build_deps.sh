#!/bin/sh

function downloadsrc () {
    # usage: downloadsrc <url> <tar_name> <lib_name>
    url=$1
    tar_name=$2
    lib_name=$3
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

# set up env.
export PATH=${PATH}:~/Documents/programs/cmake/CMake.app/Contents/bin

# create temp. directory
TOP_DIR=$(dirname $(realpath "${BASH_SOURCE[0]}"))
DEPS_DIR=${TOP_DIR}/_deps
SRC_DIR=${TOP_DIR}/src
BUILD_DIR=${TOP_DIR}/_build
TOOLS_DIR=${TOP_DIR}/tools

if [ ! -e ${DEPS_DIR} ]; then
    mkdir ${DEPS_DIR}
fi
if [ ! -e ${SRC_DIR} ]; then
    mkdir ${SRC_DIR}
fi
if [ ! -e ${BUILD_DIR} ]; then
    mkdir ${BUILD_DIR}
fi
if [ ! -e ${TOOLS_DIR} ]; then
    mkdir -p ${TOOLS_DIR}/bin
fi
export PATH=${TOOLS_DIR}/bin:${TOOLS_DIR}/bin/CMake.app/Contents/bin:${PATH}

# ----- prepare CMake
if [ ! -e ${TOOLS_DIR}/bin/CMake.app ]; then
    curl -L -o ${SRC_DIR}/cmake.tar.gz https://github.com/Kitware/CMake/releases/download/v3.26.3/cmake-3.26.3-macos-universal.tar.gz
    tar xf cmake.tar.gz -C tools/bin --strip-components 1
fi

# ----- download sources
downloadsrc \
https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz \
pkg-config.tar.gz pkg-config

downloadsrc \
https://github.com/libusb/libusb/releases/download/v1.0.26/libusb-1.0.26.tar.bz2 \
libusb.tar.bz2 libusb

downloadsrc \
https://www.intra2net.com/en/developer/libftdi/download/libftdi1-1.4.tar.bz2 \
libftdi1.tar.bz2 libftdi1

downloadsrc \
https://www.zlib.net/zlib-1.2.13.tar.xz \
zlib.tar.xz zlib

downloadsrc \
https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz \
readline.tar.gz readline

downloadsrc \
https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz \
bison.tar.xz bison

downloadsrc \
https://github.com/libffi/libffi/releases/download/v3.4.4/libffi-3.4.4.tar.gz \
libffi.tar.gz libffi

downloadsrc \
https://www.openssl.org/source/openssl-3.1.0.tar.gz \
openssl.tar.gz openssl

downloadsrc \
https://www.python.org/ftp/python/3.11.3/Python-3.11.3.tar.xz \
Python.tar.xz Python

downloadsrc \
https://boostorg.jfrog.io/artifactory/main/release/1.82.0/source/boost_1_82_0.tar.gz \
boost.tar.gz boost

downloadsrc \
https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz \
eigen.tar.gz eigen

# ----- build
# pkg-config
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/pkg-config
./configure --prefix=${TOOLS_DIR} --with-internal-glib
make -j8 install
popd > /dev/null

# libusb
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/libusb
./configure --prefix=${TOOLS_DIR}
make -j8 install
popd > /dev/null

# libftdi1
cmake -S ${DEPS_DIR}/libftdi1 -B ${BUILD_DIR}/libftdi -DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF -DSTATICLIBS=OFF
cmake --build ${BUILD_DIR}/libftdi -- -j8
cmake --install ${BUILD_DIR}/libftdi

# zlib
cmake -S ${DEPS_DIR}/zlib -B ${BUILD_DIR}/zlib -DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release
cmake --build ${BUILD_DIR}/zlib -- -j8
cmake --install ${BUILD_DIR}/zlib

# readline
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/readline
./configure --prefix=${TOOLS_DIR}
make -j8 install
popd > /dev/null

# bison
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/bison
./configure --prefix=${TOOLS_DIR}
make -j8 install
popd > /dev/null

# libffi
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/libffi
./configure --prefix=${TOOLS_DIR}
make -j8 install
popd > /dev/null

# libssl
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/openssl
./Configure --prefix=${TOOLS_DIR}
make -j8 
make install
popd > /dev/null

# Python
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/Python
./configure --prefix=${TOOLS_DIR} --enable-optimizations --with-openssl=${TOOLS_DIR}
make -j8
make install
# python3 -> python
pushd ${TOP_DIR} > /dev/null
cd ${TOOLS_DIR}/bin
ln -s python3 python
popd > /dev/null
popd > /dev/null

# boost
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/boost
./bootstrap.sh --prefix=${TOOLS_DIR}
./b2 variant=release link=shared threading=multi runtime-link=shared --prefix=${TOOLS_DIR} --with-filesystem --with-thread  --with-program_options --with-iostreams --with-system install
popd > /dev/null

# eigen
cmake -S ${DEPS_DIR}/eigen -B ${BUILD_DIR}/eigen -DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release
cmake --build ${BUILD_DIR}/eigen -- -j8
cmake --install ${BUILD_DIR}/eigen