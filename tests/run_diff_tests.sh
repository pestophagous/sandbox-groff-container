#!/bin/bash

set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CUR_GIT_ROOT=$(git rev-parse --show-toplevel)
TEST_OUT=${CUR_GIT_ROOT}/build/diff_tests

source ${CUR_GIT_ROOT}/path_to_local_groff.bash
which groff # get this into the CI logs for good record-keeping
which grog # get this into the CI logs for good record-keeping
groff -v # get this into the CI logs for good record-keeping

mkdir -p ${TEST_OUT}
rm -rf ${TEST_OUT}/*


run_single_test() {
  while read filenames; do
    for d in "$filenames"; do
      echo $d

      BNAME=$(basename $d)
      GROFF_OUT=$(mktemp --dry-run --tmpdir=${TEST_OUT} ${BNAME}.XXX)
      echo $GROFF_OUT
      GROFF_CMD=${d}.sh

      # generate PS output:
      $GROFF_CMD $d $GROFF_OUT
      # strip timestamps from PS output:
      $THISDIR/sanitize_ps_output.sh $GROFF_OUT

      # now compare it to the golden copy:
      GOLDEN=${d}.ps.sanitized
      diff $GOLDEN $GROFF_OUT
      diff_rslt=$?
      # per 'man diff': Exit status is 0 if inputs are the same
      # If someone disables 'set -x', then explicitly fail here regardless:
      if [ $diff_rslt != 0 ]; then echo early termination at $LINENO; return -1; fi

    done
  done
}



pushd ${THISDIR} >& /dev/null
  top_level_dirs=(*/)
popd >& /dev/null

for dr in "${top_level_dirs[@]}"; do
  dir=${THISDIR}/${dr}

  if [ -f "${dir}/.git" ]; then
      echo "Refusing to clang-format ${dir} - it appears to be a submodule."
  else
    find ${dir} \
         \( -name '*\.roff' \
         -o -name '*\.man' \
         -o -name '*\.mm' \
         -o -name '*\.me' \
         -o -name '*\.mom' \
         -o -name '*\.ms' \) \
         | run_single_test
  fi
done

echo 'We assume this was run with '\''set -x'\'' (look at upper lines of this script).'
echo 'Assuming so, then getting here means:'
echo 'SUCCESS'
