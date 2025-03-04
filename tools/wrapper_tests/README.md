# Framework tests

This directory holds tests to confirm correct operation of the test framework itself.

It requires a stub TOSCA processor, [my_tosca_tool](https://github.com/pmjordan/my_tosca_tool), for correct operation. 

1. Copy tools/wrapper_example.py to tools/wrapper.py
2. Make sure that my_tosca_tool is installed and in the path
3. Invoke pytest from this directory.
