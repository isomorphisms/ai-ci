# BC-CF08 — Close host-specific matrix obligations without borrowing another host's evidence

**1. Identity.** STAR · Ultra · owner: isomorphisms/catfood. Parent: [BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239). Canonical: [Cat Food #89](https://github.com/isomorphisms/catfood/issues/89); host-detection history: [#88](https://github.com/isomorphisms/catfood/issues/88).

**2. Outcome.** Cat Food's existing matrix must expose exact host/runtime/source/artifact obligations for maintained Hetzner, container/GitHub, Void and SDF targets, with truthful missing or unsupported states. One host's successful binary must never accept another OS, libc, CPU or deployment.

**3. Recovered intent.** #89 places target-specific builds under Cat Food while leaves retain recipes. SDF's recorded NetBSD 9.3 amd64/X5460 baseline differs from NetBSD 11 VM tests. [#131's October 10 human correction](https://github.com/isomorphisms/catfood/issues/131) overrides #89's older `grease→greasecpp` recommendation: C++ binaries/runtime dependencies are ineligible; partial `ysh-d` remains incomplete Grease.

**4. Current evidence.** Refresh main `395cdb37a542e653b77d606879bcb78362f2485e`, `android/target.sh`, `TARGETS.md`, `runtime-binaries.tsv`, `followers/targets.tsv` and shared/local AGENTS. Main already requires positive Debian/Ubuntu evidence for automatic cloud selection. [isomorphisms/catfood PR #116, “Refuse NetBSD cloud assumptions and record mailbox host evidence”](https://github.com/isomorphisms/catfood/pull/116), `9d0c946272e73b3d25ee3a0ee48f92085d18c20f`, retains another older candidate. Do not recreate the fixed detector.

**5. Reuse.** Inspect retained `sdf/netbsd-grease@63898163b948d86e693b19a394508a02b5563bd5`, especially `sdf/README.md`, preflight, acquisition and receipts; its C++ Grease feed is no longer eligible. Preserve `sdf/netbsd-d-translations@6f973556b22b7f89c63f185bca3dc3c7bacc767e` as candidate evidence, not completed runtime. [#130](https://github.com/isomorphisms/catfood/issues/130)'s C67 generic-linux jq failure provides a concrete OS/runtime-lane regression.

**6. Ownership.** Cat Food owns target inventory and acquisition; leaves build; FP invokes owners; AICI verifies; Cockswain consumes existing unfinished cells. CF03 owns runtime classification and CF05 first-command behavior. No hardware registry, host scheduler or mailbox application redesign.

**7. Prerequisites.** STAR ready. Target execution requires observed host/account/OS/ABI/libc, permitted storage, exact eligible runtime and supported acquisition. Unknown Void state stays unknown; absent SDF access blocks its live step only.

**8. Investigation / SUN boundaries.** Derive four continuations: reconcile existing maintained host cells and historical receipts; qualify eligible SDF runtime acquisition; establish Void-specific closure/acquisition without Debian assumptions; repair actual OS-versus-ABI utility selection using C67 jq as a regression. Coordinate edits to shared selectors and manifests.

**9. Acceptance.** Independent fixtures reject NetBSD→cloud, generic-glibc→Android substitution, wrong CPU/runtime closure and missing source inputs; accept declared supported hosts and harmless shell/path variation. Exercise each real maintained entrypoint, including identical retry and interrupted acquisition. Compare deterministic matrix obligations, retaining missing cells and failed stages.

**10. Limits.** Source inspection, VM, host packaging and physical installation are separate. No CPU tuning or native-host PASS follows from CI labels or architecture alone.

**11. Completion.** File decision, full SUN Ultra jobs, per-host readiness/dependency table, exact next actions and unresolved owner obligations.

**12. Authority:** Investigate, perform bounded disposable qualification needed to settle this domain, and create SUN issue/file records and reviewable draft PRs. SUN jobs must implement and verify their assigned scope. No merge, closure, release, managed-system installation, deployment activation, recurring schedule or actual Work dispatch is inferred.

END OF BC-CF08
