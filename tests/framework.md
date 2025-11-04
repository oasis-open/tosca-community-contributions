# Framework

## Directory structure
TOSCA test files are held in a directory structure which reflects the paragraph names in the [TOSCA specification](https://github.com/oasis-tcs/tosca-specs). The actual directory names are taken from the anchor tags for each paragraph.

TOSCA files should be placed in the directory which corresponds to the section in which the tested syntax is defined. Some directories may be empty as the corresponding paragraph does not define any syntax. Test files for syntax which spans two or more paragraphs are allowed but there should be a text file in the corresponding directory pointing to the combined file.

## Directory Content

### The TOSCA file
Normally the test file will be TOSCA YAML file. It may also be a TOSCA CSAR file or any file which comprises a TOSCA CSAR file.
The naming convention for these files is as follows:
Some test files are taken directly from the snippets used in the specification, those keep the same filename which are of the form:
s<number>.yaml
Some of the snippets had to be changed as pytest prefers that filenames are unique across all sub-directories as they have the format, for example multiple uses of types.yaml in the specification snippets have been changed to <parent-directory-name>-types.yaml
Where snippets from the specification had to be changed by the addition of a suffix, i.e.
s<orginal number>a.yaml
There should be test files which are designed to be passed and those which are designed to fail.
Those which are designed to fail should have a filename which ends -inv.yaml although the earlier standard of  including the word 'invalid' in the filename is still allowed.
New test cases not taken from the specification should use the following naming convention, although older ones exist:
<directory name>-<content description using hyphen seprators><optional invalid indicator>.yaml
Some some test files are in CSAR format not simple yaml, these have the relevant extension e.g. .zip

### The pytest file
The expected result is held in a separate file in the same directory which will have a similar name with suffix of _test. e.g. if the tosca file is called valid.yaml the associated file will be named valid_test.py.

The metadata file is, at present, a Python file which defines a test and expected outcome using [pytest](https://docs.pytest.org/en/stable/#)

Each pytest file will be crafted to match the associated test file although expected that in most cases customization will be minimal. For an example pytest file see ./tests/tosca_2_0/tosca-definitions-version/version_test.py. It assumes the name of the file can be derived from its own name.

The pytest file may be adapted to create a CSAR file on the fly before sending it to the TOSCA processor under test. (An example is required.)

The pytest file calls a program called wrapper with a reference to the tosca file. Wrapper provides a standard interface to the TOSCA Processor under test and is further described in [validation](validation.md).

The pytest file includes code to assert that the result is as expected. Wrapper returns a standard set of numbered return codes which cover the expected standard results, these can probably be used in the assert statements for most expected results.

Wrapper also returns a json response containing details of the command which invoked the processor, the raw processor response and a standardized interpretation of those results. The json may be used in more complex assert statements and for debugging. In future it will also contain any TOSCA outputs. Here is an example:

```json
{
  "wrapper": {
    "executedCommand": [
      "my_tosca_tool",
      "--tosca-file",
      "~/tosca-community-contributions/tools/wrapper_tests/tosca/my_tosca_tool/valid.yaml"
    ],
    "success": true,
    "error": false,
    "errorReason": ""
  },
  "processor": {
    "stdout": "PASS\n",
    "stderr": "",
    "return_code": 0
  }
}
```

There is a program called py4yaml.sh in [tools/scripts](https://github.com/oasis-open/tosca-community-contributions/tools/scripts) which can be used to generate pytest files from TOSCA files.