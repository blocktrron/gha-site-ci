#!/bin/bash

set -ef

OUTPUT_FILE="$1"

# Install dependencies
# apt-get update
# apt-get install -y make git jq

# Clone repository & Checkout
git clone https://github.com/freifunk-gluon/gluon.git gluon
cd gluon
git checkout "${GLUON_VERSION}"
ln -s docs/site-example site

# Get Target list
make list-targets "BROKEN=${BROKEN}" | jq  --raw-input .  | jq --slurp . | jq -c . > "${OUTPUT_FILE}"
