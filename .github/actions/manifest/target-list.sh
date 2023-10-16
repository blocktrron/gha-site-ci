#!/bin/bash

mkdir -p "${RUNNER_TEMP}/action-data"

if [ -n "$ACTION_TARGETS" ]; then
    echo "$ACTION_TARGETS" | jq -r '.[]' | paste -sd ' ' > "${RUNNER_TEMP}/action-data/targets.list"
else
    touch "${RUNNER_TEMP}/action-data/targets.list"
fi

