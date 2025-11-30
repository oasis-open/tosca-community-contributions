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
            "errorReason": pErrorReason
            #"outputs": "not yet implemented"
        },
        "processorResult": {
            "stdout": result.stdout,
            "stderr": result.stderr,
            "return_code": result.returncode
        }
    }
    print(json.dumps(response, indent=2))

def main():
    file_path = sys.argv[1]

    ################################################
    # Modify the command below to run the TOSCA processor to be tested
    processor_command = ["my_tosca_tool", "--tosca-file", file_path]
    ################################################

    #Initialize variables
    pSuccess = False
    pError = False
    pErrorReason = ""
    
    # Confirm that the correct number of arguments were passed
    if len(sys.argv) != 2:
        print("Wrapper Usage: python wrapper.py <path_to_file>")
        sys.exit(101)

    # Confirm that the file exists
    if not os.path.isfile(file_path):
        print(f"Wrapper Error: {file_path} is not a valid file.")
        sys.exit(102)

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
    if ((result.stdout == 'PASS\n')):
        pSuccess = True
        printJsonResponse(pSuccess, pError, pErrorReason, processor_command, result)
        sys.exit(0)
    # Condition if the file was not valid TOSCA
    elif ((result.returncode == 1) and (result.stderr == 'TOSCA start line not found')):
        pError = True
        pErrorReason = "InvalidTOSCA"
        printJsonResponse(pSuccess, pError, pErrorReason, processor_command, result)

        sys.exit(1)
    # Condition if the file was valid TOSCA but the content could not be processed
    elif ((result.returncode == 1) and (result.stdout == "TOSCA file is valid but not deployable\n")):
        pError = True
        pErrorReason = "CannotActionFile"
        printJsonResponse(pSuccess, pError, pErrorReason, processor_command, result)
        sys.exit(2)
    # Condition if the TOSCA file could not be found or read
    elif (result.returncode == 1):
        pError = True
        pErrorReason = "CannotReadFile"
        printJsonResponse(pSuccess, pError, pErrorReason, processor_command, result)
        sys.exit(3)
    else:
        print(f"Wrapper got error from processor: An unknown error occurred with exit code {result.returncode}, error {result.stderr}, and stdout {result.stdout}")
        pError = True
        pErrorReason = "Unknown"
        printJsonResponse(pSuccess, pError, pErrorReason, processor_command, result)
        sys.exit(99)
    ################################################
    
if __name__ == "__main__":
    main()