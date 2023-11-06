#!/bin/bash

[ -n "$ACTION_MANIFEST" ] || exit 1

SIGNING_KEY_PATH="/gluon/signing-key/signing.key"
GLUON_DIR="/gluon/gluon-repo"

manifest_path="/gluon/output-dir/images/sysupgrade/$ACTION_MANIFEST.manifest"
echo "$manifest_path"
$GLUON_DIR/contrib/sign.sh "$SIGNING_KEY_PATH" "$manifest_path"
