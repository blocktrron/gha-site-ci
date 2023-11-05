#!/bin/bash

[ -n "$GLUON_REPO" ] || GLUON_REPO="/gluon/gluon-repo"
[ -n "$GLUON_ARTIFACT_DIR" ] || GLUON_ARTIFACT_DIR="/gluon/artifacts"

OPENWRT_DIR="$GLUON_REPO/openwrt"
OPENWRT_BUILD_DIR="$OPENWRT_DIR/build_dir"
OPENWRT_STAGING_DIR="$OPENWRT_DIR/staging_dir"
OPENWRT_LUA_TARGET="openwrt/staging_dir/hostpkg/bin/lua"

ln -s /gluon/site-repo "$GLUON_REPO/site"

# Create manifest
make -C "$GLUON_REPO" update

# Compile Lua
make -C "$GLUON_REPO" "-j$(nproc)" V=s "GLUON_AUTOREMOVE=1" "openwrt/staging_dir/hostpkg/bin/lua"

# Pack output
tar cJf "$GLUON_ARTIFACT_DIR/openwrt.tar.xz" --posix -C "$GLUON_REPO" openwrt
