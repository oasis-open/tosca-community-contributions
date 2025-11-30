import subprocess
import unittest
import os
import zipfile
from pathlib import Path


# Set the path to the tosca file
here = os.path.dirname(os.path.abspath(__file__))
# To save re-typing the tosca file name into every test file,
# guess that the tosca file has the same root as the name of this test file
# and that the extension is .yaml
tosca_file_path = here + '/' + Path(__file__).stem.split("_test")[0] + ".yaml"
# If not the case, then uncomment the following line and give the correct name of the tosca file
# tosca_file_path = here + '/version.yaml'
tosca_file_name = os.path.basename(tosca_file_path)

# Create a zip file to create a csar format file
zip_name = here + '/' + Path(tosca_file_path).with_suffix('.zip').name
with zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED) as zf:
    # Add the TOSCA.meta content directly using writestr
    tosca_meta_content = f"CSAR-Version: 2.0\nCreated-By: paul.m.jordan@outlook.com\nEntry-Definitions: {tosca_file_name}\n"
    zf.writestr('TOSCA.meta', tosca_meta_content)
    
    # Add the entry tosca file (use the basename of the tosca file path)
    zf.write(tosca_file_path, arcname=os.path.basename(tosca_file_path))
    
    # Now add the files referenced by the entry tosca file to the archive
    extras_path = os.path.join(here, 'io.kubernetes')
    # Write out the zip file 
    if os.path.exists(extras_path):
        zf.write(extras_path, arcname=os.path.join(os.path.basename(extras_path)))

# Set the path to the wrapper
wrapper_path = here + '/../../../tools/wrappers/wrapper.py'

class TestWrapperProgram(unittest.TestCase):

    def test_wrapper_with_version_yaml(self):
        command = (f'python3 {wrapper_path} {tosca_file_path}')
        result = subprocess.run(command, capture_output=True, text=True, shell=True)
        self.assertEqual(result.returncode, 0, 
                        f"Expected return code 0, but got {result.returncode} with message\n {result.stdout}\nLeaving zip file for inspection")
        # If the assertion passes, remove the zip file
        try:
            os.remove(zip_name)
        except FileNotFoundError:
            pass
