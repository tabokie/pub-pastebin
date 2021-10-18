#!/bin/bash
set -ueo pipefail

source configurations.sh

./private/stop.sh
./private/restore_cluster.sh ${1}
