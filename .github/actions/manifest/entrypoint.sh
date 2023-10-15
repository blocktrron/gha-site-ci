#!/bin/bash

[ -n "$GLUON_REPO" ] || GLUON_REPO="/gluon/gluon-repo"
[ -n "$GLUON_ARTIFACT_INPUT_DIR" ] || GLUON_ARTIFACT_INPUT_DIR="/gluon/artifacts-input"
[ -n "$GLUON_ARTIFACT_OUTPUT_DIR" ] || GLUON_ARTIFACT_OUTPUT_DIR="/gluon/artifacts-output"
[ -n "$GLUON_RELEASE" ] || error 1
[ -n "$GLUON_PRIORITY" ] || GLUON_PRIORITY=1
[ -n "$GLUON_MANIFEST_BRANCHES" ] || error 1

ARTIFACT_TARGETS=""

ln -s /gluon/site-repo /gluon/gluon-repo/site

# Read target names to list
for filename in $GLUON_ARTIFACT_INPUT_DIR/*/ ; do
	artifact_folder_name="$(basename $filename)"
	echo "Target artifact: ${artifact_folder_name} (Full: ${filename})"

	ARTIFACT_TARGETS="${ARTIFACT_TARGETS} $artifact_folder_name"
done

echo "$ARTIFACT_TARGETS"

# Combine artifacts
for artifact_target in $ARTIFACT_TARGETS ; do
	# ToDo: Check if artifact in list. Only delete otherwise.
	echo "Combining ${artifact_target}"
	rsync -a ${GLUON_ARTIFACT_INPUT_DIR}/${artifact_target}/* "$GLUON_ARTIFACT_OUTPUT_DIR"
	rm -rf "${GLUON_ARTIFACT_INPUT_DIR}/${artifact_target}"
done

# Create manifest
make -C "$GLUON_REPO" update
for branch in $GLUON_MANIFEST_BRANCHES; do
	make -C "$GLUON_REPO" manifest \
		"-j$(nproc)" \
		"V=s" \
		"BROKEN=1" \
		"GLUON_RELEASE=$GLUON_RELEASE" \
		"GLUON_AUTOUPDATER_BRANCH=$branch" \
		"GLUON_PRIORITY=$GLUON_PRIORITY" \
		"GLUON_IMAGEDIR=$GLUON_ARTIFACT_OUTPUT_DIR/images"
done
