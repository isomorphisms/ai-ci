# Physical evidence boundary

The user requested the real SDF/Gmail procedure be designed but not committed.
That procedure is delivered separately. This public directory contains only the
evidence schema and the rule separating live acceptance from hosted simulation.
No real mailbox, source path, credential, token, private key, or Gmail identifier
belongs in the public fixture corpus.

A public receipt may use opaque source/destination aliases and redacted evidence
references. Digests are not automatically anonymous: private message hashes can
permit correlation or guessing. Keep raw digests and actual IDs private by
default; use keyed digests for externally shared linkage when necessary. The
key stays private. A redacted receipt points to private evidence; it cannot by
itself establish the content of inaccessible evidence.

`NOT_RUN` is the current physical status. A local server, loopback test, model,
cloud runner or replay adapter never satisfies `physical-sdf-gmail`.
