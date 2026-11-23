# BC-CF04 — Reconcile installed-material integrity with authoritative runtime obligations

**1. Identity.** STAR · Ultra · owner: isomorphisms/catfood. Parent: [BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239). Canonical: [Cat Food #33](https://github.com/isomorphisms/catfood/issues/33); dependency contract owner: [#95](https://github.com/isomorphisms/catfood/issues/95).

**2. Outcome.** Installation reuse and readiness must depend on actual installed bytes, complete transitive runtime obligations and current approved material. Neither a copied PASS nor deleting an inconvenient declaration may make a broken installation current.

**3. Recovered intent.** [CF-A2-S1's reconciliation](https://github.com/isomorphisms/catfood/issues/33#issuecomment-6039830452) records four S2 failures: installed-byte mutation, actual restriction deletion, runtime-obligation deletion and two-package cycles. Its local `e7111dc954b34fb9d3919f6cbd62812e01b4be22` is unpublished/unavailable here. Preserve the existing S2/S4 split and recover their full assignments before replacement.

**4. Current evidence.** Main `395cdb37a542e653b77d606879bcb78362f2485e` still compares package revision/receipt PASS. Retained `aici-android-producer-receipt@e2d65a5d76ff81bcc65f5cabf8ed2ad0e3a57482` already implements `android/content.sh`, complete tree reconstruction, launcher/dependency hashes, v3 authorization and installation locks. It is 24 commits ahead/one behind main. These are inspected implementations, not fresh executed qualification.

**5. Reuse.** Continue the advanced branch, not the frozen metadata of [isomorphisms/catfood PR #112, “Consume exact AICI Android producer receipts”](https://github.com/isomorphisms/catfood/pull/112). Its current hashes detect changed existing receipts, but do not independently approve new manifests. Restriction deletion can remove the fresh requirement; general structural cycle rejection remains absent despite recursive validation protection.

**6. Ownership.** Cat Food owns package graphs, installed material and local records. AICI owns independent policy approval; #95 consumes its dependency-transition contract. CF01 owns firmware/instance semantics; CF07 owns APK authority. Avoid duplicating their verifiers.

**7. Prerequisites.** STAR ready; implementation waits only for exact recovered S2/S4 decisions and approved obligation inputs. Reconcile main's new plan with retained sealing. Current-source consistency must never be relabeled independent trust.

**8. Investigation / SUN boundaries.** Produce four continuations: integrate existing sealed-tree authorization; bind required restrictions/runtime obligations to independently approved material; validate complete package dependency graphs before effects; qualify interruption/retry/concurrent generation replacement and actual caller adoption. Preserve existing implementation rather than rewriting the seal.

**9. Acceptance.** Run the actual installer, inspector and comparer against independently constructed expected trees. Corrupt installed bytes, delete the real Mali-G57 restriction, remove a runtime obligation and introduce a two-node cycle: each must fail for its intended reason. Benign file ordering, unchanged exact material and compatible shared ARM64 packages must pass. Repeat/retry must preserve valid generations, failed attempts and deterministic obligations without fabricating exactly-once effects.

**10. Limits.** Source inspection and synthetic fixtures do not prove Android execution, independent producer authority or physical acceptance. Keep each stage and unavailable claim explicit.

**11. Completion.** File decision/evidence, complete SUN Ultra jobs, dependencies, focused controls and exact next actions; reconcile original obligations and stale prerequisites.

**12. Authority:** Investigate, perform bounded disposable qualification needed to settle this domain, and create SUN issue/file records and reviewable draft PRs. SUN jobs must implement and verify their assigned scope. No merge, closure, release, managed-system installation, deployment activation, recurring schedule or actual Work dispatch is inferred.

END OF BC-CF04
