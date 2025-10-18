---
applyTo: '*.yaml'
---
# Instructions to github copilot for TOSCA files

Conform to YAML, Version 1.2 3rd Edition, Patched at 2009-10-01

Conform to TOSCA 2.0 unless otherwise specified

TOSCA 2.0 is defined in the OASIS Standard "Topology and Orchestration Specification for Cloud Applications (TOSCA) Version 2.0", OASIS Standard, 15 November 2023, available at https://docs.oasis-open.org/tosca/TOSCA/v2.0/os/TOSCA-v2.0-os.html

Use snake case for TOSCA keynames

Use dash case for TOSCA value names

Use camel case for TOSCA entity type names. All words in the name should be capitalized, including prepositions

# Do not use the construct 'type: tosca.*' as this is not valid TOSCA 2.0
Do not use the construct 'derived from tosca.*' Do not include any comment about not using this construct.
Do not use values starting with 'tosca.*' for any TOSCA entity type name as this is not valid TOSCA 2.0

Do not use template_type section  as this is not valid in TOSCA 2.0 instead use service_template.
