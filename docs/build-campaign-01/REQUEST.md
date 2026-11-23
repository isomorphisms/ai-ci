# STAR BUILD-CAMPAIGN-01 — Turn the recorded build-system backlog into STAR and SUN implementation work

**Execution:** STAR, Ultra.
**Coordinator:** isomorphisms/ai-ci.
**Core repositories:** isomorphisms/ai-ci, isomorphisms/kitchen, isomorphisms/catfood, isomorphisms/flexible-pipes.
**Required hierarchy:** this coordinator STAR → domain STAR jobs → SUN implementation jobs.
**Allocation intent:** make a broad, substantial campaign for the current allocation window. The user expressly wants aggressive use of STAR and SUN, with Ultra reasoning.

## Mission

Recover my recorded intentions for this build system, reconcile them with the actual repositories and unfinished work, and turn the remaining gaps into a large collection of independently runnable jobs.

The intended result is a deterministic, correct, repeatable build and delivery system. A maintained request should resolve the right sources, dependencies, tools, target facts, procedures and acceptance rules; execute the real selected programs; deliver the exact resulting artifacts; and report precisely what succeeded or failed.

My earlier chats contain many of the decisions. Find and apply them. Do not make me restate settled requirements, choose routine implementation splits, repair incomplete handoffs, or notice every downstream dependency myself.

This coordinator must produce other STAR assignments. Those STARs must investigate their domains, settle the necessary questions, and produce SUN jobs that implement, test and integrate the improvements. Create or reuse the corresponding GitHub issues and durable job records when executing this assignment.

**Working scale: approximately 24–36 domain STAR jobs, normally yielding 3–6 substantial SUN jobs apiece.** That would support 72–216 SUN jobs if the evidence supports those splits. Treat this as the intended scale, not a quota: expand for additional distinct work, combine coupled work, and explain a smaller result with an actual coverage/disposition ledger. Do not stop after a customary handful of jobs while documented work remains. Do not manufacture duplicate tasks to reach a number.

The estimate of roughly a thousand outstanding issues is a discovery lead. Measure the reachable backlog; do not repeat that estimate as a verified count.

## 1. Preserve the existing division of responsibility

| Owner | Responsibility |
|---|---|
| ai-ci | Shared requirements, independent acceptance, evidence validity, executable policy, negative controls and enforcement across consumers. |
| Kitchen | Maintained procedures, script preparation and generation, verified human-facing commands, and manual/recovery adapters. |
| Cat Food | Authoritative target/profile facts, package and dependency inventory, build/artifact matrix, provisioning, acquisition, runtime delivery and target-scoped acceptance records. |
| Flexible Pipes | Registered repeatable execution, composition of maintained owner procedures, immutable requests, stage ordering, recorded replay and execution/handoff receipts. |
| Producer/application repositories | Their source, application semantics, declared requirements, project-specific recipes and real consumer behavior. |
| Cockswain, where already implicated | Continuing existing unresolved obligations and reporting their actual state; consuming the owners' records. |

Cat Food's build instructions must lead to a callable maintained Flexible Pipes operation. Kitchen must not become a competing canonical producer pipeline. Flexible Pipes must invoke the owning implementation rather than acquire duplicated policy, target constants or application logic. ai-ci must not become another target registry.

Extend the established interfaces. Do not create another general scheduler, work tracker, hardware registry, test framework or dependency database merely because this campaign spans several repositories.

Use related repositories when the actual dependency graph requires them: android-NDK, ICK, Idriç, Grease, Ish, Ithon, existing runtimes and representative consumers. Keep this campaign focused on their build-system responsibilities. Preserve literal repository/executable names even where their spelling differs from prose.

## 2. Recover intent and inspect the live work before splitting it

Read the current shared and repository-local instructions, architecture documents, failure ledgers, tests, workflows, registries, issue discussions and relevant branches.

Search previous conversations by the four core names, their established aliases, and concrete incidents. Search older periods as well as recent summaries. Useful historical threads include:

