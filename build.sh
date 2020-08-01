#!/bin/bash

# This script relies on the following for heavy lifting:
# https://www.flourish.org/cinclude2dot/cinclude2dot

set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

CUR_GIT_ROOT=$(git rev-parse --show-toplevel)

cd ${CUR_GIT_ROOT}
mkdir -p build
mkdir -p local_install

BUILD_ROOT=${CUR_GIT_ROOT}/build
INSTALL_ROOT=${CUR_GIT_ROOT}/local_install

pushd ${CUR_GIT_ROOT}/groff-mirror/ >& /dev/null
  if [ -f ${CUR_GIT_ROOT}/groff-mirror/build-aux/config.sub ]; then
    echo "looks like we already completed bootstrap. skipping it now."
  else
    bash -x bootstrap
  fi
popd >& /dev/null


pushd ${BUILD_ROOT} >& /dev/null
  if [ -f config.status ]; then
    echo "looks like we already completed configure."
    ./config.status
  else
    bash -x ${CUR_GIT_ROOT}/groff-mirror/configure --with-x --prefix=${INSTALL_ROOT}
  fi

  make -j4
  make install

popd >& /dev/null
