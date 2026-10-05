# Fleet merge-gate rollout

`docs/merge-gate-fleet.tsv` is the deployment manifest for repositories that
participate in ordinary current work. Each active default-branch ruleset has
one small, always-eligible, exact-PR-head context. The live collector verifies
that the context is still present in the applicable ruleset and then applies
repository-owned conditional evidence requirements.

The universal context is deliberately not the whole acceptance boundary. A
check is listed as universal only when its workflow runs for every pull request
to the protected branch and explicitly checks out the PR head. Workflows with
path filters, hardware availability, external credentials, scheduled cadence,
or repository-specific applicability remain conditional inputs to the merge
contract. Their absence on an unrelated change is not a permanently pending
branch gate; their absence on an applicable change is a deterministic blocker.

Physical evidence is never inferred from QEMU, an Android emulator, a package
build, or a GitHub-hosted runner. Grease, IB, idric-arm-thumb, Cat Food, and the
Android utility repository retain their repository-specific phone/tablet or
replacement-install boundaries. The fleet manifest says `conditional-only`
where no physical device is required for an ordinary unrelated merge.

## Enforcement procedure

For every listed repository:

1. keep deletion, non-fast-forward, and pull-request rules active with no
   bypass actor;
2. require only the manifest's universal status context;
3. collect the live PR head, live base, exact checkout witness, checks, scope,
   dependencies, receipts, and contextual-authority receipt;
4. pass the collected files to `merge/pr-verdict.sh` without reimplementing
   verifier policy in the collector;
5. retain a closed failing proof PR showing that the normal merge route is
   blocked, and a merged clean proof PR showing the context is always eligible;
6. re-run both directions after changing the universal context or ruleset.

The GitHub ruleset prevents a normal merge when the always-present context is
missing or red. The merge contract remains the stricter decision boundary for
conditional semantic checks, exact artifacts, stack parents, scheduled work,
and physical-device evidence. A green synthetic merge checkout cannot satisfy
the contract because every manifest context has an explicit exact-head witness.

Contextual authority is supplied only by a Cockswain classification receipt.
Cockswain may recover an earlier merge-authorizing task through a later
ambiguous continuation, revocation, or correction. It does not claim GitHub
state. ai-ci binds that receipt to the current exact repository state and does
not infer conversation semantics. Missing private context remains `UNKNOWN`.
