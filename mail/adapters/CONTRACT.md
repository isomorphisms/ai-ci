# MAIL-ACCEPT/1

This adapter exists only for acceptance. Native APIs, programming languages,
buffer ownership, and parser architecture remain unrestricted. The controller
owns fixtures and expected results; the candidate owns only a fresh output
directory. Production CI must keep expected outputs and holdouts unavailable to
the candidate and audit the executed artifact. A cooperative process test is
not protection against a malicious implementation that forges observations.

## Invocation and input

The runner executes an absolute executable with three arguments:
`OPERATION CASE_ID OUTPUT_DIRECTORY`. Supported operations are `rfc`, `mime`,
`mbox`, `migration`, `identity`, and `ssh-model`. `ssh-model` is a state/effect
model and must never be reported as a real encrypted SSH session.

stdin starts with these UTF-8/ASCII control lines:

```text
MAIL-ACCEPT/1
base<TAB>UNSIGNED_DECIMAL
```

Each data frame is `data<TAB>N<LF>`, exactly N raw bytes, and one framing LF.
N must be positive. The framing LF is not input data. The adapter must call its
implementation's feed operation once per complete data frame. A pipe write or
OS read is not a promised feed boundary. The adapter may spool a very large
whole-input frame instead of retaining it all in RAM; record such behavior.

Terminal control is exactly `eof<LF>` or `error<TAB>IO<LF>`. `again<LF>` and
`idle<LF>` represent would-block and a zero-payload read without established
EOF; neither terminates the stream. A pipe closing before a terminal command
is an adapter-protocol failure. The archive contains only supplied DATA bytes.
Ordinary corpus schedules end with EOF. `accept interrupt` also supplies a
prefix followed by IO failure, without sending the unread suffix. Error
injection must not invent source bytes or complete messages.

No locale conversion is allowed. Offsets and byte counts are unsigned decimal
mathematical integers, never floats or JSON numbers. Reject overflow explicitly.
64-bit-or-wider arithmetic is required for the tested range. Empty text values
use `-` in hex fields; all other byte-valued fields use lowercase hex.

## Output files

| File | Meaning |
| --- | --- |
| archive.bin | Exact concatenation of input DATA bytes, including invalid input |
| source.tsv | One row: absolute start, exclusive end, byte count, lowercase SHA-256 |
| terminal.tsv | Exactly `eof` or `io-error`, with LF |
| facts.tsv | Canonical ordered semantic observations for the selected operation |
| part-PATH.bin | Exact decoded leaf payload octets for MIME |
| stdout.bin / stderr.bin | Distinct command streams for SSH scenarios |
| file.bin | SSH file-transfer payload |
| message-N.bin | Raw identity-scenario message artifacts supplied by that scenario |

The controller compares archive and payload files itself; candidate-provided
digests alone are insufficient. Symlinked payload files are rejected. Each
candidate run uses a new directory; reused logs fail rather than look current.
stdout/stderr of the adapter process are bounded diagnostic files, separate from
the SSH command's stdout.bin/stderr.bin. Nonzero adapter exit or missing output
is failure even if some records look good.

Canonical facts:

- RFC: `header INDEX LOWERCASE_NAME_HEX UNFOLDED_BODY_HEX`, followed by optional
  `display subject DISPLAY_UTF8_HEX`, then `body START END`. Whitespace after
  the colon belongs to the unfolded body. Do not trim it or reorder repeats.
- MIME: preorder `part PATH MEDIA_TYPE TRANSFER_ENCODING PAYLOAD_FILE_OR_DASH`.
  Root is `0`, children `0.0`, `0.1`, etc. Container parts have no decoded file.
  `filename PATH UTF8_HEX` follows the leaf whose filename it describes.
  Implicit transfer encoding is `7bit`; media types are lowercase.
- Migration: `knowledge STATE`, `retry safe|prohibited|unnecessary`,
  `complete yes|no`, in that order. This is post-crash knowledge, not an
  undocumented claim that a 2xx HTTP response was durably recorded.
- Identity: ordered occurrence records as shown in identity-collisions. Mapping
  to destination IDs remains unknown; no deduplication rule is implied.
