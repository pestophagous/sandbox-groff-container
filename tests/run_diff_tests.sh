#!/bin/bash

set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CUR_GIT_ROOT=$(git rev-parse --show-toplevel)
TEST_OUT=${CUR_GIT_ROOT}/build/diff_tests

source ${CUR_GIT_ROOT}/path_to_local_groff.bash
which groff # get this into the CI logs for good record-keeping
which grog # get this into the CI logs for good record-keeping
groff -v # get this into the CI logs for good record-keeping

# We need to remove some lines from 'an-old.tmac' that can insert
# text into the PS output due to groff version mismatch
git checkout ${CUR_GIT_ROOT}/local_install/share/groff/tmac/an-old.tmac
pushd ${CUR_GIT_ROOT} >& /dev/null
  git apply ${THISDIR}/an-old.tmac.patch
popd >& /dev/null


mkdir -p ${TEST_OUT}
rm -rf ${TEST_OUT}/*


run_single_test() {
  while read filenames; do
    for d in "$filenames"; do
      echo $d

      BNAME=$(basename $d)
      GROFF_OUT_PS=$(mktemp --dry-run --tmpdir=${TEST_OUT} ${BNAME}.XXX)
      echo $GROFF_OUT_PS
      GROFF_OUT_INTER=$(mktemp --dry-run --tmpdir=${TEST_OUT} ${BNAME}.XXX)
      GROFF_CMD=${d}.sh

      # generate PS output:
      $GROFF_CMD $d $GROFF_OUT_PS
      # strip timestamps from PS output:
      $THISDIR/sanitize_ps_output.sh $GROFF_OUT_PS

      # now compare it to the golden copy:
      GOLDEN_PS=${d}.ps.sanitized
      diff $GOLDEN_PS $GROFF_OUT_PS
      diff_rslt=$?
      # per 'man diff': Exit status is 0 if inputs are the same
      # If someone disables 'set -x', then explicitly fail here regardless:
      if [ $diff_rslt != 0 ]; then echo early termination at $LINENO; return -1; fi

      # generate INTERMEDIATE output:
      $GROFF_CMD $d $GROFF_OUT_INTER -Z
      # adjust the 'x F' filename line:
      $THISDIR/sanitize_inter_output.sh $GROFF_OUT_INTER $BNAME

      # now compare it to the golden copy:
      GOLDEN_INTER=${d}.intermediate
      diff $GOLDEN_INTER $GROFF_OUT_INTER
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

# Put the tmac file back the way we found it initially:
git checkout ${CUR_GIT_ROOT}/local_install/share/groff/tmac/an-old.tmac
echo 'We assume this was run with '\''set -x'\'' (look at upper lines of this script).'
echo 'Assuming so, then getting here means:'
echo 'SUCCESS'
