#!/bin/bash
set -eof pipefail

SUFFIX="-${1}"
if [ -z "${1}" ]; then
    SUFFIX=""
fi

TIKV_DIR="${DEPLOY_DIR}/tikv-20160/"

for i in ${TIKV}; do
    if [ -e ${BINARY_DIR}/tikv-server${SUFFIX} ]; then
        echo sync tikv-server${SUFFIX} to $i
        scp ${SSH_FLAGS} ${BINARY_DIR}/tikv-server${SUFFIX} ${USER_NAME}@$i:${TIKV_DIR}/bin/tikv-server
    elif [ -e ${BINARY_DIR}/tikv-server ]; then
        echo sync tikv-server to $i
        scp ${SSH_FLAGS} ${BINARY_DIR}/tikv-server ${USER_NAME}@$i:${TIKV_DIR}/bin/tikv-server
    fi
    if [ -e ${BINARY_DIR}/tikv${SUFFIX}.toml ]; then
        echo sync tikv${SUFFIX}.toml to $i
        scp ${SSH_FLAGS} ${BINARY_DIR}/tikv${SUFFIX}.toml ${USER_NAME}@$i:${TIKV_DIR}/conf/tikv.toml
    elif [ -e ${BINARY_DIR}/tikv.toml ]; then
        echo sync tikv.toml to $i
        scp ${SSH_FLAGS} ${BINARY_DIR}/tikv.toml ${USER_NAME}@$i:${TIKV_DIR}/conf/tikv.toml
    fi
done
