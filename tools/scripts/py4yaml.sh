#!/bin/bash

# This script traverses a sub-directory of a hardcoded directory in tests
# looking for TOSCA yaml files and checks if there is a matching Python
# file in the same directory. If not, it optionally creates either 
# an expected pass or an expected fail python file.
# The choice of pass or fail is made based on the name of the TOSCA file.

set -e

# Set TESTS_DIR relative to the script's location, so it works regardless of the current working directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$SCRIPT_DIR/../../tests/tosca_2_0"

# Function to determine expected result by filename
get_verdict() {
  local base="$1"
  if [[ "$base" == *-inv || "$base" == *invalid* ]]; then
    echo "fail"
  else
    echo "pass"
  fi
}

# Function to create a Python test file
create_pyfile() {
  local pyfile="$1"
  local base="$2"
  local verdict="$3"
  cat > "$pyfile" <<EOF

import subprocess
import unittest
import os
from pathlib import Path

# Set the path to the tosca file
here = os.path.dirname(os.path.abspath(__file__))
# To save re-typing the tosca file name into every test file,
# guess that the tosca file has the same root as the name of this test file
# and that the extension is .yaml
tosca_file_path = here + '/' + Path(__file__).stem.split("_test")[0] + ".yaml"

wrapper_path = here + '/../../../tools/wrappers/wrapper.py'

class TestWrapperProgram(unittest.TestCase):
    def test_wrapper_with_yaml(self):
        command = f'python3 {wrapper_path} {tosca_file_path}'
        result = subprocess.run(command, capture_output=True, text=True, shell=True)
        # Expected ${verdict}
        self.assertEqual(result.returncode, $([[ "$verdict" == "fail" ]] && echo 1 || echo 0),
                         f"Expected return code $([[ "$verdict" == "fail" ]] && echo 1 || echo 0), but got {result.returncode} with message\\n {result.stdout}")
EOF
  echo "Created $pyfile"
}

## Processing starts here

# Initialize an array to hold missing Python files
missing_pyfiles=()

# Find all .yaml files and check for corresponding _test.py files
while IFS= read -r yamlfile; do
  dir=$(dirname "$yamlfile")
  base=$(basename "$yamlfile" .yaml)
  pyfile="${dir}/${base}_test.py"
  if [ ! -f "$pyfile" ]; then
    missing_pyfiles+=("$yamlfile")
  fi
done < <(find "$TESTS_DIR" -type f -name "*.yaml")

# Report missing files and optionally create them
for yamlfile in "${missing_pyfiles[@]}"; do
  dir=$(dirname "$yamlfile")
  base=$(basename "$yamlfile" .yaml)
  pyfile="${dir}/${base}_test.py"
  short_pyfile="$(basename "$dir")/${base}_test.py"
  echo "Missing: $short_pyfile"
  verdict=$(get_verdict "$base")
  read -p "Create $verdict file ? [y/N] " yn
  if [[ $yn =~ ^[Yy]$ ]]; then
    create_pyfile "$pyfile" "$base" "$verdict"
  fi
done



