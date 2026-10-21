# Remind Me to Read: independently checked local backups

This is an AI-CI-owned verifier, **not** a copy of the application Java
`PortableBackup` implementation. It checks a completed complete-library ZIP
supplied to the oracle with Python's standard-library ZIP reader, its own
file-name allowlist, schema/foreign-key checks and SHA-256 checks.

```sh
python3 reading-backup/verify.py /path/to/verified-export.zip
python3 -m unittest discover -s reading-backup -p 'test_*.py' -v
```

The oracle must pass positive fixtures and refuse wrong-hash, missing/extra
member, traversal, duplicate member, missing-column, orphan mark/session,
unsupported format and truncated ZIP fixtures.

**Scope limitation:** a synthetically created archive that passes this verifier
does not prove that a real physical phone exported all of its database rows or
books. A third-party hash of that original phone's private files/database and
an actual end-to-end export/restore test are still needed. It also cannot
establish user/device provenance, external archive custody or device APK
update identity. The existing independent
[`android-signing/`](../android-signing/) gate and actual C67/A1 update
receipts are separate requirements.

Track [AI-CI #306](https://github.com/isomorphisms/ai-ci/issues/306),
[Flexible Pipes #238](https://github.com/isomorphisms/flexible-pipes/issues/238)
and [Remind Me to Read PR #4](https://github.com/isomorphisms/remind-me-to-read/pull/4).
