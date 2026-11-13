# Defect specimen registration

`src/aici_defect_registration.c` verifies the version-one registration used by
the retained Holomorphic generated-test proxy incident. It is deliberately a
small native verifier over ordinary TSV files, not a second issue tracker.

The registration separates five objects that must not be collapsed:

1. the original source and test specimen, including exact revisions and byte
   digests;
2. the independently owned oracle and the human confirmation reference;
3. a bounded, paginated inventory of source tests, templates, wrappers, and
   promotion callers;
4. evidence-backed dispositions (`confirmed`, `benign`, `unknown`, or
   `inaccessible`);
5. owner-bound obligations emitted only for confirmed findings or specific
   unknown evidence boundaries.

The verifier requires all eleven owner seeds retained by SUN T1 and separately
records the unavailable original generator trace. This establishes completeness
only for that declared boundary. It does not establish account-wide test health,
a common generator cause, GPU correctness, RGB correctness, sampling intent, or
physical-device acceptance.

## Determinism and rejection cases

The canonical obligation identifier is `a05-` followed by the candidate ID.
Candidates and obligations are unique, obligations are sorted, and the verifier
renders both the maintained obligation record and the consumer release
byte-for-byte. Re-registering identical specimen evidence is idempotent. A
second row with the same specimen ID and different evidence is rejected.

The built-in self-test starts with the actual maintained registration and then
rejects a conflicting duplicate, an omitted known consumer, a missing search
page, a copied oracle, a stale source revision, an unjustified benign
disposition, duplicate or missing obligations, promotion of the smoke to a
mathematical claim, and relabeling inaccessible evidence as benign. It also
renders identical evidence twice and compares the resulting bytes.

## Consumer boundary

`incidents/2026-10-holomorphic-generated-test-proxy/release/obligations.tsv` is
the exact released input for BC-A05-S02, BC-A05-S03, and BC-S01-S01. The
consumer ledger records availability only. It does not claim those jobs have
executed or that Cockswain has retired their obligations.

The required workflow compiles the verifier through the qualified ICK C
compiler, verifies the maintained records, and executes all negative cases.
