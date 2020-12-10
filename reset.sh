#!/bin/bash
set -ueo pipefail

source configurations.sh

./private/stop.sh
./restore_cluster.sh ${1}
tiup cluster start ${TIUP_NAME}

