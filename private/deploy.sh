#!/bin/bash
set -ueo pipefail

tiup cluster destroy ${TIUP_NAME} -y || true
tiup cluster deploy ${TIUP_NAME} nightly ${PROJECT}/data/topology.yaml --user ${USER_NAME} -i ${PRIVATE_SSH_KEY} -y
