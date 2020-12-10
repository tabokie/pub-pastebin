#!/bin/bash
# synchronize tidb/pd binary and config
set -eof pipefail

TIDB_DIR="${DEPLOY_DIR}/tidb*"
PD_DIR="${DEPLOY_DIR}/pd*"

SUFFIX="-${1}"
if [ -z "${1}" ]; then
    SUFFIX=""
fi

for i in $TIDB; do
    if [ -e ${BINARY_DIR}/tidb-server${SUFFIX} ]; then
        echo sync tidb-server${SUFFIX} to $i
        scp ${SSH_FLAGS} ${BINARY_DIR}/tidb-server${SUFFIX} ${USER_NAME}@$i:${TIDB_DIR}/bin/tidb-server
    elif [ -e ${BINARY_DIR}/tidb-server ]; then
        echo sync tidb-server to $i
        scp ${SSH_FLAGS} ${BINARY_DIR}/tidb-server ${USER_NAME}@$i:${TIDB_DIR}/bin/tidb-server
    fi
    if [ -e ${BINARY_DIR}/tidb${SUFFIX}.toml ]; then
        echo sync tidb${SUFFIX}.toml to $i
        scp ${SSH_FLAGS} ${BINARY_DIR}/tidb${SUFFIX}.toml ${USER_NAME}@$i:${TIDB_DIR}/conf/tidb.toml
    elif [ -e ${BINARY_DIR}/tidb.toml ]; then
        echo sync tidb.toml to $i
        scp ${SSH_FLAGS} ${BINARY_DIR}/tidb.toml ${USER_NAME}@$i:${TIDB_DIR}/conf/tidb.toml
    fi
done
for i in $TIDB; do
    echo sync pd to $i
    if [ -e ${BINARY_DIR}/pd-server${SUFFIX} ]; then
        echo sync pd-server${SUFFIX} to $i
        scp ${SSH_FLAGS} ${BINARY_DIR}/pd-server${SUFFIX} ${USER_NAME}@$i:${PD_DIR}/bin/pd-server
    elif [ -e ${BINARY_DIR}/pd-server ]; then
        echo sync pd-server to $i
        scp ${SSH_FLAGS} ${BINARY_DIR}/pd-server ${USER_NAME}@$i:${PD_DIR}/bin/pd-server
    fi
    if [ -e ${BINARY_DIR}/pd${SUFFIX}.toml ]; then
        echo sync pd${SUFFIX}.toml to $i
        scp ${SSH_FLAGS} ${BINARY_DIR}/pd${SUFFIX}.toml ${USER_NAME}@$i:${PD_DIR}/conf/pd.toml
    elif [ -e ${BINARY_DIR}/pd.toml ]; then
        echo sync pd.toml to $i
        scp ${SSH_FLAGS} ${BINARY_DIR}/pd.toml ${USER_NAME}@$i:${PD_DIR}/conf/pd.toml
    fi
done
