import subprocess
import sys
import os

def main():
    print("Starting wrapper")

    if len(sys.argv) != 2:
        print("Usage: python wrapper.py <path_to_file>")
        sys.exit(1)

    file_path = sys.argv[1]

    if not os.path.isfile(file_path):
        print(f"Error: {file_path} is not a valid file.")
        sys.exit(1)

    #result = subprocess.run(["pwd"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)    
    result = subprocess.run(
        # Modify the command below to run the TOSCA processor to be tested
        ["my_tosca_tool", "--tosca-file", file_path],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    # Modify the the conditions in the clauses to match the behavior of the TOSCA processor output
    # Ensure that each case has a unique matching condition

    # Condition if the TOSCA file was processed successfully
    if ((result.stdout == 'PASS\n')):
        print("Success: The TOSCA file was processed successfully.")
        sys.exit(0)
    # Condition if the file was not valid TOSCA
    elif ((result.returncode == 1) and (result.stderr == 'Error: Custom { kind: Other, error: "TOSCA start line not found" }\n')):
        print("Error: The file is not valid TOSCA.")
    # Condition if the file was valid TOSCA but the content could not be processed
    elif ((result.returncode == 1) and (result.stderr == 'Error: Custom { kind: Other, error: "TOSCA content could not be processed" }\n')):
        print("Error: The TOSCA content could not be processed.")
    # Condition if the TOSCA file could not be found or read
    elif (result.returncode == 1):
        print("Error: There was an error reading the TOSCA file.")
    else:
        print(f"Error: An unknown error occurred with exit code {result.returncode}, error {result.stderr}, and stdout {result.stdout}")
    
    


if __name__ == "__main__":
    main()