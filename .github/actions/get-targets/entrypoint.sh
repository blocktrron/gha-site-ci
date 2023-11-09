#!/bin/bash

set -euxo pipefail

GLUON_PATH="$1"
TARGET_WHITELIST="${2-}"

# Get List of available Targets
AVAILABLE_TARGETS_NEWLINE="$(make --no-print-directory -C $GLUON_PATH list-targets "BROKEN=${BROKEN}" "GLUON_SITEDIR=$GLUON_PATH/docs/site-example")"
TARGET_WHITELIST_NEWLINE="$(echo "$TARGET_WHITELIST" | tr ' ' '\n')"

# Return all available targets if no whitelist is set
OUTPUT_TARGETS="${AVAILABLE_TARGETS_NEWLINE}"

if [ -n "$TARGET_WHITELIST" ]; then
    # Only return words present in both lists
    OUTPUT_TARGETS="$(echo -e "$AVAILABLE_TARGETS_NEWLINE\n$TARGET_WHITELIST_NEWLINE" | sort | uniq -d)"
fi

# Convert to JSON
OUTPUT_JSON="$(echo "$OUTPUT_TARGETS" | jq  --raw-input .  | jq --slurp . | jq -c .)"

echo "$OUTPUT_JSON"