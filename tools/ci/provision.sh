#!/bin/bash

set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

CUR_GIT_ROOT=$(git rev-parse --show-toplevel)

# This only comes into play for certain dconf-able(s) like tzdata
export DEBIAN_FRONTEND=noninteractive # in addition to --assume-yes

# Deal with environments (such as bitbucket CI) that lack sudo
if ! [ -x "$(command -v sudo)" ]; then
  apt-get update
  apt-get --assume-yes install sudo
fi

if [[ -n ${GITHUB_ACTIONS-} ]];
then
   # A workaround (for github action) from: https://github.com/Microsoft/azure-pipelines-image-generation/issues/672
   sudo apt-get remove -y clang-6.0 libclang-common-6.0-dev libclang1-6.0 libllvm6.0
   sudo apt-get autoremove
   # end workaround
fi

sudo apt-get update
sudo apt-get --assume-yes install \
  bison \
  build-essential \
  curl \
  gdb \
  git \
  gnupg \
  libc-bin \
  libuchardet-dev \
  libxaw7-dev \
  libxmu-dev \
  netpbm \
  psmisc \
  psutils \
  python3 \
  texinfo \
  unzip \
  wget \
  xvfb


## BEGIN: clang-format from LLVM
${CUR_GIT_ROOT}/tools/ci/get_llvm_clang-format.sh
## END: clang-format from LLVM
