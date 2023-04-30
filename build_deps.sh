#!/bin/sh

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

if [ ! -e ${TOOLS_DIR} ]; then
    mkdir -p ${TOOLS_DIR}/bin
fi
if [ ! -e ${WORK_DIR} ]; then
    mkdir ${WORK_DIR}
fi
if [ ! -e ${DEPS_DIR} ]; then
    mkdir ${DEPS_DIR}
fi
if [ ! -e ${SRC_DIR} ]; then
    mkdir ${SRC_DIR}
fi
if [ ! -e ${BUILD_DIR} ]; then
    mkdir ${BUILD_DIR}
fi

# update PATH env. variable
export PATH=${TOOLS_DIR}/bin:${TOOLS_DIR}/bin/CMake.app/Contents/bin:${PATH}

# ----- prepare CMake
if [ ! -e ${TOOLS_DIR}/bin/CMake.app ]; then
    curl -L -o ${SRC_DIR}/cmake.tar.gz https://github.com/Kitware/CMake/releases/download/v3.26.3/cmake-3.26.3-macos-universal.tar.gz
    tar xf cmake.tar.gz -C tools/bin --strip-components 1
fi

# ----- download sources
downloadsrc \
https://ftp.gnu.org/gnu/gawk/gawk-5.2.1.tar.xz \
gawk.tar.xz

downloadsrc \
https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz \
sed-4.9.tar.xz

downloadsrc \
https://ftp.gnu.org/gnu/texinfo/texinfo-7.0.3.tar.xz \
texinfo.tar.xz

downloadsrc \
https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz \
m4.tar.xz

downloadsrc \
https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz \
pkg-config.tar.gz

downloadsrc \
https://github.com/libusb/libusb/releases/download/v1.0.26/libusb-1.0.26.tar.bz2 \
libusb.tar.bz2

downloadsrc \
https://www.intra2net.com/en/developer/libftdi/download/libftdi1-1.4.tar.bz2 \
libftdi1.tar.bz2

downloadsrc \
https://www.zlib.net/zlib-1.2.13.tar.xz \
zlib.tar.xz

downloadsrc \
https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz \
readline.tar.gz

downloadsrc \
https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz \
bison.tar.xz

downloadsrc \
https://github.com/libffi/libffi/releases/download/v3.4.4/libffi-3.4.4.tar.gz \
libffi.tar.gz

downloadsrc \
https://www.openssl.org/source/openssl-3.1.0.tar.gz \
openssl.tar.gz

downloadsrc \
https://www.python.org/ftp/python/3.11.3/Python-3.11.3.tar.xz \
Python.tar.xz

downloadsrc \
https://boostorg.jfrog.io/artifactory/main/release/1.82.0/source/boost_1_82_0.tar.gz \
boost.tar.gz

downloadsrc \
https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz \
eigen.tar.gz

# ----- build
# gawk
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/gawk
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# sed
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/sed
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# texinfo
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/texinfo
./configure --prefix=${TOOLS_DIR} --disable-perl-xs
make -j${NCPU} install
popd > /dev/null

# m4
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/m4
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# pkg-config
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/pkg-config
./configure --prefix=${TOOLS_DIR} --with-internal-glib
make -j${NCPU} install
popd > /dev/null

# libusb
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/libusb
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# libftdi1
cmake -S ${DEPS_DIR}/libftdi1 -B ${BUILD_DIR}/libftdi -DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF -DSTATICLIBS=OFF -DCMAKE_INSTALL_NAME_DIR=${TOOLS_DIR}/lib
cmake --build ${BUILD_DIR}/libftdi -- -j${NCPU}
cmake --install ${BUILD_DIR}/libftdi

# zlib
cmake -S ${DEPS_DIR}/zlib -B ${BUILD_DIR}/zlib -DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release
cmake --build ${BUILD_DIR}/zlib -- -j${NCPU}
cmake --install ${BUILD_DIR}/zlib

# readline
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/readline
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# bison
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/bison
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# libffi
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/libffi
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# libssl
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/openssl
./Configure --prefix=${TOOLS_DIR}
make -j${NCPU} 
make install
popd > /dev/null

# Python
pushd ${TOP_DIR} > /dev/null
cd ${DEPS_DIR}/Python
./configure --prefix=${TOOLS_DIR} --enable-optimizations --with-openssl=${TOOLS_DIR}
make -j${NCPU}
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
cmake --build ${BUILD_DIR}/eigen -- -j${NCPU}
cmake --install ${BUILD_DIR}/eigen
