# Acceptance harness language attempt

This is acceptance infrastructure, not a mail implementation or an Idriç mail
sketch. No translated parser supplies expected results.

The domains are immutable byte sources, nonnegative byte positions, partitions,
source spans, observations, and evidence states. A partition is a list of positive
byte counts whose sum is the input size. A source span has start ≤ end and uses
an exclusive end. Comparisons distinguish bytes, structure, decoded payload, and
external effects. Unknown evidence cannot inhabit the passing-result domain.

The smallest slice is `empty_source_size : Number`. The full intended operations
are partitioning a byte count, hashing byte streams, supervising processes with
bounded resources, and comparing externally produced observations. Reading,
writing, process supervision, and durable receipts are effects; partitioning and
comparison are mathematical functions. Needed host facilities include binary
files, SHA-256, pipes, process groups, timeouts, and 64-bit positions.

Compiler source inspected: isomorphisms/Idric
51e3892d4de59943e42e65c60a9814aba792c5d4; STYLE.md and the canonical intent examples
were read. The recorded invocation is `edric --emit-one-step` on the adjacent
source. The invocation returned exit 2: `Idriç one-step emitter: compiler is not
bootstrapped; run ./_/edric bootstrap`. No Idriç execution is claimed.

The external acceptance result still matters. The fallback uses AICI's existing
C17 verifier convention, rather than introducing maintained Python source.
The maintained sources live in `mail/` as requested; this attempt record and
the unavailable Idriç slice remain here rather than duplicating the C sources.
The C infrastructure must be verified separately. Its semantics come from the
user's contract, original-source review, and specifications, never this attempt.

First blocker: the compiler executable required by the documented entrypoint is
absent on this disposable host. Next step is provisioning the existing bootstrap,
not inventing a syntax or language defect. Acceptance: emit and check this small
Number expression, then investigate binary I/O and process supervision separately.
