#!/bin/bash
set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

echo 'reading arguments ($1 is target file, $2 is original basename)'
TARGETFILE=$1
BNAME=$2

# The GOLDEN intermediate files checked into the tests directory all contain
# simply the basename of the input file on the 'x F' line. However, when we run
# the tests, the 'x F' line generated in the test runs has a full absolute path
# to the input file. "Sanitization" in this case amounts to sedding out the
# longer 'x F' line to use only the basename.

XF_LINE="x F $BNAME"

sed -i "/^x F /c ${XF_LINE}" "$TARGETFILE"
