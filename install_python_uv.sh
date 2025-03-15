#!/bin/sh

# set env. variables & PATH etc.
TOP_DIR=$(dirname $(realpath $0))
source ${TOP_DIR}/exports.sh

mkdir -p ${TOOLS_BIN_DIR}
mkdir -p ${WORK_DIR}
mkdir -p ${SRC_DIR}
mkdir -p ${BUILD_DIR}

# download & install uv
if [ ! -e ${SRC_DIR}/uv-aarch64-apple-darwin.tar.gz ]; then
    curl -L https://github.com/astral-sh/uv/releases/download/0.6.6/uv-aarch64-apple-darwin.tar.gz \
    --output ${SRC_DIR}/uv-aarch64-apple-darwin.tar.gz
    tar xf ${SRC_DIR}/uv-aarch64-apple-darwin.tar.gz -C ${BUILD_DIR}
    cp -R ${BUILD_DIR}/uv-aarch64-apple-darwin/uv* ${TOOLS_BIN_DIR}
fi

export PATH=${PATH}:${TOOLS_BIN_DIR}

# install Python
if [ ! -e ${TOP_DIR}/.venv ]; then
    uv venv -p 3.11
fi
# source .venv/bin/activate
# python -VV

echo "[INFO] installed Python in virtual env."
