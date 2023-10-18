#!/bin/bash

set -e

GLUON_DIR=$1
OPENWRT_PATCHES_ARCHIVE="/tmp/openwrt-patches.tar"

tar cf "$OPENWRT_PATCHES_ARCHIVE" -C "$GLUON_DIR/patches" openwrt

OPENWRT_PATCHES_HASH=$(md5sum "$OPENWRT_PATCHES_ARCHIVE" | awk '{ print $1 }')
MODULES_HASH=$(md5sum "$GLUON_DIR/modules" | awk '{ print $1 }')
rm "$OPENWRT_PATCHES_ARCHIVE"

echo "$MODULES_HASH-$OPENWRT_PATCHES_HASH"
