# Source-bound requirement projection

This contract projects already-authorized requirement records into exact bytes
for one maintained request. It does not classify natural language. A human or
upstream owner must explicitly record source kind, authority, selectors,
supersession, applicability and the affected owner/program/target decision.

`owners.tsv` records the components that own the relevant policy or artifact
boundary. `requirements.tsv` distinguishes direct instructions, corrections,
proposals, observations and executed results. Every row keeps an exact source
span, public source location and SHA-256. The request binds the canonical owner
profile and requirement-manifest hashes, so row order is irrelevant while a
changed record is rejected until the request is deliberately rebound.

The checker:

- rejects changed source, profile and requirement hashes;
- rejects missing, duplicate, cyclic or structurally unsupported correction
  chains;
- rejects conflicting active decisions and proposal/non-authoritative records
  promoted into obligations;
- blocks `unknown` authority or applicability for the affected choice;
- requires at least one applicable obligation for each of owner, program and
  target; and
- emits canonical obligation bytes sorted by stable requirement identity.

An irrelevant record or input-row reorder does not change projection bytes. A
new applicable correction does. The historical predecessor remains in the
manifest and the emitted correction names it; history is not rewritten.

The checked-Ithon interface is:

```text
ithon validators/check-requirement-projection.pi project REQUEST OWNERS REQUIREMENTS SOURCE_ROOT PROJECTION
ithon validators/check-requirement-projection.pi validate REQUEST OWNERS REQUIREMENTS SOURCE_ROOT PROJECTION
```

The qualified checked-Ithon revision is
`d6e83969f82512e920fb17b44326cb54f31d015c`. The maintained specimens emit:

| Request | Projection SHA-256 | Required decisions |
| --- | --- | --- |
| SDF/NetBSD Grease leaf | `2b62e5614e8db54d9b004bcd0dc1ee2b3085bcca40eeefce985c0402bab100dd` | Grease leaf ownership, Cat Food matrix/cell ownership, non-C++ eligibility |
| MIRO A1 Grease leaf | `a0981c2268ed3ffd4d56d30a429cb1254803dcefb6326e088878355327f8cbe8` | Grease leaf ownership, Cat Food matrix/companion ownership, non-C++ eligibility |

`validators/job_delivery.pi` accepts these exact UTF-8 projection bytes and
digest as optional request fields, then binds them into the existing immutable
request identity. The A1 delivery fixture exercises that seam. A later consumer
can make the projection mandatory without recreating this checker. The bound
projection's `request_id` must equal the immutable request's `id`.

The SDF good twin and its duplicated-leaf-matrix bad twin are executable. Other
controls reject stale C++ eligibility despite the historical artifact digest,
proposal promotion, an omitted rule, unsupported supersession, wrong target,
unknown applicability and all three stale hash classes. Repeat projection
produces one copy of each obligation.

A valid projection proves only that explicit records were consistently selected
and bound. It does not prove that a model obeyed them, a program ran, a target
was reached, an artifact was deployed, or the source judgments were semantically
correct. Missing history remains unknown.

Sources: [AICI issue 181](https://github.com/isomorphisms/ai-ci/issues/181),
[the approved companion-ownership result](https://github.com/isomorphisms/ai-ci/issues/218#issuecomment-6020460105),
[Cat Food issue 131](https://github.com/isomorphisms/catfood/issues/131), and
[BC-A01-S01](https://github.com/isomorphisms/ai-ci/issues/181#issuecomment-6170074997).
