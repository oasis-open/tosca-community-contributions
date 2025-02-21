import subprocess
import unittest
import os
import pytest


class TestWrapperProgram(unittest.TestCase):
    print("Running tests for wrapper.py")
    print("Current directory:", os.getcwd())
    def test_wrapper_with_version_yaml(self):
        result = subprocess.run(
            'python3 /home/paul/tosca-community-contributions/tools/wrappers/wrapper.py '
            '/home/paul/tosca-community-contributions/tests/tosca_2_0/tests_with_v2_0_heading_names/tosca-definitions-version/version.yaml',
            capture_output=True, text=True, shell=True
        )
        print("Result: ", result)
        self.assertEqual(result.returncode, 0, f"Expected return code 0, but got {result.returncode}")

if __name__ == '__main__':
    unittest.main()