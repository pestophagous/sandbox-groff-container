#!/bin/bash

if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi

CUR_GIT_ROOT=$(git rev-parse --show-toplevel)

INSTALL_ROOT=${CUR_GIT_ROOT}/local_install

export PATH="${INSTALL_ROOT}/bin/:$PATH"
