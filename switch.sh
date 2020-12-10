#!/bin/bash
set -eof pipefail

source configurations.sh

if [ "${2}" = "hard" ]; then
    tiup cluster stop ${TIUP_NAME} -y || true
    ./private/restore_cluster.sh ${1}
else
    tiup cluster stop ${TIUP_NAME} --role tikv -y || true
fi
./private/sync_tikv.sh ${1}
tiup cluster start ${TIUP_NAME}

