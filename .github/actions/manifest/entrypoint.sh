#!/bin/bash

[ -n "$GLUON_REPO" ] || GLUON_REPO="/gluon/gluon-repo"
[ -n "$GLUON_ARTIFACT_DIR" ] || GLUON_ARTIFACT_DIR="/gluon/artifacts"
[ -n "$GLUON_RELEASE" ] || error 1
[ -n "$GLUON_PRIORITY" ] || GLUON_PRIORITY=1
[ -n "$GLUON_MANIFEST_BRANCHES" ] || error 1

ln -s /gluon/site-repo /gluon/gluon-repo/site

# Parse list of targets to build manifest for
PARSED_TARGET_LIST="$(cat /gluon/action-data/targets.list)"

# Read target names to list
ARTIFACT_NAMES=""
for filename in $GLUON_ARTIFACT_DIR/*/ ; do
	artifact_folder_name="$(basename $filename)"
	echo "Target artifact: ${artifact_folder_name} (Full: ${filename})"

	ARTIFACT_NAMES="${ARTIFACT_NAMES} $artifact_folder_name"
done

# Combine artifacts
mkdir "$GLUON_ARTIFACT_DIR/output"
for artifact_target in $ARTIFACT_NAMES ; do
	# Check if artifact in list. Only delete otherwise.
	if [ -n "$PARSED_TARGET_LIST" ] && [[ "$PARSED_TARGET_LIST" =~ "$artifact_target" ]]; then
		echo "Combining ${artifact_target}"
		# Unpack archive
		tar xf "${GLUON_ARTIFACT_DIR}/${artifact_target}/output.tar.gz" -C "${GLUON_ARTIFACT_DIR}/${artifact_target}"
		rm "${GLUON_ARTIFACT_DIR}/${artifact_target}/output.tar.gz"

		# Combine targets
		rsync -a ${GLUON_ARTIFACT_DIR}/${artifact_target}/* "$GLUON_ARTIFACT_DIR/output"
	else
		echo "Skipping ${artifact_target}"
	fi
	rm -rf "${GLUON_ARTIFACT_DIR}/${artifact_target}"
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
		"GLUON_IMAGEDIR=$GLUON_ARTIFACT_DIR/output/images"
done

# Copy Manifests to dedicated directory
mkdir -p "$GLUON_ARTIFACT_DIR/manifests"
find "$GLUON_ARTIFACT_DIR/output/images/sysupgrade" -name "*.TIF" -exec cp {} $GLUON_ARTIFACT_DIR/manifests \;

# Pack output
tar czf "$GLUON_ARTIFACT_DIR/manifests.tar.gz" -C "$GLUON_ARTIFACT_DIR" manifests
rm -rf "$GLUON_ARTIFACT_DIR/output"
rm -rf "$GLUON_ARTIFACT_DIR/manifests"
