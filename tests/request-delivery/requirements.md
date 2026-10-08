# FP-CONTROL-02-A acceptance requirements and type sketch

Continue AICI #205 and Flexible Pipes #18. An approved registry is supplied by
the trusted controller from Flexible Pipes' existing release, never by a request
branch. This suite creates disposable qualification contexts; they confer no
deployment authority. Cat Food continues to own artifact sealing.

## Values and actions

`RequestBytes` are the exact data-only submission selected from the human's
available instruction prefix. `Release` is the independently selected existing
FP deployment configuration plus its contract, qualification, materials, tools,
runtime environment and fixed entrypoints. `OperationResult` is an untrusted
service claim. `ObservedRun` is controller-owned execution and postcondition
evidence. `PayloadBytes` and `ResponseBytes` are separately captured bytes.

The central functions are `release_identity(Release) -> Binding`,
`check(RequestBytes, Release, OperationResult, ObservedRun, PayloadBytes)
-> VerifiedOperation`, and the existing
`job_delivery.check(Stage, PayloadBytes, ResponseBytes, Complete) -> Unit`.
File reads and Git object inspection are effects; hashing and comparisons are
pure. A digest identifies evidence; it never grants authority by itself.

Required checks come from the independently pinned FP contract. Removing a check
and its declaration from candidate data must not relax that contract. Every
required check must have independently captured completion, zero skipped work,
matching request/release/input binding and the expected check identity. Source
files must match both the material bytes and published Git objects. Unchanged
HEAD alone is insufficient. Relevant changed material, dependency, runtime,
environment, checker, registry, source, input or payload invalidates reuse.

The operation remains transfer. Wrong source owner, repository, numeric identity,
destination, operation, context, authority or runner fails. Private synthetic
repository visibility stays private. Every attempted mutating API call must have
the exact intended endpoint/arguments and its own subsequent numeric-identity
observation before another attempt; child stdout cannot establish a postcondition.

The final response must contain the complete approved bytes captured by the
actual supported sink. Truncation, rewriting, link substitution and a failure
after partial delivery cannot export PASS. PENDING, PARTIAL, FAILED, BLOCKED and
VERIFIED are distinct. A retry may recover with unchanged approved evidence;
every final delivery still needs a fresh sink capture.

Positive controls are mandatory: useful supported output, maintained paste
delivery when direct execution is unavailable, reproducible fixed-input
generation, unchanged qualified-evidence reuse and usable exploration. Blanket
refusal cannot satisfy this suite.

## Language and evidence boundary

The requested integration extends existing checked Ithon `.pi` validators and
the existing FP artifact contract. This is maintained Ithon work, not a Python
fallback or a new shell procedure. Idriç is not an exposed compiler in this
execution context; these existing interfaces select Ithon. The suite must run
through the pinned Ithon frontend, including imported modules. No generated C,
RefC, Java or alternative interpreter acceptance is claimed.

The starting Kitchen pin had a standalone Linux Grease artifact. Its actual
successor `933ec7974b7b06050fa107a6733a3d1698cabb87` provides a compact paste unit.
Execute those exact maintained producer bytes twice and independently witness
the complete paste in two empty homes and unrelated directories. Recipe
acquisition uses the owner's immutable pin through an inert acquisition fixture;
no network transfer is performed. Keep fixture acceptance separate from approved
runtime, actual caller, deployed registry and phone acceptance. R's resulting
approved release and reachable caller, actual model replay and fresh model
evaluation remain PENDING. Deterministic orchestration, recorded replay and fresh
model judgment must have separate receipts.