- Cat Food's clean-container first-command acceptance and exact-output program fixtures.
- Its compact userland, complete runtime dependencies and preserved workbench/bootstrap attempts.
- Kitchen's preparation, assumptions, preflight, fresh-session acquisition and exact served script.
- Actual ICK-or-NDK execution, explicit capability gaps and refusal of silent compiler substitution.
- Dependency changes producing downstream implementation, mock, test and manifest obligations.
- Human-found test flaws triggering semantic sibling searches and repairs to their upstream generator.
- Flexible Pipes' discrete predictable programs, explicit model stages, recorded replay and actual caller adoption.
- Stable Android update identity, target-specific artifacts, companion builds and physical acceptance.
- Failed handoffs, missing checkouts, stale paths, unavailable programs, disk exhaustion and wrappers hiding failures.

Record each recovered requirement with its source, date, owner, later corrections, current implementation, remaining gap and intended acceptance. Distinguish direct user instructions, assistant proposals, historical reports, source observations and executed evidence. Do not call a summary an original transcript or claim exhaustive history without a coverage denominator. Preserve relevant technical material without publishing private conversation dumps.

Inventory the reachable work through the existing account/repository records. Paginate completely within the supported interfaces; partition searches when a result cap would hide work. Separate issues from pull requests and report inaccessible or incompletely collected scope. Read full bodies and relevant discussions for the actual build-system families.

For active, merged, closed and archived work, determine what behavior exists now. An open issue can describe a repaired original bug and still contain unfinished integration. A closed pull request can retain valuable implementation on an advanced branch. Read the live branch; closed-PR metadata is not sufficient.

Recover existing STAR decisions, SUN assignments and local/unsubmitted work before creating replacements. Preserve a correct decision and assign its unfinished implementation directly. Reopen architectural questions only when newer instructions or concrete evidence require it.

## 3. Start from these existing source records

These are discovery anchors, not a claim that every described defect remains present. Refresh their comments, linked work and current implementation.

