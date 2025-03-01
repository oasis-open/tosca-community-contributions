import subprocess
import sys
import os



def main():
    print("Starting wrapper")

    if len(sys.argv) != 2:
        print("Wrapper Usage: python wrapper.py <path_to_file>")
        sys.exit(101)

    file_path = sys.argv[1]

    if not os.path.isfile(file_path):
        print(f"Wrapper Error: {file_path} is not a valid file.")
        sys.exit(102)

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
        print("Wrapper got success message from processor: The TOSCA was processed")
        print('Wrapper got {} from processor'.format(result.stdout))
        sys.exit(0)
    # Condition if the file was not valid TOSCA
    elif ((result.returncode == 1) and (result.stderr == 'TOSCA start line not found')):
        print("Wrapper got error from processor: The file is not valid TOSCA.")
        print('Wrapper got {} from processor'.format(result.stderr))
        sys.exit(1)
    # Condition if the file was valid TOSCA but the content could not be processed
    elif ((result.returncode == 1) and (result.stdout == "TOSCA file is valid but not deployable\n")):
        print("Wrapper got error from processor: The TOSCA content could not be processed.")
        sys.exit(2)
    # Condition if the TOSCA file could not be found or read
    elif (result.returncode == 1):
        print("Wrapper got error from processor: There was an error reading the TOSCA file.")
        sys.exit(3)
    else:
        print(f"Wrapper got error from processor: An unknown error occurred with exit code {result.returncode}, error {result.stderr}, and stdout {result.stdout}")
        sys.exit(99)
    
if __name__ == "__main__":
    main()