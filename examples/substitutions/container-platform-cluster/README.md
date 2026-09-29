# One requirement, many assignments, one node each

*Drafted with an AI assistant (Claude).*

A `ContainerPlatform` spans several servers. Its realization creates one cluster
agent per server, and each agent must receive **one** of the platform's
placements, not all of them.

This is the requirement mapping people get wrong first, and the one the
specification's own grammar is hardest to read on. The two files here are
complete and small:

- [`main.yaml`](main.yaml) — the abstract service, in the System View: three
  `ServerPlatform` nodes and a `ContainerPlatform` whose `host` requirement
  binds all three.
- [`cluster.yaml`](cluster.yaml) — the realization, in the technology column: a
  counted `agent` template, and the mapping that hands each agent a different
  server.

## Which layer each file is in

Substitution is how the [policy continuum](../README.md) crosses from one layer
to the next, so a realization's own nodes belong to the layer below the node it
substitutes. That is worth stating as a rule, because it is easy to break by
accident:

- `main.yaml` uses System View types and nothing else.
- `cluster.yaml` names one System View type, `platform:ContainerPlatform`, as
  the `node_type` of its `substitution_mappings`. Everything else it uses comes
  from the technology column, and no requirement in it names a System View type.

An abstract type is what a realization substitutes, never what it is built from.
A node type derived from a System View type, or a requirement in the realization
pinned to one, puts an abstract type into an implementation and collapses the two
layers into one.

The community has no technology-specific profiles yet, so the realization defines
the node type it needs, `Agent`, in its own file, derived from `Root` in
[`community.tosca.technology.base`](../../../profiles/community/tosca/technology/base/profile.yaml).
That profile is the technology column's base: its own `Standard` interface, its
own `Bash` artifact type, and its own copies of the three base relationship and
capability types, so a technology type never has to reach into the abstract
layer. It is in the repository and is not part of the `0.1` release. Once
technology profiles exist, `Agent` is what one of them would define against a
product, with operations that install and join the thing.

## The mapping

```yaml
requirements:
  - [host, UNBOUNDED]: [agent, $relationship_index, host]
```

Read it right to left. `agent` is a counted node template, so it yields several
representations. `$relationship_index` is the index of the assignment being
mapped: the first `host` assignment on the substituted node carries index 0, the
second 1, and so on. Using it as the index of the target template pairs
assignment *n* with agent *n*, and `host` is the requirement on that agent which
receives it.

Without the index, the same entry means *all* assignments go to one target
requirement. That is sometimes exactly right: the
[`microservice`](../microservice) example maps
`- [interacts-with, UNBOUNDED]: [pod, endpoint]`, because every peer a
microservice talks to is consumed by the one pod. It is wrong for a cluster,
where it would ask every agent to host every server.

What holds one server per agent is the agent's own requirement:

```yaml
- host:
    capability: tech:Container
    relationship: tech:ContainedBy
    count_range: [1, 1]
```

An agent that ended up with several placements, or with none, fails validation
rather than deploying into a topology nobody asked for. The mapping states the
intent; the count is what holds it.

That requirement names no target node type. The machine an agent is placed on is
contributed by the realization of the server the placement came from, which is a
different substitution in a different file, so the type to pin would have to be
one both realizations share, from a technology profile the community does not
have yet. The type that must not be pinned here is the one this file could
name today, `platform:ServerPlatform`: that is the layering rule above, broken.

## Two things the example has to work around

**Nothing counts the assignments.** The realization has to know how many agents
to create, and TOSCA offers no way to ask how many relationships a requirement
produced. Here the number travels across the boundary in the substituted node's
`implementation-details`, the `YAML` property `Base` declares for opaque values,
decoded into a typed input on the other side. A built-in that counts
relationships would remove the need, which is what community issue I49 and
[discussion #372](https://github.com/oasis-open/tosca-community-contributions/discussions/372)
propose.

The unpinned requirement above is the same constraint seen from the other side:
what would make a read across it type-checkable is a pinned target type, and
there is none to pin that does not reach into the layer above. So an agent is
named from `$node_index` rather than from the server it was placed on, and which
agent got which server is read from the relationships, not from a property
copied across the boundary.

**The mapping key cannot be parsed by every YAML library.** `[host, UNBOUNDED]`
is a sequence used as a mapping key. PyYAML refuses it, because it requires
hashable keys; `ruamel.yaml` accepts it. Any tooling that reads these files
needs a parser that allows it.

## What the specification says, and where it does not hold up

§15.5 of `tosca_2_0/TOSCA-v2.0-os.md` says that where several mappings share a
requirement name each assignment is mapped separately, and where only one
mapping carries that name all assignments go to the same target. §15.5.5 adds
the `UNBOUNDED` count. That rule is not implementable as written, and it is
filed as
[oasis-tcs/tosca-specs#362](https://github.com/oasis-tcs/tosca-specs/issues/362):

- **An entry's meaning depends on how many siblings it has.** The specification's
  own examples use the identical form `- service: [<node>, service]` for both
  meanings, s139 consuming two assignments and s150 consuming one. Adding a
  second entry for a name silently reduces the first from "all" to "one" without
  that entry changing, so no entry can be read or validated on its own.
- **The surplus is undefined.** With two entries and five assignments, nothing
  says where assignments three through five go. The gap is widest exactly where
  it matters, a requirement whose upper bound is `UNBOUNDED` and whose number of
  assignments is not known until deployment.

The issue proposes two ways out: a countless entry consumes exactly one
assignment and `UNBOUNDED` is how an author says "all the remaining ones", or the
rule stays and the text has to state both the sibling dependency and what happens
to the surplus. Neighbouring problems in the same section are
[#359](https://github.com/oasis-tcs/tosca-specs/issues/359),
[#360](https://github.com/oasis-tcs/tosca-specs/issues/360) and
[#367](https://github.com/oasis-tcs/tosca-specs/issues/367).

Either way out leaves the form used here, an explicit count in the key and an
index on the target, meaning what it says. That is the practical reason to
prefer it: a template written with the bare form is relying on an
interpretation, and the two readings disagree about what it means.

## Related

- [`microservice`](../microservice) — the other two mapping forms: one abstract
  requirement fanned out to a named requirement on each of several nodes
  (`host`), and the unindexed `UNBOUNDED` form, where all assignments of one
  requirement reach a single target (`interacts-with`).
- [`modeling-methodology.md`](../../../profiles/community/tosca/docs/modeling-methodology.md)
  — substitution, and how a realization is selected.
