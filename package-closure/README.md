# Complete delivered material

`manifest.grease ROOT` emits a canonical sorted SHA-256/mode/path TSV for
every regular file except `material.tsv`. `verify.grease ROOT REQUIRED
MANIFEST_GENERATOR GREASE OBSERVED_OUTPUT` recomputes that inventory read-only
and compares it byte-for-byte. The consumer supplies independent required
path/mode pairs. This bounded profile rejects all symlinks and special nodes;
it does not silently follow links outside a package. Paths use ASCII letters,
digits, `_`, `.`, `-`, `/`, and canonical nonempty components.

Missing/changed/extra material, duplicate/reordered/forged records, invalid
paths, missing payloads and wrong modes fail. A producer-written manifest
alone cannot establish semantic behavior or trustworthy origin. Consumers
must bind source, archive digest and executable identities to trusted inputs,
then actually run their own positive and negative semantic controls from an
unrelated directory. They must neither rebuild nor repair delivered material.

First consumer: the retained [dilapidated-shed/icky PR #4,
“Make ICKY's domain types explicit”](https://github.com/dilapidated-shed/icky/pull/4).
Its formerly archived launcher lacked the compiled app. The shared check
owns generic material validation; ICKY owns its source pins, required payload
paths and exact protocol oracle. Platform providers are declared separately;
this profile makes no arbitrary-Linux, Android or physical-device claim.
