# filepath: /home/paul/tosca-community-contributions/tools/scripts/../../tests/tosca_2_0/artifact-type/artifact-type-no-root-inherited_test.py
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
        # Expected pass
        self.assertEqual(result.returncode, 0,
                         f"Expected return code 0, but got {result.returncode} with message\n {result.stdout}")
