#!/bin/bash

set -ef

GLUON_PATH="$1"
OUTPUT_FILE="$2"

# Link default site
ln -s $GLUON_PATH/docs/site-example $GLUON_PATH/site

# Get Target list
make -C $GLUON_PATH list-targets "BROKEN=${BROKEN}" | jq  --raw-input .  | jq --slurp . | jq -c .
