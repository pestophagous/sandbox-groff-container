#!/bin/bash

set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

echo 'reading arguments ($1 is input, $2 is output)'
INFILE=$1
OUTFILE=$2

groff -T ps -P-pa4 -me $INFILE > $OUTFILE
