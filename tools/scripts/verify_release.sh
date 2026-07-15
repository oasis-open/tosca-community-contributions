#!/bin/bash
# Usage: ./verify_release.sh <artifact_name>.csar
#
# Verifies one downloaded CSAR: its SHA-256 against the signed checksums.txt, and
# its Sigstore keyless signature against the identity of the repo that produced
# it. Real releases come from oasis-open; override GITHUB_ORG when verifying a
# release cut from a fork (e.g. GITHUB_ORG=<user> ./verify_release.sh ...).

ARTIFACT=$1
GITHUB_ORG="${GITHUB_ORG:-oasis-open}"
REPO_NAME="${REPO_NAME:-tosca-community-contributions}"
BUNDLE="$ARTIFACT.bundle"
CHECKSUM_FILE="checksums.txt"

if [ -z "$ARTIFACT" ]; then
    echo "Usage: $0 <file.csar>"
    echo "Example: $0 community.tosca.core.0.1.csar"
    exit 1
fi

echo "--- 1. Checking SHA-256 Checksum ---"
if [ -f "$CHECKSUM_FILE" ]; then
    grep "$ARTIFACT" "$CHECKSUM_FILE" | sha256sum --check
else
    echo "Error: $CHECKSUM_FILE not found. Integrity check failed."
    exit 1
fi

echo -e "\n--- 2. Verifying Sigstore Keyless Signature ---"
# Strictly validate that the signature came from the $GITHUB_ORG/$REPO_NAME repo.
cosign verify-blob "$ARTIFACT" \
  --bundle "$BUNDLE" \
  --certificate-identity-regexp "https://github.com/$GITHUB_ORG/$REPO_NAME/.github/workflows/.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"

if [ $? -eq 0 ]; then
    echo -e "\n✅ Verification Successful: The artifact is authentic and untampered."
else
    echo -e "\n❌ Verification Failed!"
    exit 1
fi
