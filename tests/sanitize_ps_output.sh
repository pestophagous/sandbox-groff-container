#!/bin/bash
set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

echo 'reading arguments ($1 is target file)'
TARGETFILE=$1

# The 'sanitization' process is aimed at cleaning up lines that would
# be EXPECTED to change across different runs of groff. In order to
# test with 'diff' whether output is correct, we need to 'diff' two
# files where the timestamps and other changeable things are fixed.
FIX_CREATOR='%%Creator: groff version 9.99.9'
FIX_CDATE='%%CreationDate: Thu Jan  1 01:28:32 1970'
FIX_DOC_RSRC='%%DocumentSuppliedResources: procset grops 9.99 9'
FIX_BEG_RSRC='%%BeginResource: procset grops 9.99 9'


# find matching lines and replace WHOLE line with new strings
sed -i "/^%%Creator: /c ${FIX_CREATOR}" "$TARGETFILE"
sed -i "/^%%CreationDate: /c ${FIX_CDATE}" "$TARGETFILE"
sed -i "/^%%DocumentSuppliedResources: /c ${FIX_DOC_RSRC}" "$TARGETFILE"
sed -i "/^%%BeginResource: /c ${FIX_BEG_RSRC}" "$TARGETFILE"
