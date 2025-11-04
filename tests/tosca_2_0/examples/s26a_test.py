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

tosca_meta_file_path = "TOSCA.meta"
with open(tosca_meta_file_path, 'w') as file:
    file.write("CSAR-Version: 2.0\n")
    file.write("Created-By: paul.m.jordan@outlook.com\n")
    file.write(f"Entry-Definitions: {tosca_file_name}\n")

# Create a zip file containing the TOSCA.meta and the TOSCA definition file
zip_name = Path(tosca_file_path).with_suffix('.zip').name
with zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED) as zf:
    # Add the TOSCA.meta (created in the current working directory)
    zf.write(tosca_meta_file_path, arcname=os.path.basename(tosca_meta_file_path))
    # Add the tosca file (use the basename inside the archive)
    zf.write(tosca_file_path, arcname=os.path.basename(tosca_file_path))
    # Also add the types file under the types/ directory inside the archive
    types_path = os.path.join(here, 'types', 'examples-mytypes.yaml')
    if os.path.exists(types_path):
        zf.write(types_path, arcname=os.path.join('types', os.path.basename(types_path)))

# Remove the temporary TOSCA.meta file (keep the zip)
os.remove(tosca_meta_file_path)

# Set the path to the wrapper
wrapper_path = here + '/../../../tools/wrappers/wrapper.py'

class TestWrapperProgram(unittest.TestCase):

    def test_wrapper_with_version_yaml(self):
        command = (f'python3 {wrapper_path} {tosca_file_path}')
        result = subprocess.run(command, capture_output=True, text=True, shell=True)
        self.assertEqual(result.returncode, 0, 
                        f"Expected return code 0, but got {result.returncode} with message\n {result.stdout}")
        # finally:
        #     # Remove the created zip file during cleanup
        try:
            os.remove(zip_name)
        except FileNotFoundError:
            pass
