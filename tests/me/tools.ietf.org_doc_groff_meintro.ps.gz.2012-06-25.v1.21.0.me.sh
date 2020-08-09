#!/bin/bash

set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

echo 'reading arguments ($1 is input, $2 is output, $3 is for -Z)'
INFILE=$1
OUTFILE=$2
GROFFARGS=${3-}
# The '-' hyphens above test without angering the 'set -u' about unbound variables

groff $GROFFARGS -T ps -P-pa4 -me $INFILE > $OUTFILE
