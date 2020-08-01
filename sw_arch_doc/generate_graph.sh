#!/bin/bash

# This script relies on the following for heavy lifting:
# https://www.flourish.org/cinclude2dot/cinclude2dot

set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

CUR_GIT_ROOT=$(git rev-parse --show-toplevel)
ARCH_DOC_DIR=${CUR_GIT_ROOT}/sw_arch_doc
INC_2_DOT=${CUR_GIT_ROOT}/third_party/cinclude2dot

pushd ${CUR_GIT_ROOT}/groff-mirror/src/ >& /dev/null
    ${INC_2_DOT} --merge module --include ${CUR_GIT_ROOT}/groff-mirror/src/include/ > ${ARCH_DOC_DIR}/all_src.dot
popd >& /dev/null

# Grep (filter) only the edges lines and sort them (so we can have meaningful
# diffs over time):
cat ${ARCH_DOC_DIR}/all_src.dot | grep -P '\t"' | sort > sorted_edges.tmp

# Re-compose a whole graphviz dot files, concatenating a header + edges + tail
cat \
  ${ARCH_DOC_DIR}/dot_head.part \
  sorted_edges.tmp \
  ${ARCH_DOC_DIR}/dot_tail.part \
  > ${ARCH_DOC_DIR}/all_src.dot

rm sorted_edges.tmp # remove our temp file

# Delete lines from the dot file that pertain to utility modules that "clog" the
# graph and do not add much insight to internal module relationships.
#
# The lines targeted for deletion look like:
#     "driver" -> "error"
#     "div" -> "stringclass"
sed -i "/\"\bassert\b\"/d" ${ARCH_DOC_DIR}/all_src.dot
sed -i "/\"\bcasecmp\b\"/d" ${ARCH_DOC_DIR}/all_src.dot
sed -i "/\"\bcset\b\"/d" ${ARCH_DOC_DIR}/all_src.dot  # not sure about deleting this one
sed -i "/\"\berrarg\b\"/d" ${ARCH_DOC_DIR}/all_src.dot
sed -i "/\"\berror\b\"/d" ${ARCH_DOC_DIR}/all_src.dot
sed -i "/\"\bgetopt\b\"/d" ${ARCH_DOC_DIR}/all_src.dot
sed -i "/\"\bgetopt_1\b\"/d" ${ARCH_DOC_DIR}/all_src.dot
sed -i "/\"\bgetopt_int\b\"/d" ${ARCH_DOC_DIR}/all_src.dot
sed -i "/\"\blib\b\"/d" ${ARCH_DOC_DIR}/all_src.dot
sed -i "/\"\bnonposix\b\"/d" ${ARCH_DOC_DIR}/all_src.dot
sed -i "/\"\bposix\b\"/d" ${ARCH_DOC_DIR}/all_src.dot
sed -i "/\"\bstrcasecmp\b\"/d" ${ARCH_DOC_DIR}/all_src.dot
sed -i "/\"\bstringclass\b\"/d" ${ARCH_DOC_DIR}/all_src.dot
sed -i "/\"\bstrncasecmp\b\"/d" ${ARCH_DOC_DIR}/all_src.dot

dot -Tsvg < ${ARCH_DOC_DIR}/all_src.dot > ${ARCH_DOC_DIR}/all_src.svg
