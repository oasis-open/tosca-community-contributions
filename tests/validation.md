# Validation

A TOSCA processor may be validated by ensuring that it responds correctly to a full suite of TOSCA files as defined in their associated pytest files (see [framework](framework.md) ).There should be test files which are designed to be passed and those which are designed to fail.

The pytest files cannot know in advance how to invoke a particular TOSCA processor nor how to interpret its response. Therefore a wrapper program is used to provide a standard interface towards pytest. A separate wrapper is needed for each TOSCA processor.

Three levels of testing are defined for TOSCA processors:

- **Level 1** Ensures that the processor can parse valid TOSCA and reject invalid files.
- **Level 2** Tests the ability of the processor to maintain and report on an internal representation model.
- **Level 3** Tests the ability of the processor to create, modify and delete real world implementations of nodes and relationships.

Current effort is directed at creating a complete set of tests for Level 1.


## Set-up

### Requirements

1. Install [python](https://www.python.org/) and ensure it is in your PATH
2. Install [pytest](https://docs.pytest.org/en/stable/index.html) and ensure it is in your PATH
3. Ensure TOSCA Processor to be tested is in your PATH
4. Modify the wrapper to match the operation of the TOSCA processor
    Further instructions on this step are provided in the [wrapper documentation](../tools/wrappers/README.md)

## Operation
The tests are invoked using the pytest command. pytest will scan the current or supplied directory for all the pytest files. So typically invoke it from ./tests

### Example Command

To run the tests, navigate to the directory containing the tests and use the following command:

```sh
pytest ./tests/tosca_2_0
```

You can also specify a particular test file or directory:

```sh
pytest path/to/test_file.py
```

