#!/bin/bash

set -euxo pipefail

GLUON_PATH="$1"
OUTPUT_FILE="$2"

# Get Target list
make --no-print-directory -C $GLUON_PATH list-targets "BROKEN=${BROKEN}" "GLUON_SITEDIR=$GLUON_PATH/docs/site-example" | jq  --raw-input .  | jq --slurp . | jq -c .
