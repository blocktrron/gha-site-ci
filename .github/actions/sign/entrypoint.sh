#!/bin/bash

set -euxo pipefail

SIGNING_KEY_PATH="/gluon/signing-key/signing.key"
GLUON_DIR="/gluon/gluon-repo"
MANIFEST_PATH="/gluon/output-dir/images/sysupgrade/$ACTION_MANIFEST.manifest"

$GLUON_DIR/contrib/sign.sh "$SIGNING_KEY_PATH" "$MANIFEST_PATH"
