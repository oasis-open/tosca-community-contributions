<div>
<h1>Contributing</h1>

<div>
<h2><a id="openParticipation">Public Participation Invited</a></h2>

<p>This <a href="https://www.oasis-open.org/resources/open-repositories">OASIS Open Repository</a> ( <b><a href="https://github.com/oasis-open/tosca-test-assertions">github.com/oasis-open/tosca-test-assertions</a></b> ) is a community public repository that supports participation by anyone, whether affiliated with OASIS or not.  Substantive contributions (repository "code") and related feedback is invited from all parties, following the common conventions for participation in GitHub public repository projects.  Participation is expected to be consistent with the <a href="https://www.oasis-open.org/policies-guidelines/open-repositories">OASIS Open Repository Guidelines and Procedures</a>, the <a href="https://www.oasis-open.org/sites/www.oasis-open.org/files/Apache-LICENSE-2.0.txt">LICENSE</a> designated for this particular repository (Apache License v 2.0), and the requirement for an <a href="https://www.oasis-open.org/resources/open-repositories/cla/individual-cla">Individual Contributor License Agreement</a>.  Please see the repository <a href="https://github.com/oasis-open/tosca-test-assertions/blob/master/README.md">README</a> document for other details.</p>
</div>


<div>
<h2><a id="distinctRules">Governance Distinct from OASIS TC Process</a></h2>
<p>Content accepted as "contributions" to this Open Repository, as <a href="#openRepoContribution">defined</a> below, are distinct from any <a href="https://www.oasis-open.org/policies-guidelines/ipr#contributions">Contributions</a> made to the associated <a href="https://www.oasis-open.org/committees/tosca/">OASIS Topology and Orchestration Specification for Cloud Applications (TOSCA) TC</a> itself.  Participation in the associated Technical Committee is governed by the <a href="https://www.oasis-open.org/policies-guidelines/bylaws">OASIS Bylaws</a>, <a href="https://www.oasis-open.org/policies-guidelines/tc-process">OASIS TC Process</a>, <a href="https://www.oasis-open.org/policies-guidelines/ipr">IPR Policy</a>, and related <a href="https://www.oasis-open.org/policies-guidelines/">policies</a>.  This Open Repository is not subject to the OASIS TC-related policies.  Open Repository governance is defined by separate <a href="https://www.oasis-open.org/policies-guidelines/open-repositories">participation and contribution guidelines</a> as referenced in the <a href="https://www.oasis-open.org/resources/open-repositories/">OASIS Open Repositories Overview</a>.</p>
</div>

<div>
<h2><a id="distinctLicenses">Licensing Distinct from OASIS IPR Policy</a></h2>
<p>Because different licenses apply to the OASIS TC's specification work, and this Open Repository, there is no guarantee that the licensure of specific repository material will be compatible with licensing requirements of an implementation of a TC's specification.  Please refer to the <a href="https://github.com/oasis-open/tosca-test-assertions/blob/master/LICENSE">LICENSE file</a> for the terms of this material, and to the OASIS IPR Policy for <a href="https://www.oasis-open.org/policies-guidelines/ipr#RF-on-Limited-Mode">the terms applicable to the TC's specifications</a>, including any applicable <a href="https://www.oasis-open.org/committees/tosca/ipr.php">declarations</a>.</p>
</div>

<div>
<h2><a id="contributionDefined">Contributions Subject to Individual CLA</a></h2>

<p>Formally, <a id="openRepoContribution">"contribution"</a> to this Open Repository refers to content merged into the "Code" repository (repository changes represented by code commits), following the GitHub definition of <i><a href="https://help.github.com/articles/github-glossary/#contributor">contributor</a></i>: "someone who has contributed to a project by having a pull request merged but does not have collaborator [<i>i.e.</i>, direct write] access."  Anyone who signs the Open Repository <a href="https://www.oasis-open.org/resources/open-repositories/cla/individual-cla">Individual Contributor License Agreement (CLA)</a>, signifying agreement with the licensing requirement, may contribute substantive content &mdash; subject to evaluation of a GitHub pull request.  The main web page for this repository, as with any GitHub public repository, displays a link to a document listing contributions to the repository's default branch (filtered by Commits, Additions, and Deletions).</p>

<p>This Open Repository, as with GitHub public repositories generally, also accepts public feedback from any GitHub user.  Public feedback includes opening issues, authoring and editing comments, participating in conversations, making wiki edits, creating repository stars, and making suggestions via pull requests.  Such feedback does not constitute an OASIS Open Repository <a href="#openRepoContribution">contribution</a>.   Some details are presented under "Read permissions" in the table of <a href="https://help.github.com/articles/repository-permission-levels-for-an-organization/">permission levels</a> for a GitHub organization.  Technical content intended as a substantive contribution (repository "Code") to an Open Repository is subject to evaluation, and requires a signed Individual CLA.</p>


</div>

<div>
<h2><a id="fork-and-pull-model">Fork-and-Pull Collaboration Model</a></h2>

<p>OASIS Open Repositories use the familiar <a href="https://help.github.com/articles/using-pull-requests/#fork--pull">fork-and-pull</a> collaboration model supported by GitHub and other distributed version-control systems.  Any GitHub user wishing to contribute should <a href="https://help.github.com/articles/github-glossary/#fork">fork</a> the repository, make additions or other modifications, and then submit a pull request.  GitHub pull requests should be accompanied by supporting <a href="https://help.github.com/articles/commenting-on-the-diff-of-a-pull-request/">comments</a> and/or <a href="https://help.github.com/articles/about-issues/">issues</a>. Community conversations about pull requests, supported by GitHub <a href="https://help.github.com/articles/about-notifications/">notifications</a>, will provide the basis for a consensus determination to merge, modify, close, or take other action, as communicated by the repository <a href="https://www.oasis-open.org/resources/open-repositories/maintainers-guide">Maintainers</a>.</p>
</div>

<div>
<h2><a id="feedback">Feedback</a></h2>

<p>Questions or comments about this Open Repository's activities should be composed as GitHub issues or comments. If use of an issue/comment is not possible or appropriate, questions may be directed by email to the <a href="https://github.com/oasis-open/tosca-test-assertions/blob/master/README.md#maintainers">repository Maintainer(s)</a>.  Please send general questions about Open Repository participation to OASIS Staff at <a href="mailto:repository-admin@oasis-open.org">repository-admin@oasis-open.org</a> and any specific CLA-related questions to <a href="mailto:repository-cla@oasis-open.org">repository-cla@oasis-open.org</a>.</p>

</div>

</div>

# Contribution Guide

Pull requests in order to be properly validated and accepted should follow the constraints defined below:

* Pull requests should not contains too many tests as it will take longer to review them. They also may be rejected even if only a single test is rejected..
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
  oasis.testAssertion.tags.errors: <optional error_code>, <optional error_code>
  oasis.testAssertion.tags.errors_lines: <optional error_line>, <optional error_line>
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
    * **&lt;optional error_code&gt;** is a coma separated list of error codes (also expressed in the predicate) in case of expected parsing errors.
    * **&lt;optional error_line&gt;** is a coma separated list of error lines in the document the list of line numbers must match the list of error codes in the errors section.
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
  oasis.testAssertion.target: a tosca template that has a valid tosca_definitions_version value equals to 'tosca_simple_yaml_1_0'.
  oasis.testAssertion.predicate: >
    When parsing the template
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