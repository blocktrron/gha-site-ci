#/bin/bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"

RELEASE_NAME="${1-}"

# Regex for testing firmware tag
TESTING_TAG_RE="^[2-9].[0-9]~[0-9]{8}$"
# Regex for release firmware tag
RELEASE_TAG_RE="^[2-9].[0-9].[0-9]$"

# Check if we have an argument provided.
if [ -n "$RELEASE_NAME" ]; then
    if [[ "$RELEASE_NAME" =~ $RELEASE_TAG_RE ]] || [[ "$RELEASE_NAME" =~ $TESTING_TAG_RE ]]; then
        # Success
        echo "Provided Release Name '$RELEASE_NAME' is valid"
    else
        # Failure
        echo "Provided Release Name '$RELEASE_NAME' is invalid"
        exit 1
    fi
else
    RELEASE_NAME="$(make --no-print-directory -C $SCRIPT_DIR -f ci-build.mk version)"
fi

# Replace ~ with - in testing tags
TAG_NAME="${RELEASE_NAME//\~/\-}"

echo "Proceed to tag firmware release for '$RELEASE_NAME' (Tag: '$TAG_NAME')? (y/n)"

read -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Proceeding to tag firmware release with $RELEASE_NAME"
else
    echo "Aborting"
    exit 1
fi

git tag "$TAG_NAME"

echo "Tag was created"
