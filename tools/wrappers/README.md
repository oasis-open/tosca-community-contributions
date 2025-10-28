# Wrappers Directory

To prepare testing of a particular TOSCA processor

1. Copy wrapper_example.py to wrapper_<your_tool>.py
2. Modify wrapper_<your_tool>.py to call the processor to be tested and correctly interpret the results, see inline comments.
3. Copy wrapper_<your_tool>.py to wrapper.py

Note that wrapper.py is included in .gitignore.
