import subprocess
import unittest
import os
from pathlib import Path
import pytest

# Set the path to the tosca file
here = os.path.dirname(os.path.abspath(__file__))
# To save re-typing the tosca file name into every test file,
# guess that the tosca file has the same root as the name of this test file
# and that the extension is .yaml
tosca_file_path = here + '/' + Path(__file__).stem.split("_test")[0] + ".yaml"
# If not the case, then uncomment the following line and give the correct name of the tosca file
# tosca_file_path = here + '/version.yaml'

# Set the path to the wrapper
wrapper_path = here + '/../../../tools/wrappers/wrapper.py'

class TestWrapperProgram(unittest.TestCase):

    def test_wrapper_with_version_yaml(self):
        command = (f'python3 {wrapper_path} {tosca_file_path}')
        result = subprocess.run(command, capture_output=True, text=True, shell=True)
        self.assertEqual(result.returncode, 1, 
                         f"Expected return code 1, but got {result.returncode} with message\n {result.stdout}")
