---
applyTo: 'tests/tosca_2_0/*/*.yaml'
---
# Instructions to github copilot for TOSCA 2.0 tests

When creating TOSCA 2.0 tests, follow these guidelines:


Each new test should be in its own .yaml file


The format of each invalid Tosca test file should be as follows:

<parent directory name>-<brief description>-inv.yaml

Use underscores to separate words in the name of each TOSCA file

Do not create new directories for TOSCA tests. All TOSCA tests should be in the existing directory structure.

When creating a new invalid TOSCA test include a comment at the top of the file that describes the error in the test.

Do not include use tags like # tag::s38[] / # end::s38[] when creating negative TOSCA tests.

