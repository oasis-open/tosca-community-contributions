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
    if not os.path.isfile(file_path):
        print(f"Wrapper Error: {file_path} is not a valid file.")
        sys.exit(102)

    file_path = sys.argv[1]

    file_dir = os.path.dirname(file_path)
    file_name = "TOSCA.meta"
    full_file_path = os.path.join(file_dir, file_name)

    with open(full_file_path, 'W') as file:
        file.write("CSAR-Version: 2.0")
        file.write("Created-By: Ubicity Corp.")
        file.write(f"Entry-Definitions: {full_file_path}")

    ################################################
    # Modify the command below to run the TOSCA processor to be tested
    processor_command = ["ubicity", "catalog",  "validate", file_dir]
    ################################################

    #Initialize variables
    pSuccess = False
    pError = False
    pErrorReason = ""

    #Run the processor
    result = subprocess.run(  
    processor_command,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True
    )

    ################################################
    # Modify the the conditions in the clauses below to match the behavior of the TOSCA processor output
    # Ensure that each case has a unique matching condition

    # Condition if the TOSCA file was processed successfully
    if ((result.returncode == 0)):
        pSuccess = True
        printJsonResponse(pSuccess, pError, pErrorReason, processor_command, result)
        sys.exit(0)
    # Condition if the file was not valid TOSCA
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

    os.remove(full_file_path)
    
if __name__ == "__main__":
    main()