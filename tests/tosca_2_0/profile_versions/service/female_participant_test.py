# filepath: /home/paul/tosca-community-contributions/tools/scripts/../../tests/tosca_2_0/profile_versions/service/female_participant_test.py
import subprocess
import unittest
import os
from pathlib import Path

here = os.path.dirname(os.path.abspath(__file__))
tosca_file_path = here + '/female_participant.yaml'
wrapper_path = here + '/../../../tools/wrappers/wrapper.py'

class TestWrapperProgram(unittest.TestCase):
    def test_wrapper_with_yaml(self):
        command = f'python3 {wrapper_path} {tosca_file_path}'
        result = subprocess.run(command, capture_output=True, text=True, shell=True)
        # Expected pass
        self.assertEqual(result.returncode, 0,
                         f"Expected return code 0, but got {result.returncode} with message\n {result.stdout}")
