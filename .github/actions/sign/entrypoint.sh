#!/bin/bash

[ -n "$ACTION_OUTPUT_DIR" ] || exit 1
[ -n "$ACTION_SIGNING_KEY" ] || exit 1
[ -n "$ACTION_MANIFEST_BRANCHES" ] || exit 1

SIGNING_KEY_PATH="/gluon/signing-key/signing.key"
GLUON_DIR="/gluon/gluon-repo"

# Sign every Manifest indicated
for manifest in $ACTION_MANIFEST_BRANCHES; do
	manifest_path="/gluon/output-dir/images/sysupgrade/$manifest.manifest"
	echo "$manifest_path"
	$GLUON_DIR/contrib/sign.sh "$SIGNING_KEY_PATH" "$manifest_path"
done
