# Release promotion guards

`gate.sh` is shared release policy; application repositories supply exact build
observations, required physical checks and workflow wiring. No compiler or app
runtime is substituted by these shell/JSON checks.

- `property FILE KEY`: read one nonempty property as data, never source it.
- `verify-run JSON REPOSITORY SOURCE RUN_ID WORKFLOW_PATH`: require a successful
  completed main-branch push run from the same repository and exact source.
- `physical CONTEXT RECEIPT CANDIDATE_APK UNSIGNED_APK`: hash the actual bytes,
  require an exact binding, physical device, named observer, report reference,
  plausible timestamp and every declared check with a nonempty observation.
- `tag-accepted REPOSITORY TAG SOURCE CONTEXT RECEIPT CANDIDATE_APK UNSIGNED_APK`:
  perform that same physical gate immediately before creating an annotated
  stable version tag. The annotation binds the source, APK and receipt hashes.
  Existing tags are never moved; only an identical annotated result is a retry.
- `publish-test REPOSITORY SOURCE RUN_ID ATTEMPT VERSION ASSET_DIRECTORY`:
  derive `test-vVERSION-FULLSHA-runID-aATTEMPT`, outside ordinary stable version
  tags. Existing releases must be prereleases with matching tags and bytes.
  Missing assets may be added; existing bytes are never deleted or replaced.
  The code has no release-edit, force-tag or clobber operation.

The caller is trusted policy: obtain context from the successful named workflow
and actual downloaded artifacts, not from the observation receipt. Keep policy
and acceptance records on reviewed default-branch history; do not execute policy
from an arbitrary source/ref selected by a dispatch input. Pin this policy by
full SHA. Serialize publishing workflows, and keep production credentials out
of PR tests. A repository administrator can still bypass or rewrite workflows;
this is mistake prevention and auditable manual acceptance, not hardware
attestation or a defense against an authorized maintainer forging testimony.

A context has `schema: release-context-v1`, `built_at` (UTC ISO 8601), a `binding`
object and nonempty unique `required_checks`. The binding keys are repository,
source_sha, fdroid_run_id, fdroid_run_attempt, package_id, version_name,
version_code, candidate_apk_sha256 and unsigned_apk_sha256. IDs/version code are
strings. Observations have `schema: physical-acceptance-v1`, that exact binding,
`decision: accepted`, observed_by, report_reference, observed_at, device
(kind=physical, model, android_version), and checks mapping each required name
to `{result: PASS, detail: actual observation}`. Generated drafts must use
`NOT_RUN`, never `accepted` or `PASS` without a human's report.

Keep the receipt in a later default-branch commit rather than altering the
candidate source to record its own future test. This avoids a circular rebuild
requirement. Retain its bytes in Git; annotated tags retain its hash. Neither a
tag nor a GitHub prerelease establishes F-Droid submission or publication.

Run `bash release-promotion/test.sh`. The suite executes the real gate against
positive twins and targeted bad records, then tests the complete tag/publisher
commands using a recording fake GitHub API. It checks zero writes for rejected
cases, byte-identical retries, partial-upload recovery and API-error handling.
The fake data explicitly is synthetic, not physical-device or store evidence.
