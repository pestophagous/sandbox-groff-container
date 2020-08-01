#!/bin/bash

# This script relies on the following for heavy lifting:
# https://www.flourish.org/cinclude2dot/cinclude2dot

set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

CUR_GIT_ROOT=$(git rev-parse --show-toplevel)

MYCFLAGS="-g -O0"
MYCXXFLAGS="-g -O0"

BUILD_DATE=`date '+%Y-%m-%d_%H.%M'`
LAST_KNOWN_HASH=`git rev-parse --verify --short=10 HEAD`
MYVERSION="${BUILD_DATE}_${LAST_KNOWN_HASH}"

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

  rm -f ${BUILD_ROOT}/src/roff/troff/majorminor.cpp
  rm -f ${BUILD_ROOT}/src/libs/libgroff/version.cpp

  make V=1 CFLAGS="${MYCFLAGS}" CXXFLAGS="${MYCXXFLAGS}" -j4

  sed -i "s/\bUNKNOWN\b/$MYVERSION/" ${BUILD_ROOT}/src/roff/troff/majorminor.cpp
  sed -i "s/\bUNKNOWN\b/$MYVERSION/" ${BUILD_ROOT}/src/libs/libgroff/version.cpp

  make V=1 CFLAGS="${MYCFLAGS}" CXXFLAGS="${MYCXXFLAGS}" -j4

  make V=1 install

popd >& /dev/null
