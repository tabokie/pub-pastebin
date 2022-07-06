#!/usr/bin/env bash

# Configurations
LOG_DIR=${LOG_LADY_HOME:-"${HOME}/cabin"}

LOG_NAME=$(date +%Y%m%d).plan
LOG_PATH=${LOG_DIR}/${LOG_NAME}
LOG_TEMPLATE=${LOG_DIR}/template

if [ ! -f ${LOG_PATH} ]; then
  # Create today's log.
  mkdir -p ${LOG_DIR}
  if [ -f ${LOG_TEMPLATE} ]; then
    cat ${LOG_TEMPLATE} > ${LOG_PATH}
  else
    touch ${LOG_PATH}
  fi

  # Aggregate yesterday's log.
  YESTERDAY_LOG_PATH=${LOG_DIR}/$(date -d '-1 day' +%Y%m%d).plan
  ARCHIVE_PATH=${LOG_DIR}/memory
  if [ -f ${YESTERDAY_LOG_PATH} ]; then
    echo "--------------------------" >> ${ARCHIVE_PATH}
    date -d '-1 day' +'%A %B %d, %Y' >> ${ARCHIVE_PATH}
    echo "--------------------------" >> ${ARCHIVE_PATH}
    cat ${YESTERDAY_LOG_PATH} >> ${ARCHIVE_PATH}
    echo >> ${ARCHIVE_PATH}
  fi
fi

vim ${LOG_PATH}
