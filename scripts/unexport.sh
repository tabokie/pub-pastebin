#!/bin/bash

# This script removes folder from PATH variable
# Folders to remove reading as arguments

if [ $# -lt 1 ]; then
    echo "You should give at least one argument"
    echo "For example"
    echo "$0 /usr/local/bin"
else
    FOLDERS_TO_REMOVE=`echo $@ | sed 's/ /|/g'`

    echo "You actually PATH variable is:"
    echo $PATH
    echo "###"

    PATH=$( echo ${PATH} | tr -s ":" "\n" | grep -vwE "(${FOLDERS_TO_REMOVE})" | tr -s "\n" ":" | sed "s/:$//" )

    echo "After unexport:"
    echo $PATH
    export PATH=$PATH
fi
