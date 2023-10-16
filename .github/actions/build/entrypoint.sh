#!/bin/bash

set -ef

# Determine Gluon Make args
GLUON_MAKE_ARGS="GLUON_AUTOREMOVE=1"
[ -n "$GLUON_ACTION_BROKEN" ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} BROKEN=${GLUON_ACTION_BROKEN}"
[ -n "$GLUON_ACTION_AUTOUPDATER_BRANCH" ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} GLUON_AUTOUPDATER_BRANCH=${GLUON_ACTION_AUTOUPDATER_BRANCH}"
[ -n "$GLUON_ACTION_AUTOUPDATER_ENABLED" ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} GLUON_AUTOUPDATER_ENABLED=${GLUON_ACTION_AUTOUPDATER_ENABLED}"
[ -n "$GLUON_ACTION_RELEASE" ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} GLUON_RELEASE=${GLUON_ACTION_RELEASE}"

env

echo "Extra args for build: ${GLUON_MAKE_ARGS}"

# Link repository
ln -s /gluon/site-repo /gluon/gluon-repo/site

# Build
cd /gluon/gluon-repo
make update
make "GLUON_TARGET=${TARGET}" $GLUON_MAKE_ARGS V=s "-j$(nproc)"
echo "Build finished"

# Pack images
# ToDo: Make output artifact directory configurable
mkdir /gluon/artifacts/output
tar czf /gluon/artifacts/output/output.tar.gz output