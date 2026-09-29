# Invariants and reasons

The status `SPEC` means a named specification profile has an independently
constructed answer, not that the unidentified retained parser must already
support that profile. `POLICY` means a requirement explicitly established by this
job. `UNRESOLVED` preserves a question without inventing an answer. Selecting a
retained compatibility profile requires provenance and feature decisions.

| ID | What must hold, and why | Independent evidence | Tests | Mistake detected |
| --- | --- | --- | --- | --- |
| RAW | Archive the exact bytes received, including NUL, high bytes, folding and original endings; later interpretation must not erase source evidence | U-RAW | Every corpus input; normalize-crlf, destructive-unfold, decode-before-archive mutations | A semantic success masks irreversible corruption |
| SPAN | Positions count bytes, use exclusive ends, and stay exact across 2³¹ and 2³²; verify output bytes independently of claimed hashes | U-RAW | source.tsv on every run; offset32 at base 4294967293 | Character offsets, signed overflow, wrong adjacent-message locator |
| CHUNK | Explicit feed partitions leave raw and interpreted observations unchanged | U-RAW; source stream semantics | All cases × whole, one, 2/3/7/17/31, random, every two-chunk cut; drop-boundary-byte | Chunk-local search, UTF-8 decoder reset, CRLF loss |
| HOLDOUT | A finite catalogue must not let a candidate accept only named public examples; fresh valid grammar instances must satisfy the same independently stated RFC profile | R5322 §§2.2.3,3.6; U-RAW | `accept challenge`; generated-holdout and public-fixture-only harness mutations | Case-ID whitelist, literal answer table, public-fixture replay |
| TERMINAL | Would-block, zero payload, EOF, and read failure stay distinct; preserve exactly the received prefix after failure | SSH channel_read_ex docs; src/channel.c; U-RAW; user §§5,9 | pauses, read-error and error-at-N schedules; error-as-eof, again-as-eof, eof-error, complete-failed-input, discard-failed-prefix | Truncated transport mistaken for complete mailbox; unread suffix fabricated; received prefix discarded |
| HEADER | Header names compare without case; order and repeats survive; interpreted unfolding removes fold CRLF but retains following whitespace | R5322 §§2.2.3,3.6 | rfc-folded-repeated, long-fold, unusual-value | Destructive unfolding, map overwrites, excessive whitespace collapse |
| OPTIONAL | Missing optional headers do not require invented values or Message-ID | R5322 §3.6 | rfc-no-optional; missing-id mutation | Rejection or dereference based on assumed Message-ID |
| DISPLAY | Encoded-word display is a separate view; original field bytes remain available | R2047 | rfc-encoded-word, rfc-bad-word | Double decode, replacement characters overwrite source |
| UTF8 | The explicit international-header profile accepts complete UTF-8 sequences across arbitrary byte chunks | R6532 §§3.1–3.2 | rfc-utf8 under one-byte and exhaustive schedules | Host string/code-unit assumptions |
| DECODE | Transfer decoding produces literal expected octets; equivalent payloads need not have identical encoded source | R2045 §6 | mime-base64, base64-wrapped, qp, qp-soft-break, plain, 8bit; decoded-byte | Wrong padding, soft-break handling, NUL truncation |
| TREE | Multipart order and hierarchy survive; alternatives are separate; boundary CRLF ownership is explicit | R2046 §5 | alternative, nested-attachment, nested-message, empty-quoted-boundary | Flattening, boundary prefix search, extra CRLF in attachments |
| PARAM | Extended filename continuations assemble before percent/charset interpretation | R2231 §§3–4 | nested-attachment | UTF-8 split at parameter boundary, attachment name mangling |
| MBOX | Selected separator/escaping convention must come from the retained program; preserve exact source spans before any dequoting | R4155 §2; Q1 | all mbox-* construction records, currently UNRESOLVED | Assuming every From line separates or stripping all > quoting |
| IDENTITY | Source locator, content digest, RFC identifier, occurrence and destination ID are different evidence | U-IDENTITY | identity-collisions and mbox duplicate/absent/malformed/same-body cases | Unjustified message loss by Message-ID or content dedup |
| UNKNOWN | After submission might have happened, lost acknowledgement or local durability leaves an unknown write; never promote it to safe retry | U-CRASH; independent indistinguishability argument below | crash-during-submit, accepted-ack-lost, not-accepted-ack-lost, ack-before-durable | Duplicate import after blind retry |
| DURABLE | Durable acknowledgement with destination ID differs from volatile acknowledgement or corrupt/truncated record | U-CRASH | after-durable, corrupt-tail, truncated-tail; lost-uncertainty | Marking success too early, discarding uncertain intent on restart |
| FAILURE | Definite permanent rejection, not-submitted, accepted, and unknown remain distinct | U-CRASH | definite-failure, before-read, during-read, after-parse, safe-retry | Retrying every error, treating every failed attempt as non-write |
| HOST | Mismatch, missing trust, match and check failure cannot all mean trusted | U-TRUST; knownhost.c and knownhost_checkp | ssh-host-mismatch, host-missing; accept-any-key | SSH happy path without host verification |
| AUTH | TCP, key exchange, authentication, channel and command success are distinct | R4252; session_handshake, userauth, channel source | tcp-only, no-algorithm, auth-failed, channel-denied | Connection success falsely grants authenticated state |
| CHANNEL | stdout and stderr remain separate; nonzero exit status survives; abrupt loss is not ordinary EOF | R4254; channel.c, packet.c, test_exit_status.c | ssh-success, abrupt-close; merge-stdout-stderr, ignore-exit | Error bytes poison mailbox; failed remote cat looks complete |
| FILE | Retained SFTP/SCP reads preserve bytes and surface errors/EOF distinctly | sftp.c, scp.c; sftp_read docs | ssh-sftp/scp model; live fixture plan | Dropping short reads; removing retained file transfer |
| BOUND | Working memory must not scale with total mailbox size; large messages need streaming/spooling or explicit limits | U §13; pinned SDF_MAILBOX.md | large single/many; buffering mutant | Small tests hide whole-mailbox retention |
| EVIDENCE | Missing adapter, unknown dialect, fake receipt or hosted simulation cannot confer a live/physical pass | Governing user rule | exit 2, differential NOT_RUN, coverage states, replay labeling | Green self-test laundered into implementation acceptance |

