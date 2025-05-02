import subprocess
import sys
import os

import json

def printJsonResponse(pSuccess, pError, pErrorReason, processor_command, result):
    response = {
        "wrapper": {
            "executedCommand": processor_command,
            "success": pSuccess,
            "error": pError,
            "errorReason": pErrorReason,
            "outputs": "not yet implemented"
        },
        "processorResult": {
            "stdout": result.stdout,
            "stderr": result.stderr,
            "return_code": result.returncode
        }
    }
    print(json.dumps(response, indent=2))

def main():
    # Confirm that the correct number of arguments were passed
    if len(sys.argv) != 2:
        print("Wrapper Usage: python wrapper_ubicity.py <path_to_file>")
        sys.exit(101)

    # Confirm that the file exists
    file_path = sys.argv[1]
    if not os.path.isfile(file_path):
        print(f"Wrapper Error: {file_path} is not a valid file.")
        sys.exit(102)

    # Ubicity requires TOSCA.meta file.
    file_dir = os.path.dirname(file_path)
    file_name = os.path.basename(file_path)
    tosca_meta_file_path = os.path.join(file_dir, "TOSCA.meta")
    with open(tosca_meta_file_path, 'w') as file:
        file.write("CSAR-Version: 2.0\n")
        file.write("Created-By: Ubicity Corp.\n")
        file.write(f"Entry-Definitions: {file_name}\n")

    # Initialize variables
    pSuccess = False
    pError = False
    pErrorReason = ""

    # Run the processor
    processor_command = ["ubicity", "catalog",  "validate", file_dir]
    result = subprocess.run(  
        processor_command,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True
    )

    # Clean up
    os.remove(tosca_meta_file_path)
    
    # Condition if the TOSCA file was processed successfully
    if ((result.returncode == 0)):
        pSuccess = True
        printJsonResponse(pSuccess, pError, pErrorReason, processor_command, result)
        sys.exit(0)
    # Condition if the file was not valid TOSCA. Error codes above 100
    # indicate invalid TOSCA.
    elif ((result.returncode >= 100)):
        pError = True
        pErrorReason = "InvalidTOSCA"
        printJsonResponse(pSuccess, pError, pErrorReason, processor_command, result)
        sys.exit(1)
    else:
        print(f"Wrapper got error from processor: An unknown error occurred with exit code {result.returncode}, error {result.stderr}, and stdout {result.stdout}")
        pError = True
        pErrorReason = "Unknown"
        printJsonResponse(pSuccess, pError, pErrorReason, processor_command, result)
        sys.exit(99)
    ################################################

if __name__ == "__main__":
    main()
