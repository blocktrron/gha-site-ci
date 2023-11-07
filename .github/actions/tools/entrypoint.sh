#!/bin/bash

set -euxo pipefail

GLUON_REPO="/gluon/gluon-repo"
GLUON_ARTIFACT_DIR="/gluon/artifacts"

# Update repo
make -C "$GLUON_REPO" "GLUON_SITEDIR=/gluon/site-repo" update

# Compile Lua
make -C "$GLUON_REPO" "-j$(nproc)" V=s "GLUON_AUTOREMOVE=1" "GLUON_SITEDIR=/gluon/site-repo" "openwrt/staging_dir/hostpkg/bin/lua"

# Pack output
tar cJf "$GLUON_ARTIFACT_DIR/openwrt.tar.xz" --posix -C "$GLUON_REPO" openwrt
