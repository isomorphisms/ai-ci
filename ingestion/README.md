# Hostile-ingestion receipts

This optional AICI action owns the canonical hostile-web corpus and validates
the shared seven-stage receipt. It does not implement the candidate path.

The first implementation under test is ICU compiled through Idriç. Its current
receipt identifies the native C/OpenSSL transport boundary explicitly. The
side-by-side oracle uses curl for retrieval, gzip for compressed bytes, iconv
for UTF-8 validation, and libxml2 for recoverable HTML. Oracle output is written
to a separate receipt and is never supplied as candidate input.

Implementation-under-test acceptance requires a frozen invocation bundle from
outside the candidate's write authority. The caller supplies the approved
selection digest, current attempt, and trusted observer's observation digest
through its own control path. The verifier matches the exact corpus, selector,
executable bytes, selected cases, start and completion, raw exit, and captured
stdout and stderr. The captured stdout carries the seven-stage receipt. Wrong
material, missing or duplicate cases, changed output and stale attempts fail
before a comparison is made.

`audit-receipt` retains the old shape checks and optional trace naming policy.
Its result is explicitly `receipt-structure-only`. The old candidate
`verify` and `compare` invocations refuse acceptance with
`invocation_required`. The receipt still requires `fallback=none`, preserves
the first failed or unimplemented boundary, and checks the first-failure and
first-incomplete summaries. Executable admission uses bytes and selected
identities. A harmless file rename preserves that identity.

After owner-schema validation, the action maps the same receipt through the
[lossless stage-verdict adapter](../stage-verdict/README.md). The mapping keeps
all seven native rows and fails the action when required scope is failed or
incomplete; a structurally valid failure receipt no longer makes the wrapper
green. Native fields absent from this receipt version remain explicitly absent.

Consumers must pin `isomorphisms/ai-ci` by a full commit SHA and record that SHA
as `corpus_repository_revision`; `corpus_revision` comes from
`corpus-v1/REVISION`.

Example:

```yaml
- uses: isomorphisms/ai-ci/ingestion@<full commit SHA>
  with:
    role: implementation-under-test
    execution_bundle: ${{ steps.observer.outputs.bundle }}
    selection_sha256: ${{ steps.policy.outputs.selection_sha256 }}
    observations_sha256: ${{ steps.observer.outputs.observations_sha256 }}
    attempt: ${{ steps.request.outputs.attempt }}
    fixture: valid_utf8
    compare_observed_oracle: 'true'
```

Use `receipt:` with an oracle or consumer role for a standalone receipt audit
and stage verdict. With the implementation-under-test role the action reads
the selected candidate stdout from the verified bundle.

### Invocation bundle v1

All records use tabs and a terminating newline. The selection starts with
these five rows in order, followed by one `case` row per fixture. The fixture
ID is the case ID for this adapter.

```text
schema  aici-ingestion-selection-v1
observer  host-fixture-v1  OBSERVER_SHA256
corpus  SOURCE_COMMIT  CORPUS_MANIFEST_SHA256  FIXTURES_TSV_SHA256
candidate  SOURCE_COMMIT  EXECUTABLE_SHA256
oracle  SOURCE_IDENTITY  EXECUTABLE_SHA256  PROVENANCE_SHA256
case  FIXTURE_ID
```

`observations.tsv` begins with four rows, followed by one `invoke` row for
each selected fixture and role. The two lists may appear in any order.

```text
schema  aici-ingestion-invocation-v1
attempt  CURRENT_32_HEX_ID
policy  APPROVED_SELECTION_SHA256
observer  host-fixture-v1  OBSERVER_SHA256
invoke  ROLE  FIXTURE_ID  EXECUTABLE_SHA256  START_NS  END_NS  EXIT  STDOUT_SHA256  STDERR_SHA256
```

Keep `policy.tsv`, `oracle-provenance.tsv`, `candidate.program`,
`oracle.program` and the unedited `FIXTURE.ROLE.stdout` and
`FIXTURE.ROLE.stderr` files alongside the observations. Roles are
`candidate` and `oracle`. Start and completion are observer-local monotonic
nanoseconds. Exit is the launcher-reported status. Observation and material
files must be frozen through verification and subsequent stage verdict use.

The checked-in qualification uses the pinned Ithon frontend, a host sandbox
and an observer-owned status channel. It mounts only the selected fixture
transport, its own inputs and a read-only marker. The observer captures pipe
output outside the sandbox, validates the launcher start and terminal status,
and binds both transports to independent candidate/reference input files.
This proves the host adapter for the two selected fixture IDs and their
identity controls. The separate ten-case curl/libxml2 loop still exercises
the actual corpus oracle.

The accepted profile is `host-fixture-v1`. Admission relies on the identity
and authority of the caller and observer supplying the pins. The plan's
provenance file is itself hash-bound, and the two executables must differ.
Production evidence additionally needs the approved BC-A03 authority,
BC-P02 material closure and the Flexible Pipes observer.

The current document boundary is deliberately named
`document_log_subset_v0`. It is not a claim of browser DOM compatibility.
