#!/bin/bash

# Generate space-separated list of targets to combine
TARGET_LIST=""
if [ -n "$ACTION_TARGETS" ]; then
    TARGET_LIST=$(echo "$ACTION_TARGETS" | jq -r '.[]' | paste -sd ' ')
fi

# Read target names to list
ARTIFACT_NAMES=""
for filename in $ACTION_ARTIFACT_DIR/*/ ; do
	artifact_folder_name="$(basename $filename)"
	echo "Target artifact: ${artifact_folder_name} (Full: ${filename})"

	ARTIFACT_NAMES="${ARTIFACT_NAMES} $artifact_folder_name"
done

# Combine artifacts
ARTIFACT_OUT_DIR="$RUNNER_TEMP/output"
mkdir "$ARTIFACT_OUT_DIR"
for artifact_target in $ARTIFACT_NAMES ; do
	# Check if artifact in list. Only delete otherwise.
	if [ -n "$PARSED_TARGET_LIST" ] && [[ "$PARSED_TARGET_LIST" =~ "$artifact_target" ]]; then
		echo "Combining ${artifact_target}"

		# Unpack archive
		tar xf "${ACTION_ARTIFACT_DIR}/${artifact_target}/output.tar.gz" -C "${ACTION_ARTIFACT_DIR}/${artifact_target}"
		rm "${ACTION_ARTIFACT_DIR}/${artifact_target}/output.tar.gz"

		# Combine targets
		rsync -a ${ACTION_ARTIFACT_DIR}/${artifact_target}/* "$ARTIFACT_OUT_DIR"
	else
		echo "Skipping ${artifact_target}"
	fi
	rm -rf "${ACTION_ARTIFACT_DIR}/${artifact_target}"
done

# Remove all artifacts
rm -rf "${ACTION_ARTIFACT_DIR}/*"

# Move combined artifacts to artifact directory
mv "$ARTIFACT_OUT_DIR" "$ACTION_ARTIFACT_DIR"
