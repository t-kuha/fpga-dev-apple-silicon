#!/bin/sh

function downloadsrc () {
    # usage: downloadsrc <url> <tar_name w/o version>
    url=$1
    tar_name=$2
    lib_name=${tar_name%%.*}
    # download
    if [ ! -e ${SRC_DIR}/${tar_name} ]; then
        curl -L -o ${SRC_DIR}/${tar_name} ${url}
        if [ ! $? -eq 0 ]; then
            echo "[ERROR] curl/download failed..."
        fi
    fi
    # extract
    if [ ! -e ${BUILD_DIR}/${lib_name} ]; then
        mkdir ${BUILD_DIR}/${lib_name}
        tar xf ${SRC_DIR}/${tar_name} -C ${BUILD_DIR}/${lib_name} --strip-components 1
        if [ ! $? -eq 0 ]; then
            echo "[ERROR] tar failed..."
        fi
    fi
}

echo "----- building dependencies -----"

TOP_DIR=$(dirname $(realpath "${BASH_SOURCE[0]}"))
source ${TOP_DIR}/exports.sh

# ----- prepare CMake
if [ ! -e ${TOOLS_DIR}/bin/CMake.app ]; then
    curl -L -o ${SRC_DIR}/cmake.tar.gz \
    https://github.com/Kitware/CMake/releases/download/v3.31.6/cmake-3.31.6-macos-universal.tar.gz
    tar xf ${SRC_DIR}/cmake.tar.gz -C tools/bin --strip-components 1
fi

# ----- download sources
downloadsrc \
https://ftp.gnu.org/gnu/gawk/gawk-5.3.1.tar.xz \
gawk.tar.xz

downloadsrc \
https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz \
sed-4.9.tar.xz

downloadsrc \
https://ftp.gnu.org/gnu/texinfo/texinfo-7.2.tar.xz \
texinfo.tar.xz

downloadsrc \
https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz \
m4.tar.xz

downloadsrc \
https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz \
pkg-config.tar.gz

downloadsrc \
https://github.com/libusb/libusb/releases/download/v1.0.27/libusb-1.0.27.tar.bz2 \
libusb.tar.bz2

downloadsrc \
https://www.intra2net.com/en/developer/libftdi/download/libftdi1-1.4.tar.bz2 \
libftdi1.tar.bz2

downloadsrc \
https://www.zlib.net/zlib-1.3.1.tar.xz \
zlib.tar.xz

downloadsrc \
https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz \
readline.tar.gz

downloadsrc \
https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz \
bison.tar.xz

downloadsrc \
https://github.com/libffi/libffi/releases/download/v3.4.7/libffi-3.4.7.tar.gz \
libffi.tar.gz

downloadsrc \
https://www.openssl.org/source/openssl-3.4.1.tar.gz \
openssl.tar.gz

downloadsrc \
https://archives.boost.io/release/1.87.0/source/boost_1_87_0.tar.bz2 \
boost.tar.gz

downloadsrc \
https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz \
eigen.tar.gz

if [ -e ${SRC_DIR}/openFPGALoader ]; then
    # remove exsiting one / start fresh
    rm -rf ${SRC_DIR}/openFPGALoader
fi
git clone https://github.com/trabucayre/openFPGALoader.git ${SRC_DIR}/openFPGALoader -b v0.13.1
if [ -e ${SRC_DIR}/yosys ]; then
    rm -rf ${SRC_DIR}/yosys
fi
git clone https://github.com/YosysHQ/yosys.git ${SRC_DIR}/yosys -b v0.51

# ----- build
# gawk
pushd ${BUILD_DIR}/gawk > /dev/null
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# sed
pushd ${BUILD_DIR}/sed > /dev/null
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# texinfo
pushd ${BUILD_DIR}/texinfo > /dev/null
./configure --prefix=${TOOLS_DIR} --disable-perl-xs
make -j${NCPU} install
popd > /dev/null

# m4
pushd ${BUILD_DIR}/m4 > /dev/null
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# pkg-config
pushd ${BUILD_DIR}/pkg-config > /dev/null
./configure --prefix=${TOOLS_DIR} --with-internal-glib CFLAGS="-g -O2 -Wno-int-conversion"
make -j${NCPU} install
popd > /dev/null

# libusb
pushd ${BUILD_DIR}/libusb > /dev/null
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# libftdi1
cmake -S ${BUILD_DIR}/libftdi1 -B ${BUILD_DIR}/libftdi1/_build \
-DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release \
-DBUILD_TESTS=OFF -DSTATICLIBS=OFF -DCMAKE_INSTALL_NAME_DIR=${TOOLS_DIR}/lib
cmake --build ${BUILD_DIR}/libftdi1/_build -- -j${NCPU}
cmake --install ${BUILD_DIR}/libftdi1/_build

# zlib
cmake -S ${BUILD_DIR}/zlib -B ${BUILD_DIR}/zlib/_build \
-DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release
cmake --build ${BUILD_DIR}/zlib/_build -- -j${NCPU}
cmake --install ${BUILD_DIR}/zlib/_build

# readline
pushd ${BUILD_DIR}/readline > /dev/null
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# bison
pushd ${BUILD_DIR}/bison > /dev/null
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# libffi
pushd ${BUILD_DIR}/libffi > /dev/null
./configure --prefix=${TOOLS_DIR}
make -j${NCPU} install
popd > /dev/null

# libssl
pushd ${BUILD_DIR}/openssl > /dev/null
./Configure --prefix=${TOOLS_DIR}
make -j${NCPU} 
make install
popd > /dev/null

# boost
pushd ${BUILD_DIR}/boost
./bootstrap.sh --prefix=${TOOLS_DIR}
./b2 variant=release link=shared threading=multi runtime-link=shared \
--prefix=${TOOLS_DIR} --with-filesystem --with-thread --with-program_options --with-iostreams --with-system install
popd > /dev/null

# eigen
cmake -S ${BUILD_DIR}/eigen -B ${BUILD_DIR}/eigen/_build -DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release
cmake --build ${BUILD_DIR}/eigen/_build -- -j${NCPU}
cmake --install ${BUILD_DIR}/eigen/_build

# openFPGALoader
rm -r ${BUILD_DIR}/ofl
cmake -S ${SRC_DIR}/openFPGALoader -B ${BUILD_DIR}/openFPGALoader \
-DCMAKE_PREFIX_PATH=${TOOLS_DIR} -DCMAKE_INSTALL_PREFIX=${TOOLS_DIR} -DCMAKE_BUILD_TYPE=Release \
-DENABLE_CMSISDAP=OFF -DCMAKE_INSTALL_RPATH=${TOOLS_DIR}/lib
cmake --build ${BUILD_DIR}/openFPGALoader -- -j${NCPU}
cmake --install ${BUILD_DIR}/openFPGALoader

# yosys
patch ${SRC_DIR}/yosys/Makefile ${TOP_DIR}/patches/yosys.patch  # do not use Homebrew
pushd ${SRC_DIR}/yosys
git submodule update --init
make -j${NCPU} install PREFIX=${TOOLS_DIR} 
popd > /dev/null

echo "----- done. -----"
