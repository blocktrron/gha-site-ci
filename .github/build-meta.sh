#!/bin/bash

set -euxo pipefail

SCRIPT_DIR="$(dirname "$0")"

# Get Git short hash for repo at $SCRIPT_DIR
GIT_SHORT_HASH="$(git -C "$SCRIPT_DIR" rev-parse --short HEAD)"

# Build BROKEN by default. Disable for release builds.
BROKEN="1"

# Don't deploy by default. Enable for release and testing builds.
DEPLOY="0"

# Don't release by default. Enable for tags.
CREATE_RELEASE="0"

# Target whitelist
TARGET_WHITELIST="$(jq -r -e '.build.targets | join(" ")' "$SCRIPT_DIR/build-info.json")"

# Release Branch regex
RELEASE_BRANCH_RE="^v20[0-9]{2}\.[0-9]\.x$"
# Regex for testing firmware tag
TESTING_TAG_RE="^[2-9].[0-9]-[0-9]{8}$"
# Regex for custom testing firmware tag
CUSTOM_TESTING_TAG_RE="^[2-9].[0-9]-[0-9]{8}"
# Regex for release firmware tag
RELEASE_TAG_RE="^[2-9].[0-9].[0-9]$"

# Get Gluon version information
GLUON_REPOSITORY="$(jq -r -e .gluon.repository "$SCRIPT_DIR/build-info.json")"
GLUON_COMMIT="$(jq -r -e .gluon.commit "$SCRIPT_DIR/build-info.json")"

# Get Container version information
CONTAINER_VERSION="$(jq -r -e .container.version "$SCRIPT_DIR/build-info.json")"

# Get Default Release version from site.mk
DEFAULT_RELEASE_VERSION="$(make --no-print-directory -C "$SCRIPT_DIR/.." -f ci-build.mk version)"

# Enable Manifest generation conditionally
MANIFEST_STABLE="0"
MANIFEST_BETA="0"
MANIFEST_TESTING="0"

# Only Sign manifest on release builds
SIGN_MANIFEST="0"

echo "GitHub Ref-Type: $GITHUB_REF_TYPE"
echo "GitHub Ref-Name: $GITHUB_REF_NAME"

# Determine Autoupdater Branch to use
if [ "$GITHUB_REF_TYPE" = "branch" ]; then
	DEFAULT_RELEASE_VERSION="$DEFAULT_RELEASE_VERSION-$GIT_SHORT_HASH"
	if [ "$GITHUB_REF_NAME" = "master" ]; then
		# Push to master - autoupdater Branch is testing and enabled
		AUTOUPDATER_ENABLED="1"
		AUTOUPDATER_BRANCH="testing"

		MANIFEST_TESTING="1"
	elif [[ "$GITHUB_REF_NAME" =~ $RELEASE_BRANCH_RE ]]; then
		# Push to release branch - autoupdater Branch is stable and enabled
		AUTOUPDATER_ENABLED="1"
		AUTOUPDATER_BRANCH="stable"

		MANIFEST_STABLE="1"
		MANIFEST_BETA="1"
	else
		# Push to unknown branch - Disable autoupdater
		AUTOUPDATER_ENABLED="0"
		AUTOUPDATER_BRANCH="testing"
	fi
elif [ "$GITHUB_REF_TYPE" = "tag" ]; then
	if [[ "$GITHUB_REF_NAME" =~ $TESTING_TAG_RE ]]; then
		# Testing release - autoupdater Branch is testing and enabled
		AUTOUPDATER_ENABLED="1"
		AUTOUPDATER_BRANCH="testing"

		MANIFEST_TESTING="1"
		SIGN_MANIFEST="1"

		RELEASE_VERSION="$(echo "$GITHUB_REF_NAME" | tr '-' '~')"
		DEPLOY="1"
	elif [[ "$GITHUB_REF_NAME" =~ $RELEASE_TAG_RE ]]; then
		# Stable release - autoupdater Branch is stable and enabled
		AUTOUPDATER_ENABLED="1"
		AUTOUPDATER_BRANCH="stable"

		MANIFEST_STABLE="1"
		MANIFEST_BETA="1"
		SIGN_MANIFEST="1"

		RELEASE_VERSION="$GITHUB_REF_NAME"
		BROKEN="0"
		DEPLOY="1"
	else
		# Unknown release - Disable autoupdater
		AUTOUPDATER_ENABLED="0"
		AUTOUPDATER_BRANCH="testing"

		if [[ "$GITHUB_REF_NAME" =~ $CUSTOM_TESTING_TAG_RE ]]; then
			# Custom testing tag
			
			# Replace first occurence of - with ~ of GITHUB_REF_NAME for RELEASE_VERSION
			# shellcheck disable=SC2001
			RELEASE_VERSION="$(echo "$GITHUB_REF_NAME" | sed 's/-/~/')"
		fi
	fi

	CREATE_RELEASE="1"
else
	echo "Unknown ref type $GITHUB_REF_TYPE"
	exit 1
fi

# Ensure we don't {sign,deploy,release} on pull requests
if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
	DEPLOY="0"
	CREATE_RELEASE="0"
	SIGN_MANIFEST="0"
fi

# Determine Version to use
RELEASE_VERSION="${RELEASE_VERSION:-$DEFAULT_RELEASE_VERSION}"

echo "" > "$GITHUB_OUTPUT"

# shellcheck disable=SC2129
echo "container-version=$CONTAINER_VERSION" >> "$GITHUB_OUTPUT"
echo "gluon-repository=$GLUON_REPOSITORY" >> "$GITHUB_OUTPUT"
echo "gluon-commit=$GLUON_COMMIT" >> "$GITHUB_OUTPUT"
echo "release-version=$RELEASE_VERSION" >> "$GITHUB_OUTPUT"
echo "autoupdater-enabled=$AUTOUPDATER_ENABLED" >> "$GITHUB_OUTPUT"
echo "autoupdater-branch=$AUTOUPDATER_BRANCH" >> "$GITHUB_OUTPUT"
echo "broken=$BROKEN" >> "$GITHUB_OUTPUT"
echo "manifest-stable=$MANIFEST_STABLE" >> "$GITHUB_OUTPUT"
echo "manifest-beta=$MANIFEST_BETA" >> "$GITHUB_OUTPUT"
echo "manifest-testing=$MANIFEST_TESTING" >> "$GITHUB_OUTPUT"
echo "sign-manifest=$SIGN_MANIFEST" >> "$GITHUB_OUTPUT"
echo "deploy=$DEPLOY" >> "$GITHUB_OUTPUT"
echo "create-release=$CREATE_RELEASE" >> "$GITHUB_OUTPUT"
echo "target-whitelist=$TARGET_WHITELIST" >> "$GITHUB_OUTPUT"

cat "$GITHUB_OUTPUT"

exit 0
