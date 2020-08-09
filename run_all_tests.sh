#!/bin/bash

set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

# https://web.archive.org/web/20191121235402/https://confluence.atlassian.com/bitbucket/variables-in-pipelines-794502608.html
if [[ -n ${GITHUB_ACTIONS-} || -n ${BITBUCKET_REPO_OWNER-} || -n ${BITBUCKET_REPO_FULL_NAME-} ]];
# The '-' hyphens above test without angering the 'set -u' about unbound variables
then
  echo "Assuming C.I. environment."
  echo "Found at least one of GITHUB_ACTIONS, BITBUCKET_REPO_OWNER, BITBUCKET_REPO_FULL_NAME in env."

  # Try various ways to print OS version info.
  # This lets us keep a record of this in our CI logs,
  # in case the CI docker images change.
  uname -a       || true
  lsb_release -a || true
  gcc --version  || true  # oddly, gcc often prints great OS information
  cat /etc/issue || true

  # What environment variables did the C.I. system set? Print them:
  env

  ./tools/ci/provision.sh
  git submodule update --init --recursive

  XDISPLAY=":1"
else
  echo "Assuming we are NOT on bitbucket. Did not find BITBUCKET_REPO_OWNER nor BITBUCKET_REPO_FULL_NAME in env."
  XDISPLAY=""
fi

CUR_GIT_ROOT=$(git rev-parse --show-toplevel)

./build.sh

source ${CUR_GIT_ROOT}/path_to_local_groff.bash

./tests/run_diff_tests.sh
