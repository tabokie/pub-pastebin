#!/bin/bash
set -ueo pipefail

tiup cluster stop ${TIUP_NAME} --role tikv -y
tiup cluster stop ${TIUP_NAME} --role tidb -y
tiup cluster stop ${TIUP_NAME} --role pd -y
