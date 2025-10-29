#!/bin/bash

# Exit on first error
set -e

# Reset log file
sudo rm -f /var/log/ubicity/ubicity.log || true

# Find directories
HERE=$(dirname "$(readlink --canonicalize "$BASH_SOURCE")")

# Re-initialize Ubicity
ubctreset

# Onboard profiles
${HERE}/onboard_profiles.sh

# Onboard substituting templates into catalog
${HERE}/onboard_substitutions.sh

# Onboard platform resources
${HERE}/onboard_resources.sh
