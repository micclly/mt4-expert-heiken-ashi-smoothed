#!/bin/bash

if [ ! -d "$MQL4DIR" ]; then
    echo "ERROR: $MQL4DIR does not exist" >&2
    exit 1
fi

rsync -av --files-from=fileset.txt $MQL4DIR/ MQL4/
