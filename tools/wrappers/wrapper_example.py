import sys
import os

def main():
    if len(sys.argv) != 2:
        print("Usage: python wrapper.py <path_to_file>")
        sys.exit(1)

    file_path = sys.argv[1]

    if not os.path.isfile(file_path):
        print(f"Error: {file_path} is not a valid file.")
        sys.exit(1)

# Modify the command to run the TOSCA processor to be tested
    os.system(f"my_tosca_tool --tosca-file {file_path}")

if __name__ == "__main__":
    main()