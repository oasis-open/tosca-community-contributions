# tosca-validation

This repository aims to contains tests scenarios and templates that will allow validation of TOSCA tools against the standard.

The content of the repository is not officially recognized by TOSCA TC or TOSCA Interoperability SC.

However this repository may be moved later under OASIS repository. Based on that any people that will issue pull-requests agree that the IP related to it's pull-request will follow OASIS TOSCA TC rules and be owned by OASIS.

# How to contribute

In order to contribute to this repository you should Fork the repository, add some tests on your fork and issue a pull-request that respect the following constraints:

* The pull-request must not contains too many tests in order to ease the review of the pull-request.
* If a pull-request define multiple tests they must all be variants aiming to validate the same element of the specification
* The test template must be placed in the folder matching the conformance target (Parser-Validator or Orchestrator)
* The test template can be a yaml TOSCA template OR an unzipped TOSCA archive in a folder.
* The TOSCA template or Archive's entry TOSCA template must contains a *metadata* section that defines the test assertion expected from parsing the template as defined bellow:

```yaml
metadata:
  oasis.testAssertion.id: <test assertion id>
  oasis.testAssertion.description: <description>
  oasis.testAssertion.prerequisite: <optional prerequisite>
  oasis.testAssertion.target: <required target>
  oasis.testAssertion.predicate: <required predicate>
  oasis.testAssertion.prescription_level: <required level>
  oasis.testAssertion.normativeSource.refSourceItem.documentId: <required id of the normative source under test>
  oasis.testAssertion.normativeSource.refSourceItem.versionId: <required version of the normative source>
  oasis.testAssertion.normativeSource.textSourceItem.section: <required section>
  oasis.testAssertion.normativeSource.textSourceItem.line: <optional line>
  oasis.testAssertion.tags.conformancetarget: <required conformance target>
```

  * Where:
    * **&lt;test assertion id&gt;:** unique id of the test assertion and must follow the following pattern:
&lt;oasis.testAssertion.normativeSource.textSourceItem.section&gt;-&lt;element under test&gt;-&lt;test variant id&gt;-&lt;optional short description&gt;.
    * **&lt;optional prerequisite&gt;:** association (corresponding to the Prerequisite termin- ology definition) expresses a pre-condition to be satisfied by the &lt;Target&gt; in order to qualify for the test expressed by the &lt;Predicate&gt;. It is a boolean expression: if evaluates to "true", the &lt;Predicate&gt; can be evaluated over the &lt;Target&gt;. If evaluates to "false", the &lt;Target&gt; is not qualified for this test assertion.
    * **&lt;required target&gt;** target that will be validated by the predicate.
    * **&lt;required predicate&gt;:** association (corresponding to the Predicate terminology definition) expresses the feature or behavior expected from the &lt;Target&gt; as stated in &lt;NormativeSource&gt;. It is a boolean expression: if evaluates to "true", the &lt;Target&gt; instance exhibits the expected feature. If "false", the &lt;Target&gt; does not.
    * **&lt;required level&gt;** the level of prescription of the test (*mandatory*, *preferred* or *permitted*).
    * **&lt;required id of the normative source under test&gt;** Id of the normative source targeted by the test assertion (*tosca_simple_yaml_1_0*).
    * **&lt;required version of the normative source&gt;** Version of the normative source targeted by the test assertion (*1.0.0*).
    * **&lt;required section&gt;** Number of the section in the normative source.
    * **&lt;optional line&gt;** Optional line from the normative source.
    * **&lt;required conformance target&gt;** the tool that is targeted by the test assertion Parser-Validator or Orchestrator.

  * Example:

```yaml
metadata:
  oasis.testAssertion.id: 3.1.2-tosca_definitions_version-01-valid-definition
  oasis.testAssertion.description: Parsing a document with valid tosca definition version MUST succeed.
  oasis.testAssertion.target: The 'tosca_definitions_version' value out of the parsing.
  oasis.testAssertion.predicate: >
    assert 'tosca_definitions_version' value is equal to 'http://docs.oasis-open.org/tosca/ns/simple/yaml/1.0' or 'tosca_simple_yaml_1_0'
  oasis.testAssertion.prescription_level: mandatory
  oasis.testAssertion.normativeSource.refSourceItem.documentId: tosca_simple_yaml_1_0
  oasis.testAssertion.normativeSource.refSourceItem.versionId: 1.0.0
  oasis.testAssertion.normativeSource.textSourceItem.section: 3.1.2
  oasis.testAssertion.tags.conformancetarget: Parser-Validator
```

* The name of the TOSCA template or archive folder MUST be equal to the test assertion id (for example *3.1.2-tosca_definitions_version-01-valid-definition.yml*):
* The predicate expression must follow the following patterns:
  * assert &lt;target&gt; value is equal to &lt;expected value&gt; (or &lt;other expected value&gt; ...)
  * assert raises the error &lt;error_id&gt; (and error &lt;error_id&gt; ...)

# Approval process

Even if the repository is not recognized as and official material by the OASIS TOSCA TC or TOSCA Interoperability SC the approval process is managed by the TOSCA Interoperability SC.

Pull-requests will be validated during the TOSCA Interoperability SC and may be used as a basis for the establishment of the official test assertion document.

**Note:** TOSCA Interoperability SC meets every two week actually and you may expect some delay in the approval of the pull-requests.