| Work to recover | Sources |
|---|---|
| Original reliability backlog and its 24 implementation owners | [Flexible Pipes issue 25](https://github.com/isomorphisms/flexible-pipes/issues/25); [Kitchen issue 1](https://github.com/isomorphisms/kitchen/issues/1). |
| Clean-machine acceptance and preserved historical producer work | [ai-ci issue 149](https://github.com/isomorphisms/ai-ci/issues/149); [Cat Food issue 76](https://github.com/isomorphisms/catfood/issues/76). |
| Whole-inventory delivery and authoritative build matrix | [Cat Food issue 33](https://github.com/isomorphisms/catfood/issues/33); [Cat Food issue 89](https://github.com/isomorphisms/catfood/issues/89). |
| Existing STAR decision and SUN implementation for profile-driven companion plans | [ai-ci issue 218](https://github.com/isomorphisms/ai-ci/issues/218); [Cat Food issue 118](https://github.com/isomorphisms/catfood/issues/118), including its latest candidate chain. |
| Actual compiler execution and mandatory producer acceptance | [ai-ci issue 175](https://github.com/isomorphisms/ai-ci/issues/175); [ai-ci issue 207](https://github.com/isomorphisms/ai-ci/issues/207); [Cat Food issue 109](https://github.com/isomorphisms/catfood/issues/109). |
| One escaped producer family spanning all four owners | [ai-ci issue 225](https://github.com/isomorphisms/ai-ci/issues/225); [Cat Food issue 123](https://github.com/isomorphisms/catfood/issues/123); [Kitchen issue 37](https://github.com/isomorphisms/kitchen/issues/37); [Flexible Pipes issue 44](https://github.com/isomorphisms/flexible-pipes/issues/44). |
| Cross-repository dependency-change obligations | [ai-ci issue 190](https://github.com/isomorphisms/ai-ci/issues/190); [Cat Food issue 95](https://github.com/isomorphisms/catfood/issues/95). |
| Independent oracles, known failures and generator-cause repair | [ai-ci issue 171](https://github.com/isomorphisms/ai-ci/issues/171); [ai-ci issue 183](https://github.com/isomorphisms/ai-ci/issues/183); [Flexible Pipes issue 11](https://github.com/isomorphisms/flexible-pipes/issues/11). |
| Exact fresh-session script acquisition and delivery | [ai-ci issue 205](https://github.com/isomorphisms/ai-ci/issues/205); [ai-ci issue 226](https://github.com/isomorphisms/ai-ci/issues/226); [Cat Food issue 107](https://github.com/isomorphisms/catfood/issues/107). |
| Registered execution, real adoption and final handoff | [Flexible Pipes issue 24](https://github.com/isomorphisms/flexible-pipes/issues/24); [issue 26](https://github.com/isomorphisms/flexible-pipes/issues/26); [issue 39](https://github.com/isomorphisms/flexible-pipes/issues/39); [ai-ci issue 219](https://github.com/isomorphisms/ai-ci/issues/219). |

Also recover [isomorphisms/flexible-pipes PR #31, “Implement registered Kitchen script execution and preserve FP2 qualification attempts”](https://github.com/isomorphisms/flexible-pipes/pull/31), [isomorphisms/flexible-pipes PR #33, “Register Android producer and diagnostic operations with actual behavioral replay”](https://github.com/isomorphisms/flexible-pipes/pull/33), and [isomorphisms/flexible-pipes PR #49, “SUN 1: register and execute paired native Android producer through Cat Food and AICI”](https://github.com/isomorphisms/flexible-pipes/pull/49). Reconcile their retained/current branches and related Cat Food, android-NDK and ai-ci candidates. Do not create another competing Android runner.

Also reconcile the existing runtime/source work: [isomorphisms/flexible-pipes PR #52, “Qualify modified Icky Lua interpreter and embedded runtime through exact ICK”](https://github.com/isomorphisms/flexible-pipes/pull/52), [isomorphisms/flexible-pipes PR #37, “Seed repeatable retained-source and storage transport contracts”](https://github.com/isomorphisms/flexible-pipes/pull/37), [isomorphisms/flexible-pipes PR #38, “Replay retained-source qualification through Kitchen and AICI”](https://github.com/isomorphisms/flexible-pipes/pull/38), and [isomorphisms/flexible-pipes PR #47, “Produce paired A1 and C67 conversation runtime builds”](https://github.com/isomorphisms/flexible-pipes/pull/47). Preserve host qualification separately from Android acceptance.

## 4. Explore these work families and derive the actual STAR partition

Use this table as an investigation matrix. It does not declare 24 independently confirmed defects or replace the existing issue map. Divide families further when different causal mechanisms or independent implementation boundaries warrant it. Combine overlapping entries when they share one inseparable fix.

| Family | Concrete outcome to investigate and assign |
|---|---|
| 01. Recorded instructions in the execution path | Recover settled corrections and prove that the next generated request, command and decision actually obey them. Preserve allowed exploration and unresolved choices. |
| 02. Independent correctness oracles | Replace circular, copied, permissive or wrong-layer expectations with independently specified results; execute bad mutants and benign variants. |
| 03. Acceptance-policy integrity | Bind approved policy, required assertions, signer expectations and baselines independently of the candidate being judged; reject omitted or self-relaxed checks. |
| 04. Failure propagation | Preserve the real failing stage through scripts, subprocesses, pipes, timeouts, cancellation, workflows and reports. No successful wrapper may hide an unexecuted or failed task. |
| 05. Actual compiler and linker qualification | Prove which qualified ICK or NDK executable performed each stage; preserve specific capability gaps and distinct compiler/runtime lanes. |
| 06. Complete source and tool closure | Materialize exact repository identities, revisions, submodules, recipes, tools, runtimes and transitive dependencies. Reject stale or unavailable prerequisites before calling a job runnable. |
| 07. Reproducible build outputs | Measure independently repeated builds under controlled declared inputs; locate timestamp, path, ordering, environment and packaging differences. |
| 08. Incremental builds and caches | Compare incremental/cache-hit results with clean builds. Invalidate reuse on every material source, dependency, recipe, target, tool or policy change. |
| 09. Cat Food target/profile consumption | Make maintained consumers use the same authoritative target facts, preserving physical model, instance, firmware, ABI, capabilities and uncertainty. |
| 10. Companion builds and matrix obligations | Finish the existing directed A1-to-C67 plan, shared/separate artifact grouping and required-cell coverage. Preserve explicit incompatibility and unresolved prerequisites. |
| 11. Canonical producer execution | Turn declared build requirements into actual registered producer calls through Flexible Pipes, with owner-supplied procedures and complete stage/output coverage. |
| 12. Finished-package validation | Inspect the real APK, native archive or DEX output: route, dependencies, ABI, loadability and packaging. For APKs, bind launcher/display label, component, icon reference and declared localization to the source-bound application plan as well. |
| 13. Signing and update continuity | Verify final package identity, approved persistent signer and version continuity; exercise replacement installation without a hidden uninstall or substitute package. |
| 14. Runtime inventory and dependency completeness | Finish real deliverable groups in Cat Food's inventory; distinguish executable packages, libraries, runtime assets and reference-only entries. |
| 15. Clean-host bootstrap | Execute the documented public first command in a bare declared host environment, then real per-tool fixtures with independent exact expected outputs. The verifier must not repair missing producer outputs. Version strings or inventory presence alone cannot satisfy behavioral fixtures. |
| 16. Runtime-only device delivery | Acquire verified prebuilt packages, validate installed material, and handle interrupted/partial updates and generations through the existing delivery model. |
| 17. Exact Kitchen handoffs | Verify the final parameter-bound command/script, including acquisition and interpreter, from a fresh session and unrelated directory. |
| 18. Resource and session correctness | Handle observed storage/resource limits, spaces and malformed arguments, stale partial state, missing optional capabilities and parent-session preservation. |
| 19. Registered Flexible Pipes adoption | Complete the existing qualified operation path and prove a real supported caller reaches it. Preserve the distinction between tested source and an active deployment. |
| 20. Replay, concurrency and recovery | Keep attempts isolated, bind results to admitted requests, reject stale completion, and qualify existing resume/publication behavior under interruption or overlapping execution. |
| 21. Dependency transitions | Turn exact producer contract/revision changes into complete downstream obligations; update affected code, tests, mocks and manifests, then verify reconciliation. |
| 22. Consumer CI coverage | Find omitted gates, incomplete workflow triggers, wrong checkouts and delegated/hidden producers. Prove production changes reach the intended acceptance path. |
| 23. Artifact and job delivery | Carry the exact verified bytes through existing artifact, release and supported user-visible delivery paths. Preserve composition, availability, visibility and dispatch as separate outcomes. |
| 24. Defect propagation and completion | Carry human-found failures through sibling searches, upstream generator repair, consumer adoption and existing follower supervision. Refuse completion while required work remains. |

Use representative real consumers to prove the shared mechanism. Choose them from current evidence; possible sources include existing Crystal, Wegert, Pauli, Young Tableaux, IB and runtime work. Resolve current repository ownership and implementation routes. Application redesign, unrelated mathematical work and engine migration are outside this campaign.

## 5. Make “deterministic and correct” an executable contract

Every domain STAR must select the applicable boundaries below and translate them into concrete SUN acceptance.

**Deterministic planning.** Equal declared source, application requirements, profile, policy, recipe and tool material must produce the same canonical plan and obligations. Request times and attempt identifiers belong outside the stable plan content. Changing material input must invalidate affected downstream evidence.

**Deterministic replay.** Replaying an accepted recorded model result consumes those exact bytes. Fresh model inference remains a separate stage; identical settings do not establish identical fresh output. Follow the existing [Flexible Pipes pipeline contract](https://github.com/isomorphisms/flexible-pipes/blob/main/docs/pipeline-contract.md).

**Repeat and retry effects.** State each operation's intended behavior on repeated requests, retry, interruption and replay. Verify its actual final state, including obligations, inventory, publication, installation and partial replacement where applicable. Require idempotency where the owner promises it; do not infer exactly-once effects from deterministic output.

**Reproducible builds.** Where byte reproducibility is required, build at least twice in independent clean workspaces from the same complete declared closure and compare the actual outputs. Prevent the comparison from copying or reusing the first output. Probe relevant environmental variation. Compare different architectures against their own contracts, not against identical cross-architecture bytes.

Separate unsigned payload, packaged output and signed artifact where their contracts differ. Preserve unexplained differences as failures or unresolved evidence. Do not redefine the output boundary after a mismatch merely to obtain PASS. Stable plan bytes or one artifact hash do not prove reproducible compilation.

**Correct behavior.** State the intended postcondition independently of the implementation. Exercise the maintained entrypoint and real consumer path. Each important assertion needs a valid case and a representative deliberately broken case rejected for the intended reason. Include harmless variations to catch overbroad rejection. Prove the selected cases actually executed.

**Real execution and provenance.** Bind observed executable, source/dependency revisions, target/profile/plan, workflow and attempt, policy, and final artifact bytes. A declaration or copied digest cannot witness its own truth. A checker must not install a missing dependency or run a replacement producer and then credit the original path with success.

**Truthful stage results.** Keep acquisition, compilation, packaging, validation, publication, installation, launch, semantic behavior, emulation and physical execution separate. Preserve skipped, unavailable, interrupted, stale, malformed, wrong-target and not-run results. A later success cannot erase an earlier required failure. Retain failed retry history.

**Current admission versus historical replay.** Exact old material may support forensic replay. Current publication/admission must still satisfy the currently applicable approved policy and authority. A cached old PASS cannot override a changed material dependency or revoked qualification.

**Real integration.** A fixture, schema, README or branch does not prove that users traverse the mechanism. Require at least one concrete producer or consumer to use the repaired path and one demonstrated bypass/failure to be rejected. Preserve deployed, inactive, candidate and qualified states distinctly.

## 6. Carry forward the established implementation constraints

Use the user's named programs and the current repository conventions. Apply the relevant standing skills before authoring code. Prefer Idriç for new helper programs, Grease for authored shell orchestration, and Ish where the established task specifically selects it. Preserve required attempt/gap records. Do not write another language and relabel it. Respect current Ithon requirements for Python-family first-party source.

For maintained compile/link stages, use qualified ICK or the exact evidenced NDK route. Record capability gaps against the actual ICK revision. If neither supports the intended stage, assign the concrete capability work; do not silently relabel a generic compiler as compliant. Keep existing direct-DEX, NativeActivity and native-runtime routes distinct. The dex-jni package/runtime shape is not a third toolchain exemption. Preserve reviewed existing DEX payloads or common trampolines as such; do not introduce rejected Java, Kotlin, Gradle, d8, RefC, generated-C lowering or another undeclared compiler route.

Build and cross-compile on appropriate build hosts. Phones and tablets consume prebuilt artifacts and supply runtime/physical acceptance; do not bootstrap compilers there. Keep MIRO A1, MIRO C67, TAB_P10, GitHub runners, containers, Hetzner, Void and SDF/NetBSD separate. Use only maintained targets and existing obligations; a possible ABI combination does not create a new deployment requirement.

Bootstrap must not expose an OpenAI key, and absence of an optional key must not block unrelated setup. Receipts must retain useful provenance without recording credentials.

Resolve commands and paths from the exact target's Cat Food facts or verified locations. Fresh sessions must not depend on a previous checkout, current directory, hidden variable, invented executable or undeclared installation. Preserve target-specific storage and privilege facts.

Unavailable physical hardware, credentials or deployment access block only the dependent step. Finish all independent implementation, host verification and reviewable delivery. Prepare an exact remaining acceptance job and retain its unmet evidence; do not turn physical absence into either product PASS or a universal campaign stop.

## 7. Build the STAR → STAR → SUN graph

This coordinator owns the cross-system partition and dependency graph. Each domain STAR owns a concrete set of unresolved questions and emits executable SUN implementation/verification assignments. SUN jobs must finish coherent behavior through the real owner and consumer boundaries.

Use stable readable identifiers under STAR BUILD-CAMPAIGN-01. Reuse existing job identifiers where work already has one. Record parent, owner, canonical issue, dependencies, prerequisite artifacts/decisions, intended changed areas, acceptance and readiness.

Prevent collisions: assign one canonical owner for a shared contract and one implementation owner for overlapping paths. Consumers depend on that contract; they do not independently invent it. Parallelize independent research and implementation while serializing incompatible edits or prerequisite-dependent work.

Distinguish a STAR ready to investigate from a SUN ready to implement. A conditional job must name exactly what releases it and how to reject stale prerequisites. Do not present a job as runnable when its required source, tool, decision or artifact is unavailable. An unavailable qualified deployment or ChatGPT sink blocks only execution/admission requiring it. It does not block authoring these assignments, displaying them in this conversation, or implementation jobs whose purpose is to create and qualify that prerequisite.

Do not recurse indefinitely. Domain STARs emit SUN jobs. A new unresolved architecture question may produce a precise blocked dependency or additional sibling STAR through this coordinator; it must not become another generic generator.

Do not force every shared fix through all work families before the first useful result. Identify the earliest independent wave and the critical dependencies unlocking later waves. Continue preparing other grounded jobs while a particular lane awaits a prerequisite.

## 8. Required content of every generated job

Every STAR and SUN assignment must be complete enough to paste into a fresh conversation. Include:

1. **Identity and execution:** descriptive title, STAR or SUN, Ultra, owning repository, parent and canonical issue.
2. **Outcome:** the observable behavior that must become true and its importance to the existing build system.
3. **Recovered intent:** relevant user decisions and corrections, with source references; distinguish settled constraints from unresolved questions.
4. **Current evidence:** verified repository identities, relevant exact refs, files, existing implementation and failing/missing boundary.
5. **Reuse instructions:** existing branch/job/implementation to continue or reconcile, and any superseded assumptions.
6. **Scope and ownership:** responsible components, allowed changes, consumers, non-goals and interfaces that must remain intact.
7. **Prerequisites:** exact decisions, source/material identities, acquisition path and readiness/staleness checks.
8. **Work:** concrete investigation for STAR or implementation/integration for SUN. Name the actual procedures and checks when verified; never invent commands.
9. **Acceptance:** independent expected results, valid and invalid controls, end-to-end consumer evidence, and applicable determinism tests.
10. **Evidence limits:** what the result proves, what remains unavailable, and which target/physical/deployment claims need separate receipts.
11. **Completion and continuation:** required issue/file updates, focused verification, remaining obligations and the exact contradiction that requires renewed STAR judgment.
12. **Authority:** the applicable scope and any explicit merge/publication authority, without inventing permission from job status.

A domain STAR's required output includes its decision and evidence, the fully written SUN jobs, dependency order and exact next executable actions. If an older STAR already settled the design, it should requalify the decision against current evidence and concentrate on the missing SUN work.

A SUN must implement and verify its assigned outcome. Documentation, tests that mirror the implementation, issue filing, or a plausible plan cannot substitute for the requested behavior. If evidence contradicts the STAR decision, preserve the contradiction and return the specific question; continue unrelated in-scope work.

## 9. Create useful issues and retain the complete work

When this assignment runs, create or update actual GitHub work records. Do not merely recommend opening issues.

Deduplicate by required behavior, defect mechanism, owner and acceptance—not title alone. Reuse a matching open issue and add the executable handoff or link. Create a new issue for a genuinely distinct uncovered obligation. Cross-link shared families without turning each repository's participation into a duplicate umbrella project.

Keep durable job packets in the established repository job/documentation location, using ordinary text/Markdown and existing TSV records where appropriate. Extend existing formats instead of introducing another task protocol. Use isolated branches and draft pull requests when needed to make repository changes reviewable.

Carry forward any explicit applicable authority from the task context. Do not infer merge, closure, release, deployment activation or deletion authority merely from this campaign, green CI, or an issue's status. Do not close work to reduce the displayed count. Do not add a recurring model schedule merely to run this one campaign.

If issue or repository writes are unavailable, complete the exact job bodies and proposed records, identify the specific write blocker, and retain them as ready-to-file work. Do not claim that an issue or dispatch exists without its actual result.

## 10. Deliver the campaign without truncation

Return:

- A short account of the recovered architecture and concrete remaining gaps.
- The verified scope and coverage counts, separating issues, PRs, historical decisions and inaccessible material.
- The complete domain STAR assignments, each with a descriptive title and full runnable body.
- A dependency/readiness table, including the first independent wave and blocked prerequisites.
- Direct links to reused/created issues and complete saved job packets.
- A concise list of unresolved decisions and their exact owners.
- A continuation record if further inspected work genuinely remains.

Display the complete authoritative text for jobs presented to the user for copying. A title, link, summary or hidden dispatch does not substitute for the body. Save and check each complete packet before beginning large chat batches: all required sections, intact source links, and an END OF marker followed by that job's identifier. For a large campaign, deliver numbered complete batches and a master index recording authored, visible and filed counts plus the next undelivered job; never cut off a job mid-body. Distinguish fully authored, visibly delivered, filed and actually dispatched work. Do not claim later batches were delivered or executed merely because they were planned.

This coordinator is complete when the reachable scope has a recorded disposition, the grounded STAR assignments are fully authored and preserved, issues are reused/created or specifically blocked, dependencies and overlap are reconciled, and the next runnable wave is explicit.

The implementation campaign is complete only when the SUN results establish their actual required behavior and acceptance. Job count, issue count, merged code and green workflows are not substitutes.

Spend the allocation on recovering intent, finding real defects, making the right architectural decisions, and producing enough precise implementation work to move this build system forward.

END OF STAR BUILD-CAMPAIGN-01
