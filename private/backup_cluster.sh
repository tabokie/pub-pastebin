#!/bin/bash
set -ueo pipefail

SUFFIX="-${1}"
if [ -z "${1}" ]; then
    SUFFIX=""
fi

BACKUP_SUBDIR=${BACKUP_DIR}/backup${SUFFIX}
CMD="rm -rf ${BACKUP_SUBDIR} && mkdir -p ${BACKUP_SUBDIR} && cp -rf ${DEPLOY_DIR} \
    ${BACKUP_SUBDIR}/"
for i in ${TIKV}; do
    echo backup tikv on $i
    nohup ssh $SSH_FLAGS ${USER_NAME}@$i "${CMD}" &
done
CMD="rm -rf ${BACKUP_SUBDIR} && mkdir -p ${BACKUP_SUBDIR} && cp -rf ${DEPLOY_DIR}/pd* \
    ${BACKUP_SUBDIR}/ && cp -rf ${DEPLOY_DIR}/tidb* ${BACKUP_SUBDIR}/"
for i in ${TIDB}; do
    echo backup $i
    nohup ssh $SSH_FLAGS ${USER_NAME}@$i "${CMD}" &
done
wait
