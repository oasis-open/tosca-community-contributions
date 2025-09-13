---
applyTo: 'tests/tosca_2_0/*/*.yaml'
---
# Instructions to github copilot for TOSCA 2.0 tests

When creating TOSCA 2.0 tests, follow these guidelines:


Each new test should be in its own .yaml file


The format of each invalid Tosca test file should be as follows:

<parent directory name>_<two digit sequence number of invalid tests>_invalid_<brief description>.yaml

Use underscores to separate words in the name of each TOSCA file

Do not create new directories for TOSCA tests. All TOSCA tests should be in the existing directory structure.

When creating a new invalid TOSCA test include a comment at the top of the file that describes the error in the test.

# Copilot cannot currently create pytest tests for TOSCA tests. You must create these manually.
Each TOSCA test should have a corresponding pytest in a file named <name of TOSCA test>_test.py

Each pytest should be in the same directory as the TOSCA test it is testing.