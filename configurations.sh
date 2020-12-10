# must set to $(pwd)
PROJECT=
USER_NAME=
# private key to TiDB and TiKVs if any
SSH_KEY=
TIDB="127.0.0.1"
TIKV="127.0.0.1 127.0.0.1"
ME="127.0.0.1"
BINARY_DIR=${PROJECT}/binary
TIUP_NAME="tidb-test"

# TPC-C related
TPCC_WAREHOUSE=5000
TPCC_LOAD_THREADS=40
TPCC_DURATION=8h
TPCC_THREADS=800

# fixed
WORKING_DIR=/data
BACKUP_DIR=/backup
DEPLOY_DIR=${WORKING_DIR}/deploy
if ![ "${SSH_KEY}" ]; then
    PRIVATE_SSH_KEY=${PROJECT}/data/key
else
    PRIVATE_SSH_KEY=${SSH_KEY}
fi
SSH_FLAGS="-i ${PRIVATE_SSH_KEY}

