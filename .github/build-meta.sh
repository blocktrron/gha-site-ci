#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "$0")"

DEPLOY=0
DEFAULT_RELEASE_VERSION=$(make --no-print-directory -C $SCRIPT_DIR -f ci-build.mk version)

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
	elif [ -n "${GITHUB_REF_NAME%%v*}" ]; then
		# Push to release branch - autoupdater Branch is stable and enabled
		AUTOUPDATER_ENABLED=1
		AUTOUPDATER_BRANCH="stable"
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
		AUTOUPDATER_BRANCH="stable"
		MANIFEST_BRANCHES="testing"
	else
		# Stable release - autoupdater Branch is stable and enabled
		AUTOUPDATER_ENABLED=1
		AUTOUPDATER_BRANCH="stable"
		MANIFEST_BRANCHES="stable beta"
	fi
else
	echo "Unknown ref type $GITHUB_REF_TYPE"
	exit 1
fi

# Determine Version to use
[ -n "$RELEASE_VERSION" ] || RELEASE_VERSION="$DEFAULT_RELEASE_VERSION"

echo "release-version=$RELEASE_VERSION" >> "$GITHUB_OUTPUT"
echo "autoupdater-enabled=$AUTOUPDATER_ENABLED" >> "$GITHUB_OUTPUT"
echo "autoupdater-branch=$AUTOUPDATER_BRANCH" >> "$GITHUB_OUTPUT"
echo "manifest-branches=$MANIFEST_BRANCHES" >> "$GITHUB_OUTPUT"
echo "deploy=$DEPLOY" >> "$GITHUB_OUTPUT"

cat "$GITHUB_OUTPUT"

exit 0
