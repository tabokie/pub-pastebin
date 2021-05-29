#!/bin/bash
# deploy.sh nightly
set -ueo pipefail

tiup cluster destroy ${TIUP_NAME} -y || true
tiup cluster deploy ${TIUP_NAME} ${1} ${PROJECT}/data/topology.yaml --user ${USER_NAME} -i ${PRIVATE_SSH_KEY} -y
