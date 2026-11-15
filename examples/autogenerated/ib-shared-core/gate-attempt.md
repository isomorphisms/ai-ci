# Shared parity admission gate

The type sketch is a wrapper over the existing AICI follower verifier: exactly
three required consumer targets, exact IB source, declared acceptance kinds and
accepted matching receipts. It does not invent a ledger or attest hardware.

Positive fixtures below are explicitly synthetic admission data, not physical
receipts. Known-bad controls remove a required receipt, retain an explicit
blocked state despite a synthetic matching receipt, and omit a required target.
All must fail before emitting shared-core-parity=PASS.

The first executed wrapper exposed a native Grease mistake: command-condition
`not` was treated as an unknown program. Its positive fixture emitted diagnostics
and returned success. The failed source is preserved as parity-1.grease; the
corrected wrapper uses one positive grep command and an explicit else refusal.
The pending-table count remains an additional independent guard.

The verifier was actually compiled with the pinned, qualified Linux ICK scalar
profile. This checks admission behavior, not Android target execution. The real
ledger must remain blocked until its exact physical followers are accepted.
