#!/bin/bash

[ -n "$ACTION_OUTPUT_DIR" ] || exit 1
[ -n "$ACTION_SIGNING_KEY" ] || exit 1
[ -n "$ACTION_MANIFEST_BRANCHES" ] || exit 1

SIGNING_KEY_PATH="/gluon/signing-key/signing.key"
GLUON_DIR="/gluon/gluon-repo"

# Unpack artifacts
tar xf /gluon/output-dir/output.tar.gz -C /gluon/output-dir
rm /gluon/output-dir/output.tar.gz

# Sign every Manifest indicated
for manifest in $ACTION_MANIFEST_BRANCHES; do
	manifest_path="/gluon/output-dir/output/images/sysupgrade/$manifest.manifest"
	echo "$manifest_path"
	$GLUON_DIR/contrib/sign.sh "$SIGNING_KEY_PATH" "$manifest_path"
done

tar czf /gluon/output-dir/output.tar.gz -C /gluon/output-dir output