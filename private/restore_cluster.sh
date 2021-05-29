#!/bin/bash
set -ueo pipefail

SUFFIX="-${1}"
if [ -z "${1}" ]; then
    SUFFIX=""
fi

BACKUP_SUBDIR=${BACKUP_DIR}/backup${SUFFIX}
CMD="mkdir -p ${DEPLOY_DIR} && rm -rf ${DEPLOY_DIR}/tikv* && cp -rf ${BACKUP_SUBDIR}/data/tikv* \
    ${DEPLOY_DIR}/ && rm ${DEPLOY_DIR}/tikv*/last_tikv.toml"
for i in ${TIKV}; do
    echo restore tikv on $i
    nohup ssh $SSH_FLAGS ${USER_NAME}@$i "${CMD}" &
done
CMD="mkdir -p ${DEPLOY_DIR} && rm -rf ${DEPLOY_DIR}/tidb* && rm -rf ${DEPLOY_DIR}/pd* && \
    cp -rf ${BACKUP_SUBDIR}/data/pd* ${DEPLOY_DIR}/ && cp -rf ${BACKUP_SUBDIR}/data/tidb* ${DEPLOY_DIR}/"
for i in ${TIDB}; do
    echo restore on $i
    nohup ssh $SSH_FLAGS ${USER_NAME}@$i "${CMD}" &
done
wait