## Why an uncertain write cannot be retried automatically

Construct two worlds with identical durable local evidence: intent recorded,
request started, no durable acknowledgement. In one, Gmail accepted the message;
in the other, it did not. The restart program cannot distinguish those worlds
from those local records. Blind retry can duplicate the first; declaring success
can lose the second. It must retain uncertainty and obtain new independent
evidence or a human decision. This argument requires no particular ledger
architecture and assumes no undocumented Gmail idempotency guarantee.

`hidden-remote` in model scenarios belongs to the test controller. An adapter
must not use it as information available to the restarting program. The paired
cases require identical visible conclusions. A durable accepted record can
support written status only under the declared, independently tested filesystem
durability assumptions. A real filesystem kill/restart test remains required.

## Equality is indexed by the question

| Comparison | Exact object | Legitimate differences |
| --- | --- | --- |
| Byte | archive.bin, source span, attachment octets | None |
| Structure | ordered header occurrences and MIME part tree | Original field-name case can differ in the interpreted name only |
| Decoded content | transfer-decoded payload files | Different legal base64 line breaks or quoted-printable spelling |
| External behavior | checked host, command outcome, write knowledge, destination effect | Native error spelling and implementation architecture |

No equality above substitutes for another. Malformed input recovery is not
inferred from aesthetic expectations; raw preservation still applies when a
parser rejects or declines interpretation. Standards-profile failures must not
silently rewrite a retained-original compatibility profile.
