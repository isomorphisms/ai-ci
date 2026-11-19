# Native request-binding source checks

The recurring workflow now uses the shared [source build](../grease-fixtures/README.md).
The artifact identities and observations below record the original qualification.

This continuation executes the existing public `tests/job-delivery/check.pi`
entrypoint without skipping its FP/Kitchen generation, controller validation,
69 original delivery cases or nine existing rejection transitions. It is a
source/host fixture qualification, not managed-runtime or platform delivery
acceptance.

The source-scoped workflow pins:

| Input | Exact identity |
| --- | --- |
| Flexible Pipes | `146408ab64fe52c62edaa414126cae5ec952b3ca` |
| Kitchen | `32c3bf2d7c6268b50f1e48395dc972cfbafec7a9` |
| Checked Ithon | `d6e83969f82512e920fb17b44326cb54f31d015c` |
| Partial native Grease source | `dilapidated-shed/oils@cc3cfdf2c21f50e4c3a2ef0a8a94fcc4868e0d29` |
| Owner workflow/artifact | `43726139851` / `14166313138` |
| Actual artifact ZIP SHA-256 | `e6c482068a12253f4c1599ead1d716703e40170071d02075e464e50caf3bf073` |
| Actual extracted executable SHA-256 | `4e9ae57236a2f01d97a2bf1f515e632680cfdbc10259c154b3b37d04a0126550` |

The artifact's executable is copied unchanged to the consumer name `grease`.
The workflow verifies its exact bytes before execution. This hosted build is
distinct from the owner's locally built `ff451e62...` executable; those local
bytes and results are not relabeled as this artifact.

The older partial native runtime `5991182c...`, artifact `14083485063`, failed
the unchanged first read-only GitHub fixture with `Untranslated builtin: shift`
and exit 3. The newer artifact actually executes that fixture successfully.
On 2026-11-16, the unchanged suite at ai-ci
`50f5973b955159ba458750c9208fdf90f95c814d` passed all 69 delivery cases and nine
rejection transitions using the newer bytes. Actual FP display-only generation
and Kitchen source revalidation controls also passed. The requirement projector
passed all 20 cases through the pinned checked-Ithon frontend.

Coverage review found that the attachment and actual-readback fixtures had
unbound requests. Ten added controls now exercise valid/stale bound attachments,
valid/stale actual text and file readback, missing bytes, missing digest,
malformed digest and another request's projection with a freshly matching
digest. The complete local suite passed 79 cases and the same nine rejection
transitions. No implementation, original expectation or public entrypoint was
weakened.

The owner still reports incomplete inherited language behavior and conditional
package admission. Independent whole-language, issuer, static/transitive
closure, Cat Food/FP managed admission and trusted ChatGPT delivery remain
NOT_RUN/NOT_VERIFIED. The original delivery and native handoff jobs used
historical C++ artifact `12192502970`. Their current fixture build comes from
the pinned native source.
