# Independent GPU follower numerical acceptance

`verify_numeric.pi` reads the actual shader-backend exact-integer output.
It independently decodes every scalar encoding using foreign `ml_dtypes`
0.5.3 and checks values immediately below, at and above every positive finite
adjacent midpoint, plus 904 finite-operand arithmetic cases. Unknown rows,
duplicates, omissions and mismatches fail.
The producer is not imported. This CPU oracle cannot accept GPU execution.

Run through pinned Ithon, never by passing the `.pi` file directly to Python.
Retain the Ithon check receipt, exact producer and oracle revisions, raw stream
hashes and rejected altered/missing/duplicate records. An empty or truncated
stream must fail. This gate is optional to the primary Android build.

No execution or source provenance follows from a caller's arbitrary TSV alone.
The qualification driver must capture the actual producer's exit and hash its
binary and source. Native vendor assembler and physical readback gates remain
separate. MX metadata, experimental signed E5M3 and NVIDIA UE5M3 scales do not
receive scalar-format acceptance from this corpus.

`verify_ike.pi` hashes the real Ikefile independently, checks the exact selected
target and recipe-runner identity, and compares every ordered rule, recipe and
zero exit status against a caller-trusted plan. It supports Ike's original
single-command POSIX interface and the external Grease source-file interface.
It rejects trailing events and never trusts a final PASS alone.

`self_test.grease` consumes actual producer output and an actual Ike receipt,
reruns both positives, and requires four altered numerical streams and three
altered receipts to fail at the intended diagnostics. Its paths and programs
are explicit environment inputs. Missing inputs fail; tests do not invent GPU
execution or producer provenance from a TSV supplied by a caller.
