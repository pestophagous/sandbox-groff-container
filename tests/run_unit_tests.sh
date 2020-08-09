#!/bin/bash

set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CUR_GIT_ROOT=$(git rev-parse --show-toplevel)
TEST_OUT=${CUR_GIT_ROOT}/build/unit_tests # <-- must match the unit_tests/Makefile

mkdir -p ${TEST_OUT}

pushd ${THISDIR}/unit_tests/ >& /dev/null
  make V=1 debug
popd >& /dev/null

${TEST_OUT}/apps/unit_test_runner -s # <-- must match the unit_tests/Makefile

echo 'We assume this was run with '\''set -x'\'' (look at upper lines of this script).'
echo 'Assuming so, then getting here means:'
echo 'SUCCESS'
