#!/bin/bash

set -euxo pipefail

[ -n "$GLUON_REPO" ] || GLUON_REPO="/gluon/gluon-repo"

make -C "$GLUON_REPO" update
make -C "$GLUON_REPO" "-j$(nproc)" V=s "GLUON_AUTOREMOVE=1" "GLUON_SITEDIR=/gluon/site-repo" "openwrt/staging_dir/hostpkg/bin/lua"
