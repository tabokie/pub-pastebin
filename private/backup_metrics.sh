#!/bin/bash
set -ueo pipefail

BACKUP_METRICS=${WORKING_DIR}/backup-metrics
CMD="rm -rf ${BACKUP_METRICS} && mkdir -p ${BACKUP_METRICS} && cp -rf ${DEPLOY_DIR}/prometheus* ${BACKUP_METRICS}/"
for i in ${TIDB}; do
    echo backup $i
    nohup ssh $SSH_FLAGS ${USER_NAME}@$i "${CMD}" &
done
wait
