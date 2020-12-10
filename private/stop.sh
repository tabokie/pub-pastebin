#!/bin/bash
set -ueo pipefail

source ../configurations.sh
tiup cluster stop ${TIUP_NAME} --role tikv
tiup cluster stop ${TIUP_NAME} --role tidb
tiup cluster stop ${TIUP_NAME} --role pd
