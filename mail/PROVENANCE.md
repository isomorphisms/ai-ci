# Source provenance and scope

Audit date: 2026-09-28 request; execution host clock may use UTC on 2026-09-29.
AICI base: `b3af13b3ab2bac9dd7c72bf9dd855ed5a17609b5`, branch `main`.
Work branch: `mail/translation-acceptance`. No Idriç or D branch was changed.

## Original programs

| Subsystem | Exact evidence | Classification |
| --- | --- | --- |
| SSH original | [dilapidated-shed/issh master](https://github.com/dilapidated-shed/issh/tree/67da05b1af80be9039485a9102da5ee9049d6db8), upstream libssh2 source at `8e181e7a8e2ded832be63d2e0749d8ff8dc26cd6` | Retained |
| Alternate original placement | issh branch `84332a9bb90f2d4ca9f60839912bd0ace0f9a9b2`, `old/src`, `old/include`, `old/tests`, `old/example` | Same tree objects, not a different source oracle |
| Mailbox/message original | [ICU sdf-mailbox-reader](https://github.com/dilapidated-shed/icu/tree/d7363a58766e17f4677fae8d2e936e9121aa40c9), `SDF_MAILBOX.md` explicitly says design stub | Uncertain: original program not found |
| Provenance investigation | [ICU blocker record](https://github.com/dilapidated-shed/icu/blob/86b4b2882e0da6e9bf72abd31ada4ae5b859f46b/D_MAILBOX_TRANSLATION_PROVENANCE_BLOCKER.md) | Confirms missing parser corpus; not semantic authority |
| Gmail/import original | [idric-cli gmail-cli](https://github.com/dilapidated-shed/idric-cli/tree/dcf24dad158b9100048aff9c4331eef8540a218c), `checkpoints/gmail/README.md` | Design/surface sketch, not a copied importer |
| Other mail candidate | mailR head `d7dcdf3d65843bdcdfe0bbed969a60f858838061`, documented in the ICU investigation | SMTP R wrapper; excluded as unrelated, not asserted as the intended source |

The ICU and Gmail notes were read to locate original programs and discard
decisions, not to borrow Idriç types or translate their proposed APIs. No
translation's outputs establish expected results in this corpus.

## libssh2 exact retained trees

| Path at master / path on issh branch | Git tree object |
| --- | --- |
| src / old/src | `827b18e808f938083bb0485969c46bdbd23e0c40` |
| include / old/include | `f92d2c9423b7f92656816f7a1ce55b0970ee86ee` |
| tests / old/tests | `588250ed9328fcb53e563f8ccee294207d2e92c4` |
| example / old/example | `064d1c0906a5282fcb73f2271ac42bee03874c61` |

`git diff 8e181e7a… 67da05b1… -- src include tests example docs CMakeLists.txt
Makefile.am` is empty. `source-inventory.tsv` records every path and blob ID in
those four trees. Local changes add language work, guidance, CI, an RFC mirror,
license records, and checker exclusions. No deletion from those original trees
was observed. No specific SSH discard has been established.

Acceptance-relevant source areas include `src/session.c`, `kex.c`, `knownhost.c`,
`userauth.c`, `channel.c`, `packet.c`, `transport.c`, `sftp.c`, and `scp.c`.
Relevant upstream tests include `test_hostkey.c`, `test_auth_password_fail_*`,
`test_auth_pubkey_*`, `test_exit_status.c`, `test_read.c`, and
`openssh_fixture.c`. AICI adds a cross-language observable contract; it does not
copy or replace the complete upstream test suite.

CMake and Autotools remain original build paths. Retained crypto facilities
include OpenSSL/LibreSSL, Libgcrypt, mbedTLS, wolfSSL integration, Windows CNG,
OS/400 support, plus optional zlib. Algorithm availability is build/backend
specific; no universal algorithm list or arbitrary obsolete algorithm requirement
is invented. Each live adapter must record backend, build options, supported
algorithms, and the local server's pinned configuration. Windows and OS/400
behavior is platform-specific, not silently discarded.

## Decisions, not deductions from absence

| Decision | Evidence | Acceptance consequence |
| --- | --- | --- |
| Keep retained original behavior; do not restore explicit discards | Current user request | Source-backed retained profile required before full pass |
| ICU deliberately removed most active curl | Pinned SDF_MAILBOX.md and old/ tree | Do not restore curl IMAP/POP3/SMTP to supply a guessed parser |
| Do not expose private historical mail or secrets | Current user request | Public fixtures use reserved example.invalid addresses and synthetic bytes |
| Do not commit the real-service procedure | Current user section 17 | Procedure delivered separately; public receipt schema only |
| No automatic retry of unknown Gmail writes | Current user sections 9 and 12 | Normative safety invariant independent of future ledger format |
| No established mbox discard list | Original parser absent | No guessed omission or recovery rule |
| No established import/dedup policy | Original importer absent | Do not substitute SMTP send, Drive upload, or a Gmail-client sketch |

## Independently consulted specifications

`specifications.tsv` maps evidence IDs to exact sections and URLs. RFC documents
are immutable numbered texts; live Google pages were consulted during this audit.
An updated page does not silently rewrite committed expectations. Source/spec
conflict must be recorded and resolved explicitly. This is especially important
for RFC 4155: its discussion of variant conventions cannot identify the private
SDF file's actual escaping rule. RFC 5322's `Message-ID` uniqueness expectation
does not authorize deleting malformed or duplicated historical occurrences.

Host trust is caller policy above libssh2: the library reports the key and known
host match state; a successful transport handshake does not enforce the mail
client's pinned-host policy automatically. AICI requires the caller to enforce
that policy before authentication or remote commands, per this acceptance job.
