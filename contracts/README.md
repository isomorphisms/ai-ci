# Contract format v0

Contracts are UTF-8, tab-separated files. Blank lines and lines beginning with
`#` are ignored. Every assertion has this prefix:

```text
operation<TAB>DIAGNOSTIC-CODE<TAB>arguments...
```

Diagnostic codes contain only uppercase ASCII letters, digits, and `-`.
Paths are relative to the supplied root; literal `..` segments are rejected.
Some predicates expose a boolean content oracle. This lexical check is not a
security sandbox (see the repository trust boundary).

## Predicates

```text
nonempty       CODE  path
equal          CODE  left-path  right-path
not_contains   CODE  path       literal
tsv            CODE  path       minimum-fields  minimum-rows
tsv_header     CODE  path       comma-separated-column-names
yaml_paths     CODE  list-path  workflow-path event-name
no_suffix      CODE  root-path  comma-separated-suffixes
suffix_first_line CODE root-path suffix exact-first-line
actions_pinned CODE  workflow-path
yaml_forbid_key CODE workflow-path key
script_runner  CODE  workflow-path script-path exact-runner
```

`yaml_paths` requires every non-comment line in the list to appear as an exact
list item beneath the named event's `paths:` filter. Negative path patterns are
rejected. Mentions in comments, other events, action inputs, or shell commands
do not count. `actions_pinned` requires canonical block-style `uses:` keys, at
least one remote action, and requires every remote
`uses:` reference to end in exactly 40 hexadecimal characters. Local `./`
actions are allowed; Docker actions are rejected in v0. `script_runner`
requires one exact, single-line `run:` scalar. It fails if a named script is
absent, merely echoed, hidden in a multiline shell block, or invoked through
any command other than the declared runner. It proves declared invocation, not
successful runtime behavior. A predicate does not pass when its input is
missing. Recursive predicates reject
matching symlinks, and do not pass when they scan zero matching regular files.

## Suite format

A suite has one contract per line:

```text
path/to/contract.tsv<TAB>root-relative-to-suite-invocation
```

Every selected contract must run. An empty suite fails. Any failed contract
fails the suite; results are never averaged.

## Self-test format

```text
pass<TAB>contract<TAB>fixture-root<TAB>-
fail<TAB>contract<TAB>fixture-root<TAB>EXPECTED-DIAGNOSTIC
```

For a negative fixture, merely returning a nonzero status is insufficient. The
first diagnostic must be the one declared by the case. This prevents a broken
fixture from “passing” because the checker crashed for an unrelated reason.
For every contract beneath `contracts/`, self-test also requires at least one
positive fixture, unique assertion diagnostics, and a targeted failing fixture
for every diagnostic.
