#!/bin/bash

set -ef

# Determine Gluon Make args
GLUON_MAKE_ARGS=""
[ -n "$ACTION_AUTOREMOVE" ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} GLUON_AUTOREMOVE=${ACTION_AUTOREMOVE}"
[ -n "$GLUON_ACTION_BROKEN" ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} BROKEN=${GLUON_ACTION_BROKEN}"
[ -n "$GLUON_ACTION_AUTOUPDATER_BRANCH" ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} GLUON_AUTOUPDATER_BRANCH=${GLUON_ACTION_AUTOUPDATER_BRANCH}"
[ -n "$GLUON_ACTION_AUTOUPDATER_ENABLED" ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} GLUON_AUTOUPDATER_ENABLED=${GLUON_ACTION_AUTOUPDATER_ENABLED}"
[ -n "$GLUON_ACTION_RELEASE" ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} GLUON_RELEASE=${GLUON_ACTION_RELEASE}"

env

echo "Extra args for build: ${GLUON_MAKE_ARGS}"

# Link repository
ln -s /gluon/site-repo /gluon/gluon-repo/site

# Build
make -C /gluon/gluon-repo $ACTION_MAKE_TARGET "GLUON_TARGET=${ACTION_HARDWARE_TARGET}" $GLUON_MAKE_ARGS V=s "-j$(nproc)"
echo "Build finished"
