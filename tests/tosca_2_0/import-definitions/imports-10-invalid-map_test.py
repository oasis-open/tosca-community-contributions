# filepath: /home/paul/tosca-community-contributions/tools/scripts/../../tests/tosca_2_0/import-definitions/imports-10-invalid-map_test.py
import subprocess
import unittest
import os
from pathlib import Path

here = os.path.dirname(os.path.abspath(__file__))
tosca_file_path = here + '/imports-10-invalid-map.yaml'
wrapper_path = here + '/../../../tools/wrappers/wrapper.py'

class TestWrapperProgram(unittest.TestCase):
    def test_wrapper_with_yaml(self):
        command = f'python3 {wrapper_path} {tosca_file_path}'
        result = subprocess.run(command, capture_output=True, text=True, shell=True)
        # Expected fail
        self.assertEqual(result.returncode, 1,
                         f"Expected return code 1, but got {result.returncode} with message\n {result.stdout}")