- SSH model: ordered observations in the literal scenario manifest, with
  independent output payload files. Live transport needs the additional server
  witnesses described in ../ssh/README.md.
- Mbox: **not activated**. Proposed receipts distinguish envelope start,
  raw-message start, raw-message exclusive end, archive span, imported-message
  transformation and digest. Resolve Q1 before standardizing exact frame facts.

All separators above mean literal tabs; each record ends with LF. The v1 runner
compares canonical facts exactly. Native names/errors must be mapped explicitly
by the thin adapter. Unknown extra semantic rows are not silently accepted.

## Generated holdouts

`accept challenge ABSOLUTE_GENERATOR ABSOLUTE_ADAPTER NEW_OUTPUT` asks the
controller's generator for 16 valid RFC 5322 folded-header cases after hashing
the adapter. The no-seed form chooses a 32-bit seed from `/dev/urandom`; the
controller records it, both executable hashes, case count and result in
`challenge.tsv`. `SEED COUNT` replays a failure exactly; COUNT ranges from 1 to
64. The generated-only corpus contains no unresolved cases, so a successful
challenge exits zero.

The adapter receives the normal case ID and input stream only. Production
controllers keep the temporary corpus and expected observations outside any
candidate-visible fixture mount. This protects against accidental public-case
tables. It cannot make a cooperative process protocol safe against hostile code
running under the same account; an adapter can still fabricate receipts.

## Chunk schedules

`whole` has one DATA frame. `one`, `2`, `3`, `7`, `17`, `31` divide by that many
bytes, with the last chunk shortened. `random` starts at 0x4d41494c; update an
unsigned 32-bit state with `state = 1664525 × state + 1013904223 (mod 2³²)`, then
take `1 + state mod 31` bytes. `cut-N` splits after byte N. Exhaustive mode adds
every nonempty two-chunk partition of inputs below 4096 bytes. This includes
CRLF, headers, folds, MIME delimiters, transfer encodings, UTF-8, and EOF cuts.
The large-stream protocol is separate: a raw stdin stream and a count/hash
observation, under a controller-enforced resource limit.

`accept interrupt CORPUS ABSOLUTE_ADAPTER NEW_OUTPUT` exercises every prefix
length from zero through the full length for `rfc`, `mime`, and `mbox` inputs
below 4096 bytes. Larger inputs use lengths 0, 1, half (rounded down), length−1,
and length. Each `error-at-N` schedule divides the supplied prefix using the
same deterministic random partition rule, then sends `error<TAB>IO<LF>`.
Failure after the last byte still differs from observed EOF. The empty-input
case likewise distinguishes failure before reading anything from clean EOF.

The controller compares archive.bin directly with the exact supplied prefix,
and source.tsv with that prefix's byte count, absolute span and SHA-256. It
requires terminal.tsv to report io-error. Successful rows say
`PASS_PREFIX_ONLY`: parsed completeness and malformed-prefix recovery are not
inferred. Partial semantic receipts are deliberately not compared with the
complete-message facts. Those semantics require the retained parser profile.
execution.tsv records supplied-bytes separately from input-sha256, which
identifies the complete original fixture. The supplied count records successful
controller writes, not proof of candidate consumption; the archive comparison
establishes the latter for cooperative adapters.

## Results and differential runs

`implementations.tsv` records language, repository, full source commit, absolute
executable, and its expected SHA-256. `-` means unavailable, never PASS. The
runner verifies the executable digest and stores the declared source revision
with process evidence. Build provenance must independently bind that executable
to that revision; a registry entry alone cannot prove it.

The long-form `differential.tsv` is keyed by case, language and schedule. It can
be pivoted to the familiar case × language view without discarding schedule
failures. Each implementation is compared with established evidence first.
Pairwise disagreement is then an investigation lead. Never replace expected
answers with majority output, even if C/original agrees with several ports.
Each available adapter also runs the interruption sweep; its prefix-only rows
remain separate from normal semantic rows. Prefix success cannot clear an
unresolved mbox profile or unavailable adapter.

Keep a resolution record containing case/source/spec IDs, both artifact hashes,
observations, discrepancy class, reason, reviewer, and replacement regression.
The original source can have a bug; classify it rather than silently demanding
that every port reproduce a protocol violation.
