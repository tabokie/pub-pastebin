#!/bin/bash
#
# Author: tabokie
#
# Periodically spawn and kill a task.
#
# Usage: killer.sh 1s "./do_some_job --some_args"

INTERVAL=$1
COMMAND=$2

i=1
while : ; do
    echo "$((i++)) run"
    nohup $COMMAND >> killee.log 2>&1 &
    sleep ${INTERVAL}
    kill -9 $! || break
    sleep 5s
done

