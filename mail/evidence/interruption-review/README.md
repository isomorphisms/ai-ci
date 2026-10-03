# Partial-read failure review

This continuation builds on `39729206d014560185e346eae373135a1e1db3d3`.
The executable source hashes below identify the changed working tree tested;
the parent commit alone does not identify these changes. Historical receipts
one directory above remain unchanged and do not prove the new behavior.

The earlier read-error mutation ran only after the complete fixture. The new
controller sends every prefix of each compact RFC, MIME and mbox fixture, then
IO failure. It checks received bytes, positions, digest and failure terminal
against the independently constructed input prefix. No parsing semantics are
inferred for an incomplete message. The unread suffix never reaches the
adapter through its input protocol.

Host: Linux 6.18.44 x86_64. C17, `-Wall -Wextra -Werror -pedantic -O2`, linked
with libcrypto, using the repository Makefile.

## Results

- `make test`: PASS, including byte-identical regeneration of 75 cases, nine
  metamorphic checks and the existing/new mutation controls.
- `interruptions.tsv.gz`: 7,910 prefix-only checks, zero failures. Every byte
  cut is covered below 4096 bytes; larger fixtures use five selected positions.
- `mutations.tsv`: 26 targeted bad-mode invocations plus the public-fixture-only
  holdout are rejected; eight ordinary positive controls, the interruption sweep
  and the generated-holdout control pass.
- New negative controls reject failure-as-EOF at zero and intermediate length,
  fabricated unread suffix, discarded received prefix, and a 32-bit prefix span
  crossing 2³². The two raw-corruption mutants recompute internally consistent
  source receipts, so rejection depends on comparison with independent bytes.
- The unavailable-language differential registry still exits 2 with NOT_RUN.
- A replay-only differential check over four generated fixtures passed 32
  complete-stream runs and 777 interruption runs, exercising matrix integration.
  Its registry source field names the parent solely for the controller test;
  the executable hashes above, not that field, identify the changed replay
  binary. This is not source-to-build provenance for a translation.

These are host harness/replay results. No actual parser, Gmail write, SSH
session, process-death ledger recovery, or physical SDF acceptance is claimed.
The new prefix comparator does not establish partial-message semantic recovery;
Q1/Q2 still block those expectations.

## Refreshed provenance boundary

The current ICU branches still identify the mailbox design at
`d7363a58766e17f4677fae8d2e936e9121aa40c9` and the missing-source investigation at
`86b4b2882e0da6e9bf72abd31ada4ae5b859f46b`. The latter explicitly reports that no
retained original parser was found. The Gmail surface at
`dcf24dad158b9100048aff9c4331eef8540a218c` still begins with a statement that it
sketches a client before implementation. The issh master branch remains
`67da05b1af80be9039485a9102da5ee9049d6db8`. None of these refreshed reads resolves
the missing source corpus or authorizes selecting a replacement mail library.

## Source and executable SHA-256

| Object | SHA-256 |
| --- | --- |
| mail/accept.c | 2dd0806979a9614a232dc30803c7be6dd9f47755c965cfc48f53cf5aaf512cde |
| mail/replay_mutant.c | 04fbd314b86f2209cd706a8ddbf387c5878ad572a79490af2661cdd28e1676cb |
| mail/support.h | b0315dbdb02ec5a15c9a7c1ebebc22e0b8c0ba38e467c059f47c1e7b269ae44b |
| mail/make_corpus.c | 237eb48a2fa598f431702ff3e6dca610a163c8b29e5df48ec44f99a6a0b0762d |
| accept executable | f902c1f1f28754ed993e91ecaa7125ad509af56835bf656f10e3e3bdcf3de3c7 |
| replay executable | ed631a970b8efe7986c438a87744a1d7bfa34257dc6e13ad667484b0e2e7473b |
