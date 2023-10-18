#!/bin/bash

[ -n "$GLUON_REPO" ] || GLUON_REPO="/gluon/gluon-repo"
[ -n "$GLUON_ARTIFACT_DIR" ] || GLUON_ARTIFACT_DIR="/gluon/artifacts"

OPENWRT_DIR="$GLUON_REPO/openwrt"
OPENWRT_STAGING_DIR="$OPENWRT_DIR/staging_dir"
OPENWRT_LUA_TARGET="openwrt/staging_dir/hostpkg/bin/lua"

ln -s /gluon/site-repo "$GLUON_REPO/site"

# Create manifest
make -C "$GLUON_REPO" update

# Compile Lua
make -C "$GLUON_REPO" "-j$(nproc)" V=s "openwrt/staging_dir/hostpkg/bin/lua"

for branch in $GLUON_MANIFEST_BRANCHES; do
	make -C "$GLUON_REPO" manifest \
		"-j$(nproc)" \
		"V=s" \
		"BROKEN=1" \
		"GLUON_RELEASE=$GLUON_RELEASE" \
		"GLUON_AUTOUPDATER_BRANCH=$branch" \
		"GLUON_PRIORITY=$GLUON_PRIORITY" \
		"GLUON_IMAGEDIR=$GLUON_ARTIFACT_DIR/output/images"
done

# Pack output
tar cJf "$GLUON_ARTIFACT_DIR/openwrt-host-tools.tar.gz" -C "$OPENWRT_STAGING_DIR" host
