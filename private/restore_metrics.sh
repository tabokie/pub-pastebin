#!/bin/bash
set -ueo pipefail

BACKUP_METRICS=${WORKING_DIR}/backup-metrics
# restore metrics
CMD="ls ${BACKUP_METRICS} && rm -rf ${DEPLOY_DIR}/prometheus* && cp -rf ${BACKUP_METRICS}/prometheus* ${DEPLOY_DIR}/"
for i in ${TIDB}; do
    echo restore $i
    nohup ssh $SSH_FLAGS ${USER_NAME}@$i "${CMD}" &
done
wait
