#!/bin/bash
set -ueo pipefail

source ../configurations.sh
tiup cluster destroy ${TIUP_NAME} -y || true
tiup cluster deploy ${TIUP_NAME} nightly ../data/topology.yaml --user ${USER_NAME} -i ${PRIVATE_SSH_KEY} -y
