# Complex/projective backend evidence

This action verifies revision-bound receipts for the shared Idric complex and
projective arithmetic corpus. The [leadership policy](../docs/complex-projective-backend-policy.md)
is normative: x86-64 leads this subsystem, while Thumb-2 and GPU/shader
implementations follow the same mathematics.

The verifier validates evidence structure and witness bytes. It does not run a
backend, judge numerical output by itself, or manufacture missing receipts.
The receipt producer remains responsible for executing the named test against
the pinned revisions and writing a truthful status.

## Contract format

Contracts are UTF-8 TSV. Blank lines and `#` comments are ignored. Diagnostic
codes are unique uppercase ASCII letters, digits, and hyphens.

Version 2 is intentionally fail-closed against version 1 contracts and
receipts: the earlier format could not distinguish semantic authority from the
frontend that actually ran.

```text
schema<TAB>complex-projective-backend-contract-v2
identity<TAB>CODE<TAB>target<TAB>x86-64-cpu|arm-thumb2|gpu<TAB>leader|follower
corpus<TAB>CODE<TAB>owner/repository<TAB>ref<TAB>full-revision<TAB>relative-path<TAB>sha256
provenance<TAB>CODE<TAB>semantic-repository<TAB>semantic-ref<TAB>semantic-revision<TAB>backend-repository<TAB>backend-ref<TAB>backend-revision<TAB>application-repository|-<TAB>application-ref|-<TAB>application-revision|-
frontend<TAB>CODE<TAB>frontend-repository<TAB>frontend-ref<TAB>frontend-revision
require<TAB>CODE<TAB>exact|numeric|projective|render|pipeline<TAB>stage<TAB>environment<TAB>pass|skip|blocked
gpu_ceiling<TAB>CODE<TAB>strongest-demonstrated-stage
```

The corpus must live at the semantic repository/ref/revision named by
`provenance`. That triple identifies the canonical Idric definitions and
corpus whose contract the target follows. It does **not** claim that an
executable from that repository compiled the tested artifact. The separate
`frontend` triple identifies the compiler or frontend that actually produced
the backend input. This distinction lets a provisional follower report an
upstream Idris2 frontend honestly without promoting it to mathematical
authority.

Every contract has at least one explicit requirement in each of the `exact`,
`numeric`, `projective`, and `render` categories.

An `x86-64-cpu` identity must be `leader`, must name an application, and must
name the canonical semantic repository/ref/revision as its actual frontend.
Thus a leader receipt cannot claim canonical Idric frontend integration while
running only a separately versioned compiler. It must also
require `pass` for these exact category/stage pairs:

| Category | Stage |
| --- | --- |
| `exact` | `exact-corpus` |
| `numeric` | `numerical-corpus` |
| `projective` | `projective-equivalence-corpus` |
| `render` | `headless-render` |
| `pipeline` | `direct-build` |
| `pipeline` | `native-execution` |
| `pipeline` | `thin-debian-execution` |
| `pipeline` | `github-actions-execution` |

`arm-thumb2` and `gpu` identities must be `follower`. A GPU contract must also
have exactly one `gpu_ceiling`. The ordered stages are:

1. `shader-generated`
2. `shader-inspected`
3. `shader-compiled`
4. `shader-linked`
5. `shader-loaded`
6. `shader-executed`
7. `render-captured`
8. `vendor-device-receipt`

The receipt contains one `pipeline` row for every GPU stage. All rows through
the ceiling are `pass`; all later rows are `skip` or `blocked`. This prevents a
generated or compiling shader from being reported as loaded, executed, or
captured on hardware.

`contracts/x86-leader-v2.template.tsv` spells out the mandatory leader rows.
It contains zero-valued placeholders and is intentionally not a runnable
receipt contract until every repository, ref, revision, corpus digest, target,
and environment is replaced by the receipt-producing workflow.

## Receipt format

The first non-comment line is this exact header:

```text
target<TAB>family<TAB>role<TAB>category<TAB>stage<TAB>status<TAB>corpus_repository<TAB>corpus_ref<TAB>corpus_revision<TAB>corpus_path<TAB>corpus_sha256<TAB>semantic_repository<TAB>semantic_ref<TAB>semantic_revision<TAB>frontend_repository<TAB>frontend_ref<TAB>frontend_revision<TAB>backend_repository<TAB>backend_ref<TAB>backend_revision<TAB>application_repository<TAB>application_ref<TAB>application_revision<TAB>environment<TAB>witness<TAB>sha256
```

Every contracted requirement has exactly one matching row by category, stage,
and environment. GPU pipeline stages each have exactly one row. Duplicate and
undeclared rows fail. `status` is `pass`, `skip`, `blocked`, or `fail`; a row
only satisfies the status explicitly required by the contract, and `fail`
never satisfies a requirement. Every row must name a nonempty regular witness
below `root`, with the SHA-256 of its current bytes.

Full revisions are 40- or 64-character lowercase hexadecimal object IDs. Refs
are retained as provenance rather than inferred from a revision. Before
invocation, the trusted workflow must compare the contract's repository refs
and revisions to the current checked-out semantic authority, actual frontend,
backend, and application inputs. Build tools below the named frontend (for
example `glslangValidator`, Mesa, or a linker) belong in the witness; they do
not replace the frontend revision. That event binding prevents an internally
consistent old receipt from another branch being replayed as current success.

## Run

```text
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 \
  -o /tmp/aici-complex-projective src/aici_complex_projective.c
/tmp/aici-complex-projective verify \
  ci/complex-projective.contract.tsv \
  out/complex-projective/receipt.tsv \
  _compiler/_/examples/complex-projective/corpus-v1.json \
  out/complex-projective
```

Or pin the reviewed action revision:

```yaml
- uses: isomorphisms/ai-ci/complex-projective@0123456789abcdef0123456789abcdef01234567
  with:
    contract: ci/complex-projective.contract.tsv
    receipt: out/complex-projective/receipt.tsv
    corpus: _compiler/_/examples/complex-projective/corpus-v1.json
    root: out/complex-projective
```

Do not copy the placeholder action SHA. The `contract` must be trusted policy,
not pull-request-controlled input in a secret-bearing workflow.

## What a green verification means

A green result means the declared receipt is closed, internally consistent,
revision-bound, and backed by the current witness bytes. It does not elevate a
`skip` or `blocked` follower row to success, interpret a rendering log, or prove
that a receipt producer told the truth. The x86 leader profile is deliberately
non-downgradable; no complete x86 leader contract can pass while its required
direct, numerical, projective, headless, thin-Debian, or GitHub Actions receipt
is missing.
