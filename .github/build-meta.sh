#!/bin/bash

set -euxo pipefail

SCRIPT_DIR="$(dirname "$0")"

# Release Branch regex
RELEASE_BRANCH_RE="v[2-9]\.[0-9]\.x"
# Regex for testing firmware tag
TESTING_TAG_RE="[2-9].[0-9]-[0-9]{8}$"
# Regex for release firmware tag
RELEASE_TAG_RE="[2-9].[0-9].[0-9]$"

# Get Gluon version information
GLUON_REPOSITORY="$(jq -r -e .gluon.repository "$SCRIPT_DIR/build-info.json")"
GLUON_COMMIT="$(jq -r -e .gluon.commit "$SCRIPT_DIR/build-info.json")"

# Get Container version information
CONTAINER_VERSION="$(jq -r -e .container.version "$SCRIPT_DIR/build-info.json")"

DEPLOY=0
DEFAULT_RELEASE_VERSION="$(make --no-print-directory -C $SCRIPT_DIR -f ci-build.mk version)"

MANIFEST_STABLE="0"
MANIFEST_BETA="0"
MANIFEST_TESTING="0"

echo "GitHub Ref-Type: $GITHUB_REF_TYPE"
echo "GitHub Ref-Name: $GITHUB_REF_NAME"

# Determine Autoupdater Branch to use
if [ "$GITHUB_REF_TYPE" = "branch" ]; then
	# Don't generate manifest on push
	MANIFEST_BRANCHES=""

	# HACKHACKHACK - Don't skip manifest branches
	MANIFEST_BRANCHES="stable beta"

	if [ "$GITHUB_REF_NAME" = "master" ]; then
		# Push to master - autoupdater Branch is testing and enabled
		AUTOUPDATER_ENABLED=1
		AUTOUPDATER_BRANCH="testing"
		MANIFEST_TESTING="1"
	elif [[ "$GITHUB_REF_NAME" =~ $RELEASE_BRANCH_RE ]]; then
		# Push to release branch - autoupdater Branch is stable and enabled
		AUTOUPDATER_ENABLED=1
		AUTOUPDATER_BRANCH="stable"
		MANIFEST_STABLE="1"
		MANIFEST_BETA="1"
	else
		# Push to unknown branch - Disable autoupdater
		AUTOUPDATER_ENABLED=0
		AUTOUPDATER_BRANCH="testing"
	fi
elif [ "$GITHUB_REF_TYPE" = "tag" ]; then
	if [[ "$GITHUB_REF_NAME" =~ $TESTING_TAG_RE ]]; then
		# Testing release - autoupdater Branch is testing and enabled
		AUTOUPDATER_ENABLED=1
		AUTOUPDATER_BRANCH="testing"
		MANIFEST_TESTING="1"
		RELEASE_VERSION="$(echo "$GITHUB_REF_NAME" | tr '-' '~')"
		DEPLOY=1
	elif [[ "$GITHUB_REF_NAME" =~ $RELEASE_TAG_RE ]]; then
		# Stable release - autoupdater Branch is stable and enabled
		AUTOUPDATER_ENABLED=1
		AUTOUPDATER_BRANCH="stable"
		MANIFEST_STABLE="1"
		MANIFEST_BETA="1"
		RELEASE_VERSION="$GITHUB_REF_NAME"
		DEPLOY=1
	else
		# Unknown release - Disable autoupdater
		AUTOUPDATER_ENABLED=0
		AUTOUPDATER_BRANCH="testing"
	fi
else
	echo "Unknown ref type $GITHUB_REF_TYPE"
	exit 1
fi

# Determine Version to use
RELEASE_VERSION="${RELEASE_VERSION:-$DEFAULT_RELEASE_VERSION}"

echo "" > "$GITHUB_OUTPUT"

echo "container-version=$CONTAINER_VERSION" >> "$GITHUB_OUTPUT"
echo "gluon-repository=$GLUON_REPOSITORY" >> "$GITHUB_OUTPUT"
echo "gluon-commit=$GLUON_COMMIT" >> "$GITHUB_OUTPUT"
echo "release-version=$RELEASE_VERSION" >> "$GITHUB_OUTPUT"
echo "autoupdater-enabled=$AUTOUPDATER_ENABLED" >> "$GITHUB_OUTPUT"
echo "autoupdater-branch=$AUTOUPDATER_BRANCH" >> "$GITHUB_OUTPUT"
echo "manifest-stable=$MANIFEST_STABLE" >> "$GITHUB_OUTPUT"
echo "manifest-beta=$MANIFEST_BETA" >> "$GITHUB_OUTPUT"
echo "manifest-testing=$MANIFEST_TESTING" >> "$GITHUB_OUTPUT"
echo "deploy=$DEPLOY" >> "$GITHUB_OUTPUT"

cat "$GITHUB_OUTPUT"

exit 0
