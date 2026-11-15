# Lossless stage verdicts

This optional AICI action validates a selected stage graph and preserves every
observed attempt while computing an aggregate verdict. It does not supervise
processes, replace an owner's receipt schema, or diagnose a cause from an exit
status.

The plan header is:

```text
stage_id<TAB>actor<TAB>required<TAB>selected<TAB>depends_on<TAB>claim
```

Stages appear in dependency order. `required` and `selected` are exactly `yes`
or `no`; a missing selection is invalid input. `depends_on` names an earlier
stage or is `-`.

The observation header is:

```text
attempt<TAB>stage_id<TAB>actor<TAB>observation<TAB>evidence_validity<TAB>exit<TAB>signal<TAB>command<TAB>source_identity<TAB>producer_digest<TAB>log_digest<TAB>native_code<TAB>detail
```

Observations are `PASS`, `FAIL`, `NOT_RUN`, `SKIPPED`, `INTERRUPTED`, or
`TIMEOUT`. Evidence validity is `VALID`, `INCOMPLETE`, `MALFORMED`, `STALE`,
`WRONG_TARGET`, `WRONG_LAYER`, or `UNTRUSTED_PRODUCER`. The adapter always emits
`diagnosis=UNKNOWN`; a nonzero exit or signal is an observation, not a causal
explanation.

Every row is retained in stage and attempt order. A later successful attempt
does not erase an earlier required failure. An absent selected-stage receipt is
rendered separately as `NOT_RUN / INCOMPLETE / absent_receipt`, rather than as a
demonstrated task failure. Invalid evidence yields `HOLD_FOR_EVIDENCE`; a valid
required failure yields `REJECT_SCOPE`. Optional and unselected stages retain
their own verdict rows without condemning complete required scope.

`exit`, `signal`, `command`, `source_identity`, and the digests use `-` only
when the owner schema did not record that field. A declared valid failure with
an explicit zero exit and no signal is normalized to `MALFORMED`; no diagnosis
is invented. Digests are either 64 hexadecimal SHA-256 characters or `-`.

## Native mappings

The existing `aici-ingestion-receipt-v1` mapping is implemented by the
`ingestion` command and exercised by the published ingestion action. Its seven
native stage rows, owner, code, evidence, implementation revision, producer and
executable digest are retained. The owner schema has no process exit, signal,
command or log digest fields, so those fields remain `-`.

[`contracts/native-mappings-v1.tsv`](contracts/native-mappings-v1.tsv) freezes
the implemented field mapping and records unavailable owner schemas without
inventing compatible-looking fields.

Kitchen K05 and Flexible Pipes still own their process and immutable-attempt
schemas. Their mappings are `PENDING_OWNER_SCHEMA`; this adapter does not guess
field meanings before those schemas are released. A02 and A04 consumers can use
the normalized rows without treating either comparator as automatic authority.

The fixture corpus covers a correct run, exact output followed by exit seven,
plausible compiler output followed by failure, omitted selected work, timeout,
interruption, upload-only failure, an unrelated actor crash, optional cleanup,
retry history, every invalid-evidence class, missing selection, and a
contradictory zero-exit failure. Expected verdict files are written independently
and compared byte-for-byte by `self-test`.

This host process evidence does not establish Android or physical-device
behavior.
