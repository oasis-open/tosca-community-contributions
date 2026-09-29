# Conformance Clause Coverage

**Status:** Proposal — for discussion.
**Audience:** TOSCA Community; implementers planning to self-certify against TOSCA 2.0.
**Purpose:** Index the test suite by the conformance clauses of TOSCA 2.0 Chapter 18, so that an
implementer can run the tests for a clause, see which statements of that clause the tests cover,
and state a self-certification claim against the clause rather than against a list of sections.

**Related documents:** [README](README.md) · [framework](framework.md) ·
[validation](validation.md) ·
[TOSCA 2.0, Chapter 18](https://github.com/oasis-tcs/tosca-specs/blob/published/tosca_2_0/TOSCA-v2.0-os.md#conformance)

*Drafted with an AI assistant (Claude); the counts below were produced by script from the
repository as of 2026-09-29 and reviewed by the author.*

---

## Why the suite needs a clause view

OASIS does not run a certification program; each Technical Committee defines how conformance to
its specification is established. For TOSCA 2.0 the starting point is self-certification: an
implementer runs this suite against its tool and publishes the result. A claim of conformance is
made against a **conformance clause** — TOSCA 2.0 §18.2 to §18.6 define five, one per
conformance target — and other standards that build on TOSCA reference those clauses by number.

The suite is organized by specification **section**, one directory per section anchor, as
[framework](framework.md) describes. That makes coverage of a section legible, but a clause
cites sections selectively and adds requirements that no single section holds, so today:

- nothing tells an implementer which tests to run to claim Clause 2 or Clause 3;
- the directories `conformance-clause-2-tosca-processor`, `conformance-clause-3-tosca-orchestrator`
  and `conformance-clause-5-tosca-archive` hold only a `.gitignore`;
- a passing run says "these files were accepted or rejected as expected", which is evidence for
  some clause statements and says nothing about others.

## What the suite checks today

The suite has 422 test cases under `tosca_2_0/`. Each one asserts the wrapper's return code:
266 expect `0` (the processor accepts the file) and 155 expect `1` (the processor rejects it).
This is **Level 1** in the terms of [validation](validation.md). The wrapper defines a third
outcome, `2` — *valid TOSCA that the processor cannot act on* — which no test asserts yet.

| Chapter | Subject | Accept | Reject |
|---|---|---:|---:|
| 5 | Grammar overview | 13 | 4 |
| 6 | TOSCA file definition | 75 | 66 |
| 7 | Nodes and relationships | 10 | 7 |
| 8 | Capabilities and requirements | 29 | 6 |
| 9 | Properties, attributes and parameters | 57 | 59 |
| 10 | Functions | 15 | 1 |
| 11 | Interfaces, operations and notifications | 6 | 2 |
| 12 | Artifacts | 5 | 5 |
| 13 | Workflows | 3 | 5 |
| 14 | Multiple representations from templates | 21 | 0 |
| 15 | Substitution | 25 | 0 |
| 16 | Groups and policies | 5 | 0 |
| 17 | CSAR format | 1 | 0 |

(One further case sits under §1.2.1.1, code snippets.)

## The clause statements

Each numbered statement in Chapter 18 gets an identifier, `C<clause>.<statement>`, so that
tests, reports and claims can refer to it. The *level* column is the lowest level from
[validation](validation.md) at which a test can show the statement is met.

| ID | Statement (TOSCA 2.0 §18) | Sections cited | Level |
|---|---|---|---|
| C1.1 | A TOSCA file is valid against the TOSCA file definition | §6 | 1 |
| C1.2 | Function uses are valid against the function grammar | §10 | 1 |
| C1.3 | Entity definitions using a type are valid against that type's definition | §7.1, §7.3, §8.1, §9.2, §11.1, §12.1, §16.1, §16.3 | 1 |
| C2.1 | Parses any conforming TOSCA file; reports errors for a non-conforming one | Clause 1 | 1 |
| C2.2 | Implements the requirements and semantics of Sections 5 to 16, including the *additional requirements* paragraphs | §5 – §16 | 1 for grammar, 2 for semantics |
| C2.3 | Resolves imports | §6.8 | 1 |
| C2.4 | Reports the errors required for namespaces, built-in types and the type definitions | §6.8.4, §9.1, and the C1.3 sections | 1 |
| C3.1 | Processes TOSCA archives | §17 | 1, and 2 for the archive's content |
| C3.2 | Conforms as a TOSCA processor | Clause 2 | as Clause 2 |
| C3.3 | Evaluates functions according to their rules and semantics | §10 | 2 |
| C3.4 | Fulfils dangling requirements, including those created for mandatory requirements, applying node filters to select targets | §8.5, §8.6 | 2 |
| C3.5 | Generates substituting services for substitutable nodes, applying substitution filters to select the template | §15, §15.1 | 2 |
| C3.6 | Processes implementation artifacts according to their artifact type | §11.5, §12.1 | 3 |
| C4.1 | A generated TOSCA file conforms to Clause 1 | Clause 1 | 1, applied to generator output |
| C4.2 | A generated TOSCA archive conforms to Clause 5 | Clause 5 | 1, applied to generator output |
| C5.1 | A TOSCA archive is valid against the CSAR format | §17 | 1 |

Clause 4 is met by satisfying **at least one** of its statements; every other clause requires all
of them.

## Coverage by statement

Counts are accept + reject cases in the directories each statement cites.

| ID | Coverage today | Sections with no test |
|---|---|---|
| C1.1 | 75 + 66 across §6 | §6.8.2.1 importing profiles, §6.8.2.2 importing a TOSCA file |
| C1.2 | 15 + 1 across §10: function syntax (4), graph query functions (8), `available_allocation`, `concat`, `join`, `token` (1 each) | 48 of the 54 sections in §10, including every boolean, comparison, set and arithmetic function, `get_input`, `get_property`, `get_attribute`, `get_artifact`, `value`, `node_index`, `relationship_index`, `length`, and §10.3 TOSCA path |
| C1.3 | Node type 2 + 7, relationship type 2 + 0, capability type 2 + 3, data type 9 + 5, interface type 3 + 2, artifact type 4 + 5, group type 1 + 0, policy type 2 + 0 | — (every cited section has a case; relationship, group and policy types have no reject case) |
| C2.1 | The whole Level 1 suite | as C1.1 – C1.3 |
| C2.2 | Grammar of §5 – §16 at Level 1; no semantic assertions | §8.4.1 requirement refinement, §8.5.1 requirement keynames, §9.7 attribute assignment, §9.8 and §9.10 parameter assignment and mapping, §11.2 – §11.3 and §11.5 – §11.8 (interface definition and assignment, operation assignment, notifications, implementations), §13.1 and most of §13.2 (workflows), §15.2 – §15.4 and §15.6 (property, attribute, capability and interface mapping), §16.5 triggers |
| C2.3 | 3 + 4 in §6.8.1 | §6.8.2.1, §6.8.2.2 |
| C2.4 | Namespaces 10 + 1; built-in types 29 + 41 across §9.1 subsections; type definitions as C1.3 | collection types (§9.1.3) have no reject case |
| C3.1 | 1 + 0 (§17.3, CSAR without a TOSCA.meta file) | §17.1 overall structure, §17.1.1 archiving formats (tarballs, ZIP), §17.2 TOSCA.meta and its keynames |
| C3.2 | as Clause 2 | as Clause 2 |
| C3.3 | none — function values are not observed | all of §10 at Level 2 |
| C3.4 | none — 3 + 0 node filter cases check grammar only | target selection, mandatory requirements, node filters at Level 2 |
| C3.5 | none — 25 + 0 substitution cases check grammar only | template selection, substitution filters, mappings at Level 2 |
| C3.6 | none | artifact processing at Level 3 |
| C4.1, C4.2 | not addressed by the suite | — |
| C5.1 | 1 + 0 | as C3.1 |

Read together: Clause 1 and the parsing statements of Clause 2 have a working base; the semantic
statement of Clause 2 has none; Clause 3 beyond its Clause 2 prerequisite has none; Clause 5 has
one case. A self-certification run today supports a claim of the form "passes the suite's Level 1
cases for Clause 2", not "conforms to Clause 2" or "conforms to Clause 3".

## Proposal

### 1. Record the mapping in the clause directories

Each `conformance-clause-*` directory (all five exist under `tosca_2_0/`) gets a `statements.yaml`
listing the clause's statements, and for each one the test directories that provide its evidence
and the level those tests reach:

```yaml
clause: 3
title: TOSCA Orchestrator
statements:
  C3.4:
    text: Fulfils dangling requirements and applies node filters
    tests:
      - path: node-filter-definition
        level: 1
      - path: requirement-assignment-grammar
        level: 1
```

This follows the existing convention in [framework](framework.md), where a directory may hold a
file pointing at tests that live elsewhere. The mapping sits beside the clause it describes, and
test cases stay where they are.

### 2. Select tests by clause and statement

A `conftest.py` at `tests/` reads the `statements.yaml` files and marks every collected test with
the clauses and statements it serves, so that:

```sh
pytest -m clause2 tests/tosca_2_0
pytest -m "C3_4" tests/tosca_2_0
```

run exactly the evidence for a clause or a statement. Test files are not edited; the markers
(`clause1` … `clause5`, `level1` … `level3`) are registered in `pyproject.toml` alongside the
existing ones. A test serving two statements carries both markers.

### 3. Report by statement

A small script turns a pytest run into a per-statement table: tests run, passed, failed, and the
highest level exercised. That table, with the processor name and version and the suite commit, is
the self-certification record an implementer publishes. A statement with no tests is reported as
*not covered*, never as passed.

### 4. Extend the wrapper for Level 2

[framework](framework.md) already anticipates the wrapper returning a service's outputs. Level 2
tests follow from that: a test template declares outputs that expose the result under test, and
the pytest asserts on the `outputs` object in the wrapper's JSON response rather than on the
return code alone. For the Clause 3 statements:

- **C3.3** — an output holds a function's value, asserted against the value the specification
  defines.
- **C3.4** — an output reads, through a TOSCA path over the fulfilled requirement's relationship, a
  property of the target node, asserted against the one node the node filter admits.
- **C3.5** — an output of the substituted node, mapped from the substituting template, identifies
  which template was selected.

The same mechanism gives C2.2 semantic tests: the representation counts of §14 and the mapping
results of §15 become observable outputs.

### 5. Settle what Level 3 needs before writing it

C3.6 cannot be shown without executing an artifact, which needs an artifact type the orchestrator
processes and a place to run it. The specification defines no artifact types, so a portable
Level 3 case depends on a profile that does. This is listed as an open question below rather than
proposed.

### 6. Fill the gaps in priority order

1. C3.1 / C5.1 archive cases, which are Level 1 and need only the on-the-fly CSAR construction
   already used by `operation-definition/s118_test.py`.
2. Reject cases for §10 function grammar (C1.2), where 1 of 16 cases is a reject.
3. The empty Clause 2 sections listed above (§6.8.2, §11, §13, §15 mappings, §16.5).
4. Level 2 cases for C3.3, C3.4 and C3.5, once the wrapper returns outputs.

## Open questions

1. **Granularity of a claim.** Is self-certification stated per clause only, or may an
   implementer claim individual statements (for example, Clause 2 plus C3.1 and C3.4)? Other
   standards citing TOSCA would then be able to require a subset of Clause 3.
2. **Clauses 1 and 4.** The suite tests processors. A claim that a particular file or a
   generator's output conforms has to be checked by some processor; is "validated by a processor
   whose Clause 2 record shows full coverage" an acceptable method, and who judges full coverage?
3. **Level 3 dependencies.** May a Level 3 case import a community profile for its artifact
   types, or must the suite carry its own minimal types so that it stays independent of any
   profile?
4. **Maintenance.** When errata or a later TOSCA version renumber sections or restate a clause,
   the `statements.yaml` files change with them. Should the suite version its clause mappings
   alongside the specification version directory (`tosca_2_0/`)?
5. **Publication.** Where are self-certification records kept, if anywhere under the Committee's
   control, and does the Committee review them?
