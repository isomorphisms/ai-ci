# Metamorphic and generative properties

`audit.c` verifies all committed source/object lengths and SHA-256 values and
checks the relations below. It reads raw files and declared observations; it
does not parse mail. The runner separately compares every partitioned run against
the same established expected facts and source bytes, so two identically wrong
chunkings cannot pass merely by agreeing with one another.

| Relation | Justification | Execution |
| --- | --- | --- |
| Repartition one byte stream | U-RAW, byte-stream abstraction | Every case; all cuts below 4096 bytes |
| Fresh legal folded header instance | R5322 §§2.2.3, 3.6 | `accept challenge`; controller generates seed-indexed RFC cases and checks all partitions |
| base64 vs wrapped base64 | R2045 §6.8 | Equal literal decoded files; unequal raw files |
| QP vs 7bit literal | R2045 §6.7 | Equal literal decoded files |
| Preserve header folding in raw, unfold only structure | R5322 §2.2.3 | rfc-folded-repeated under all partitions |
| Hidden server outcome cannot change locally knowable restart state | U-CRASH indistinguishable histories | Paired ack-lost facts equal |
| Durable and volatile acknowledgement differ after crash | U-CRASH | Paired facts deliberately unequal |
| Equal content need not mean equal source occurrence | U-IDENTITY | identity message 0/2 bytes equal; distinct locators |
| Equal Message-ID need not mean equal content | U-IDENTITY | identity message 0/1 bytes unequal |

Conditional properties are **not** enabled prematurely:

- Mbox concatenation needs the selected separator/final-newline convention.
- Adding a header can shift all absolute body offsets; compare unrelated semantic
  payload, never claim raw equality. Structured header meaning, signatures and
  import options can make a supposedly irrelevant header relevant.
- Decode→encode round trips preserve decoded content only under a selected legal
  encoding/charset profile, never necessarily original octets.
- Checkpoint restart must compare independent destination effects after actual
  process death, not just model facts.

The generator accepts a seed and bounded count to build legal folded extension
headers with alternating whitespace, varied fold counts and payload identifiers.
No parser output supplies their answers. Exhaustive partitioning composes with
these generated messages. Additional structure-aware generators for MIME nesting,
mbox dialects, truncation and concrete ledger records are pending the relevant
source/format decisions. Random garbage is not treated as a replacement.

`accept challenge` obtains a seed from `/dev/urandom` unless the controller
supplies one, writes it into `challenge.tsv`, and makes the run reproducible
after failure. The generator represents a deliberately narrow RFC profile. It
detects finite public-case recognition but does not prevent a malicious adapter
from reading its case ID, reconstructing the documented grammar, or forging its
own receipt. Controller isolation and independently audited implementation
execution remain required for that stronger threat model.

Reduction procedure: first preserve input, source/spec IDs, exact executable,
seed, schedule and failure diagnostic. Reduce schedules by merging adjacent
chunks while retaining the same failure; the runner's cut-N enumeration supplies
small deterministic two-chunk witnesses. Reduce grammar constructions next by
removing complete generated headers/folds/parts while regenerating their declared
answers from construction. Never keep the old offsets after deleting bytes.
Re-check the reduced fixture independently, then commit the bytes, manifest,
seed and reason as a permanent regression. An automated general reducer is not
implemented; this is an explicit remaining capability, not a fuzz PASS.
