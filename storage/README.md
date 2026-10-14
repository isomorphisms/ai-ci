# Storage fixture acceptance

`verify-fixture.grease` validates the existing IB retained-source fixture
receipt. Kitchen executes the exact committed test source through a declared
Grease runtime; Flexible Pipes schedules/replays that procedure. This verifier
requires independently supplied IB revision/runtime digest, stream hashes,
semantic completion and host-fixture scope. It rejects promotion to live or
physical evidence. It is a receipt consistency gate, not an authentication,
artifact-signing or private-source inspection authority.

Tests under `tests/storage-fixture.grease` include valid counterparts and
targeted scope, source, stream and omitted-evidence mutants. A completed fixture
never establishes that an OpenAI export exists, that a real SDF generation was
uploaded, or that C67 consent succeeded. Those require independent receipts.
