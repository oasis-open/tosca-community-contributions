# README
This directory contains TOSCA service templates that can be used to test TOSCA tools and orchestrator compliance. The intent is for each item to contain metadata that describes the test and the expected behavior of the tool or orchestrator under test.

## Creating metadata
Currently the only format used for metadata is pytest. Further details are contained in [test framework](framework.md). However note that OASIS Test Assertion Markup Language exists and could be used.

## Using the tests
Where pytest metadata exists it can be used to execute tests of a target TOSCA processor. The intention is to have a full set of tests and metadata which can be used to validate a processor. Further details on how to do this are in [validation](validation.md).

