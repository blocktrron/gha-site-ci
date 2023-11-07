#!/bin/bash

set -euxo pipefail

# Determine Gluon Make args
GLUON_MAKE_ARGS=""
[ -n ${ACTION_GLUON_AUTOREMOVE+x} ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} GLUON_AUTOREMOVE=${ACTION_GLUON_AUTOREMOVE}"
[ -n ${ACTION_GLUON_TARGET+x} ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} GLUON_TARGET=${ACTION_GLUON_TARGET}"
[ -n ${ACTION_GLUON_BROKEN+x} ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} BROKEN=${ACTION_GLUON_BROKEN}"
[ -n ${ACTION_GLUON_AUTOUPDATER_BRANCH+x} ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} GLUON_AUTOUPDATER_BRANCH=${ACTION_GLUON_AUTOUPDATER_BRANCH}"
[ -n ${ACTION_GLUON_AUTOUPDATER_ENABLED+x} ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} GLUON_AUTOUPDATER_ENABLED=${ACTION_GLUON_AUTOUPDATER_ENABLED}"
[ -n ${ACTION_GLUON_RELEASE+x} ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} GLUON_RELEASE=${ACTION_GLUON_RELEASE}"
[ -n ${ACTION_GLUON_PRIORITY+x} ] && GLUON_MAKE_ARGS="${GLUON_MAKE_ARGS} GLUON_PRIORITY=${ACTION_GLUON_PRIORITY}"

echo "Extra args for build: ${GLUON_MAKE_ARGS}"

# Build
make -C /gluon/gluon-repo $ACTION_MAKE_TARGET $GLUON_MAKE_ARGS GLUON_SITEDIR=/gluon/site-repo V=s "-j$(nproc)"
echo "Build finished"
