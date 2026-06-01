
import subprocess
import unittest
import os
from pathlib import Path

here = os.path.dirname(os.path.abspath(__file__))
tosca_file_path = here + '/artifacts.yaml'
def _find_wrapper():
    d = os.path.dirname(os.path.abspath(__file__))
    while d != os.path.dirname(d):
        candidate = os.path.join(d, 'tools/wrappers/wrapper.py')
        if os.path.isfile(candidate):
            return candidate
        d = os.path.dirname(d)
    raise FileNotFoundError('wrapper.py not found')
wrapper_path = _find_wrapper()

class TestWrapperProgram(unittest.TestCase):
    def test_wrapper_with_yaml(self):
        command = f'python3 {wrapper_path} {tosca_file_path}'
        result = subprocess.run(command, capture_output=True, text=True, shell=True)
        # Expected pass
        self.assertEqual(result.returncode, 0,
                         f"Expected return code 0, but got {result.returncode} with message\n {result.stdout} {result.stderr}")
