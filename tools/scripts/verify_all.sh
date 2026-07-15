#!/bin/bash
# verify_all.sh - Verifies all CSAR files in the current directory.

# Absolute path of this script's directory, so verify_release.sh is found
# regardless of where this is invoked from.
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
VERIFY_SCRIPT="$SCRIPT_DIR/verify_release.sh"

if [ ! -f "$VERIFY_SCRIPT" ]; then
    echo "Error: Could not find $VERIFY_SCRIPT"
    exit 1
fi
chmod +x "$VERIFY_SCRIPT"

# CSAR files in the CURRENT working directory (the download folder).
shopt -s nullglob
artifacts=(*.csar)

if [ ${#artifacts[@]} -eq 0 ]; then
    echo "No .csar files found in $(pwd). Please run this from your download folder."
    exit 1
fi

echo "Starting batch verification for all CSAR artifacts..."
echo "----------------------------------------------------"

for artifact in "${artifacts[@]}"; do
    echo "Verifying: $artifact"
    "$VERIFY_SCRIPT" "$artifact"
    if [ $? -ne 0 ]; then
        echo "❌ Batch verification failed at $artifact"
        exit 1
    fi
    echo "----------------------------------------------------"
done

echo "✅ All artifacts verified successfully!"
