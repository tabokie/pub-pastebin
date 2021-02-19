# must set to $(pwd)
export PROJECT=
export USER_NAME=
# private key to TiDB and TiKVs if any
export SSH_KEY=
export TIDB="127.0.0.1"
export TIKV="127.0.0.1 127.0.0.1"
export BINARY_DIR=${PROJECT}/binary
export TIUP_NAME="tidb-test"
export VERSION="nightly" # v5.0.0-rc

# TPC-C related
export TPCC_WAREHOUSE=5000
export TPCC_LOAD_THREADS=40
export TPCC_DURATION=8h
export TPCC_THREADS=800

# fixed
export WORKING_DIR=/data
export BACKUP_DIR=/backup
export DEPLOY_DIR=${WORKING_DIR}/deploy
if [ "${SSH_KEY}" ]; then
    export PRIVATE_SSH_KEY=${SSH_KEY}
else
    export PRIVATE_SSH_KEY=${PROJECT}/data/key
fi
export SSH_FLAGS="-o StrictHostKeyChecking=no -i ${PRIVATE_SSH_KEY}"
