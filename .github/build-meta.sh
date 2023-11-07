#!/bin/bash

set -euxo pipefail

SCRIPT_DIR="$(dirname "$0")"

# Get Gluon version information
GLUON_REPOSITORY=$(jq -r -e .gluon.repository "$SCRIPT_DIR/build-info.json")
GLUON_COMMIT=$(jq -r -e .gluon.commit "$SCRIPT_DIR/build-info.json")

DEPLOY=0
DEFAULT_RELEASE_VERSION="$(make --no-print-directory -C $SCRIPT_DIR -f ci-build.mk version)"

MANIFEST_STABLE="0"
MANIFEST_BETA="0"
MANIFEST_TESTING="0"

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
	elif [ -n "${GITHUB_REF_NAME%%v*}" ]; then
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
	DEPLOY=1

	if [[ "$GITHUB_REF_NAME" =~ "~" ]]; then
		# Testing release - autoupdater Branch is testing and enabled
		AUTOUPDATER_ENABLED=1
		AUTOUPDATER_BRANCH="testing"
		MANIFEST_TESTING="1"
	else
		# Stable release - autoupdater Branch is stable and enabled
		AUTOUPDATER_ENABLED=1
		AUTOUPDATER_BRANCH="stable"
		MANIFEST_STABLE="1"
		MANIFEST_BETA="1"
	fi
else
	echo "Unknown ref type $GITHUB_REF_TYPE"
	exit 1
fi

# Determine Version to use
RELEASE_VERSION="${RELEASE_VERSION:-$DEFAULT_RELEASE_VERSION}"

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
