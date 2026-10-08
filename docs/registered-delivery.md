# Accept the registered transfer handoff

`validators/registered_delivery.pi` extends the existing Flexible Pipes result
and handoff contracts. It does not register recipes, promote a candidate, or
replace the root supervisor's admission and deployment checks. Kitchen keeps
recipe ownership; Flexible Pipes keeps its approved registry; Cat Food keeps
artifact sealing; this repository checks the observed result and satisfaction
of the human's requested delivery.

`check-registered-delivery.pi` takes CONFIG REQUEST RESULT ARTIFACT_DIRECTORY
STAGE RESPONSE SUBMISSION RECEIPT through checked Ithon. The controller supplies
the protected installed configuration, original request and submission, exact
client exports, and its captured handoff stage/response. Required evidence is
compared against that independent configuration, never requirements supplied
by the proposed operation. A caller-authored collection of files is a fixture,
not an attestation of a real ChatGPT message or trusted deployment.

The gate compares the request and intake provenance, current qualification and
release, exact material/checker/runtime bytes, operation and explicit parameters,
all required stage checks, authority and promotion, and the complete ordered
output pair declared by the existing approved contract. It passes the compact
`human-transfer-paste` bytes into the maintained `job_delivery.check` gate,
binding the captured request identity, complete visible bytes, and response.
Missing checks, current-byte changes under unchanged Git names, stale release
evidence, another operation or repository, changed outputs, a hidden or truncated
paste, and a link substitute cannot inherit the acceptance.

PENDING, BLOCKED, PARTIAL and failed states are preserved by their producer receipts;
they do not establish accepted delivery. Before each CLI evaluation, any old
acceptance is invalidated atomically. Invalid input or failed validation records
FAILED, PARTIAL or BLOCKED and rethrows the original failure; only VERIFIED
exports PASS. Successful receipts identify the exact input
snapshots and checker bytes and explicitly exclude live transfer, actual
ChatGPT-surface observation, and fresh model judgment.

This captured-delivery CLI cannot export a deployed-trusted acceptance. Use the
[independent request/delivery supplement](request-delivery.md) with root-owned
observations, the full registered output directory and original submission.
That supplement calls this maintained versioned checker before accepting the
human paste. A frontend failure before either entrypoint executes requires the
supervisor to allocate a fresh attempt and invalidate any stale export.

`tests/registered-delivery/check.pi` supplies protected synthetic material and
captured-sink fixtures with positive controls and targeted negative controls.
The hosted Flexible Pipes qualification separately invokes this checker against
real TLS client exports and the exact maintained generated paste. Both remain
fixture evidence until a trusted platform sink is actually connected.

An unchanged approved qualification can be reused only when its material,
runtime, environment, contract, operation, and qualification identity still
match the installed release. An unchanged accepted generation can be reused
only with identical request bytes and artifact bytes. A new intake may wrap
that reused execution with independently checked current provenance. Neither
a candidate digest nor a Git commit name establishes promotion by itself.
