# Supported workflow source

BC-A07-S01 replaces the independent line scanners with one bounded structural
reader in `src/workflow_source.h`, retained inside the existing C verifier.
Checkout, action pins, forbidden keys, event paths, run-scalar exclusions and
the script-runner source check all consume its mapping/sequence nodes. Text
inside block scalars cannot create workflow keys or checkouts.

`aici workflow-head WORKFLOW [...]` checks the same primary-checkout predicate
as `yaml_primary_checkout_ref`. The existing POSIX compatibility entrypoint
`merge/check-workflow-head.sh` invokes that command through the executable
`AICI_BIN`; a missing executable fails with status 2. It neither builds a
verifier nor runs a second policy implementation. The maintained merge workflow
builds this exact source with the pinned ICK action and supplies that path.

## Syntax boundary

The reader accepts block mappings, block sequences (including indentationless
sequences and standalone sequence markers), ordinary scalar keys/values,
single-quoted scalars with doubled quotes, and double-quoted scalars with the
supported `n`, `r`, `t`, quote, slash and backslash escapes. It recognizes
comments and literal/folded block-scalar headers with declared chomping and
indentation indicators. Expressions in unrelated ordinary scalar values remain
data. It does not evaluate expressions or shell programs.

Duplicate mapping keys produce `WORKFLOW-SOURCE-DUPLICATE`; action input names
also reject duplicates differing only in ASCII case. Expression-bearing mapping
keys are unsupported because evaluating them can change the source structure.
Flow collections,
anchors, aliases, merge keys, tags, multiple documents, tabs used for indentation
and unsupported quoted escapes produce an explicit unsupported result. Invalid
indentation, structural collisions, malformed jobs/steps and steps combining
`uses` with `run` fail. Limits are 128 container levels, 8,192 nodes, one MiB per
line and 32 MiB per file; oversized or allocation/I/O failures never pass.

The required trigger must declare `pull_request` as a scalar event or a member
of the block `on` mapping. Primary checkout fields must be actual children of
that step's `with` mapping. An absent `repository`, or the exact expression
`${{ github.repository }}`, identifies primary source. A literal `owner/repo`
continues the existing contract's explicit-dependency convention; this is not
proof that a literal names a different repository. Dynamic repository selectors
are unsupported. Required checkout and parent-job conditions accept only absent
conditions or literal `true` / `${{ true }}`. Literal false is disabled; other
conditions require a declared semantic extension and cannot pass by omission.

Checkout action identity and its `ref`/`repository` input names follow GitHub's
ASCII case-insensitive matching. Workflow structural keys remain case-sensitive.
Malformed workflow and composite steps fail in the shared reader before any
predicate can ignore their fields.

The action-pin predicate examines actual step actions, job-level reusable
workflow calls and composite-action steps, including their quoted keys. It
does not inspect action-shaped text in `env` values or run scalars. Event-path
checking retains literal inclusion and negative-pattern refusal; unfiltered
event eligibility remains BC-A07-S04's separate obligation.

## Evidence boundary

A source PASS establishes this supported configuration only. It proves neither
checkout execution nor that a required command ran, propagated failure, or
produced a valid artifact. The existing `WORKFLOW-SWALLOW-*` names remain
compatibility diagnostics for lexical run-scalar exclusions, not behavioral
shell analysis. BC-A07-S02 owns their migration and BC-A04 owns process results.
Reader failures also appear as typed source diagnostics and line numbers in
the core contract's detail field.

`tests/merge-workflow-head.sh` runs the 32 cases in
`tests/workflow-source/cases.tsv` through the direct command, compatibility
adapter and core contract, requiring equivalent verdicts and exact intended
diagnostics. The existing core self-test additionally covers quoted workflow
keys across all predicates, a quoted failing run key, and pinned/unpinned
job-level and composite action twins. The old fixtures remain unchanged.

Review counterexamples retain a good lowercase checkout followed by a mixed-case
checkout with a wrong ref, a valid mixed-case action/input twin, case-colliding
input names, expression-bearing input keys, and malformed workflow/composite
steps that previously passed the standalone action-pin assertion. These cases
exercise the same source boundary rather than claiming checkout execution.

The new owned parser uses Icky C assignment arrows. The composite action,
self-test compiler, merge-check compiler and Ike shadow recipe select the
existing pinned native ICK producer at `903b2cb27ea572c9c6cb2ffa9f39e0fbf06ec9f8`
(ICK source `c61e448251744a2f40ad743ebef1a027bdcd2f9d`). The header is an explicit
Ike dependency and the unfiltered workflows cover source, header, fixtures,
actions and recipes. Generic consumer compiler fallback is not provided.
