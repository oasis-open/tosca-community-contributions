# Scalar Units Profile

[TOSCA Simple Profile in YAML
v1.3](https://docs.oasis-open.org/tosca/TOSCA-Simple-Profile-YAML/v1.3/TOSCA-Simple-Profile-YAML-v1.3.html)
defines several *scalar-unit* types that can be used to define scalar
values along with a unit from the list of recognized units defined for
each of these types. TOSCA Version 2.0 removes these scalar-unit types
and instead replaces them with an abstract
[`scalar`](https://docs.oasis-open.org/tosca/TOSCA/v2.0/TOSCA-v2.0.html#scalar)
data type from which concrete types can be derived that represent a
wide variety of scalar unit values. This profile defines such concrete
scalar unit data types.

> As a starting point, we redefine the v1.3 scalar units using the
  v2.0 grammar.
