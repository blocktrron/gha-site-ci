#!/bin/bash

set -e

echo "release-version=v2.7~test" >> "$GITHUB_OUTPUT"
echo "autoupdater-enabled=1" >> "$GITHUB_OUTPUT"
echo "autoupdater-branch=testing" >> "$GITHUB_OUTPUT"

exit 0
