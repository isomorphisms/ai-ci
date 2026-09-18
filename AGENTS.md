# Agent instructions

Read [`README.md`](README.md), [`docs/failure-ledger.md`](docs/failure-ledger.md),
and [`research/llm-failure-modes.md`](research/llm-failure-modes.md). This file is
the canonical shared guardrail for recurrent agent failures. Repository-local
`AGENTS.md` files may add stricter rules; do not copy this whole section into
every repository.

## Recurrent agent anti-patterns

- **Do not claim stronger evidence than was produced.** Source presence,
  generation, compilation, packaging, installation, launch, semantic execution,
  backend execution, physical-device execution, and publication are different
  evidence levels. Claim only the strongest level actually demonstrated.

- **Spell out low-level error names for people.** Human-facing diagnostics, receipts, docs, and terminal instructions must lead with the ordinary meaning of errno, signal, protocol, kernel, libc, or platform symbolic codes rather than assuming the human recognizes the token. Keep the exact symbolic identifier as secondary detail when it is useful for debugging or search, for example `Operation not supported (EOPNOTSUPP)`, `No space left on device (ENOSPC)`, `Interrupted system call (EINTR)`, or `Cross-device operation (EXDEV)`. Do not replace exact machine evidence with prose; present both, with the words first.\n\n- **Do not substitute the requested mechanism.** An oracle, mock, fallback,
  handwritten equivalent, alternate backend, alternate executable, lookalike
  renderer, or convenient reimplementation does not count as acceptance of the
  named implementation.

- **Do not weaken acceptance to obtain green.** Repair the implementation.
  Change a test or contract only when the intended requirement itself is
  independently shown to be wrong or obsolete.

- **Do not reuse stale acceptance.** A successful run from an ancestor, sibling
  branch, previous dependency pin, different artifact, or old PR head is
  historical evidence only. Bind acceptance to the exact revision and material
  pins under review.

- **Distinguish an exact PR head from GitHub's synthetic merge checkout.** A
  normal `pull_request` checkout may execute `refs/pull/<n>/merge`, which is
  useful integration evidence but is not the PR head. When a claim or merge gate
  requires exact-head evidence, bind the checkout, observed check, receipt, and
  artifact to the explicit PR head SHA. Record synthetic-merge evidence as such
  rather than relabeling it as head evidence.

- **Make every required check eligible for the changes it claims to protect.**
  If a workflow uses `paths:`, include every material implementation,
  contract/oracle, fixture, action/script, workflow, and other dependency whose
  change can invalidate the claim. If that dependency set cannot be maintained
  confidently, run the check without a path filter. A green run does not protect
  a later change that could not trigger the check.

- **Name pull requests in human-facing references.** Whenever mentioning a pull
  request to the human, include its current title alongside its PR number. Do not
  use a PR number, exact-head SHA, branch name, or other machine identifier as the
  only human-facing identifier. Keep exact heads and other hashes when they help
  verification or reproducibility, but treat them as additional machine-facing
  evidence, not as a substitute for words the human can recognize.

- **Merge conservatively rather than maximizing merge count.** A GitHub
  `mergeable` flag or one green workflow is not merge authorization. Before
  merging, verify the current PR head, live base/stack topology, intended scope,
  required checks and receipts, unresolved review threads, and any explicitly
  unfinished acceptance. Leave meaningfully ambiguous or under-evidenced work
  open; use the shared `merge/` authorization contract when its evidence model
  applies.

- **Do not invent missing continuity.** If an earlier decision, branch state,
  artifact, or conversation fact cannot actually be recovered, report it as
  missing or uncertain rather than reconstructing a plausible history.

- **Do not restore rejected abstractions from stale precedent.** Explicit current
  human corrections and current architecture outrank inherited code, generated
  files, old branches, bootstrap history, upstream conventions, and familiar
  terminology. Do not reintroduce a rejected ontology under a synonym.

- **Use the current Idriç spelling in prose.** When the language name is written
  as `Edric` or `Edriç`, correct it to `Idriç`. Do not rewrite literal repository
  names, paths, file extensions, identifiers, or executable names such as
  `edric` solely to enforce the prose spelling.

- **Do not let representation define semantics.** Matrices, tuples, compiler
  nodes, ABI records, transport bytes, storage formats, and UI payloads are
  representations unless the semantics explicitly make them part of the object.

- **Distinguish native, raw, and physical layers.** Use `native` for the
  target platform's own lowest useful semantic/system interface for the facility
  being used: for example libc or the kernel system-call boundary on Linux, or
  DEX/ART, JNI/NDK/Bionic, Binder/platform services, and direct device/event
  interfaces on Android. Do not use `native` as a synonym for C++ or another
  implementation language. Use `raw` for assembly, machine instructions,
  registers, encodings, low-level bus/protocol representation or signaling, and
  similar machine-facing detail. Use `physical`, `circuit`, or `electrical`
  for actual gates, voltages, current, capacitance, traces, and other physical
  electronics. The useful native boundary is task-dependent; do not push a
  high-level operation below it merely because deeper representation exists.

- **Do not replace deliberate repository design with conventional practice merely
  because it is familiar.** Before introducing a framework, build system,
  runtime, language, directory structure, or abstraction, inspect the
  repository's established implementation path and current architecture.

- **Do not design from fixtures.** Mocks, sample data, test harnesses, temporary
  platform adapters, and today's first executable path must remain replaceable.
  They do not define the permanent interface.

- **Before adding a parallel design, inspect the surrounding current work.**
  Check the current branch, architecture documents, established interfaces,
  terminology, and nearby active changes before inventing another model for the
  same concept.

- **Avoid parallel branch and pull-request duplication.** Before creating a new
  branch or PR, inspect active work for the same intended change. Reuse or
  reconcile the existing branch when that preserves scope and evidence; create a
  new branch only for genuinely distinct work or when isolation is required for
  safety.

- **Keep reusable enforcement in `ai-ci`.** When the same failure mode,
  evidence rule, workflow-integrity rule, or acceptance boundary applies across
  repositories, put the reusable verifier, contract, action, diagnostics, and
  adversarial fixtures in `isomorphisms/ai-ci`. Consumer repositories should
  keep only their project-specific inputs, expected results, and wiring. Do not
  fork equivalent policy logic into several repositories unless the semantics
  are genuinely different.

- **Mirror substantive design work into the repository.** When a conversation
  establishes or materially develops an architecture idea, alternative,
  constraint, caveat, unresolved question, or evidence boundary, record it in
  the appropriate repository note, issue, design document, or active branch
  rather than leaving it only in chat. Preserve uncertainty: a design note is
  not an implementation claim, and a proposed alternative is not a decision.
  Cross-link neighboring repositories when an idea spans language semantics,
  architecture selection, implementation, and target evidence. Avoid dumping
  transient chatter; capture the durable technical content needed to recover
  the reasoning later.

- **Preserve meaningful stage boundaries.** A later-stage success does not erase
  an earlier-stage failure. Build is not install; install is not launch; launch
  is not semantic behavior; local packaging is not publication.

- **Classify failures at the stage that actually failed.** An unrelated runner,
  secret, upload, publication, reporting, or CI-service failure does not turn a
  separately demonstrated implementation test into a code failure. Conversely,
  passing compile or semantic tests do not make a failed packaging, publication,
  or delivery stage green. Preserve both results and repair the narrow failing
  boundary.

- **Structure build and delivery scripts as composable stages.** Keep dependency
  provisioning, source build, packaging/publication, target detection,
  installation/deployment, runtime acceptance, and receipt recording separately
  inspectable. A wrapper may sequence them, but must not blur their evidence or
  make one stage silently perform an unrelated one.

- **Keep device delivery runtime-only unless the target explicitly is a build
  environment.** Phone/tablet installers should consume declared published
  packages and commodity runtime dependencies rather than cloning source,
  bootstrapping compilers, or falling back to source builds. Keep host build and
  publication work separate from physical-device installation and acceptance.

- **Preserve Android update identity for every first-party installable APK.**
  Every maintained Android project that produces an APK for the human's devices
  must keep a stable application/package ID, a persistent test signing
  certificate for that package, and a monotonically nondecreasing
  `versionCode`. This applies to all current and future phone/tablet utilities
  and apps, not only one repository. Do not generate or substitute a fresh
  signer per developer machine, CI runner, workflow run, branch, prerelease, or
  rebuild. Install/deploy scripts must try replacement installation and must not
  silently uninstall the existing package to get around a signer or downgrade
  failure. Acceptance must exercise replacement installation without uninstalling
  the prior build. Keep public/test signing separate from production or store
  signing. Any intentional package-name or signer migration is a distinct
  migration task and must be explicit because it can require a one-time
  uninstall or supported key-rotation path.

- **Keep target detection separate from target acceptance.** Detecting `phone`,
  `tablet`, `x86_64`, or another target selects the path to run; it is not proof
  that the selected implementation built, installed, launched, or behaved
  correctly. Acceptance must execute the named target-specific action and record
  that result independently.

- **Keep device identity and storage facts scoped to the exact device.** Never
  project a phone path, mount, removable-storage layout, executable location, or
  capacity observation onto a tablet, or vice versa. Before calling a path
  "internal", "external", "SD card", "shared storage", or executable, verify it
  on the named device with direct evidence such as `readlink -f`, `df`,
  mount information, existence checks, or an actual execution attempt as
  appropriate. `~/storage/downloads` means the Android shared Downloads view;
  it is not evidence that an external SD card exists. Likewise,
  `~/storage/external-1` must be observed on that device before use. Treat
  dated device-storage observations as mutable facts and recheck them when they
  materially affect a command, artifact location, or acceptance claim.

- **Preserve explicitly deferred device setup boundaries.** Once the human has
  said that a device facility such as ADB, removable storage, pairing, mounting,
  or another setup path is not working and is deferred for another session,
  treat that facility as unavailable for the current work. Do not reintroduce
  it as a prerequisite, troubleshooting detour, or "one quick step" for an
  acceptance task that has a direct on-device path. Reopen that setup only when
  the human explicitly asks to work on it or when the task inherently cannot be
  performed without it; in the latter case, state the block instead of silently
  converting the task into setup work. Repository-local verified device notes
  outrank generic Android or Termux conventions.

- **Keep repository-specific conventions local.** Do not turn a convention such
  as `_` build layout, a particular backend hierarchy, or temporary subsystem
  leadership into a universal rule unless it is actually shared across
  repositories.

- **Make human-facing scripts independent of the current directory.** Whenever
  giving the human a script or command block, assume `$PWD` is arbitrary. Resolve
  repository and file paths from the script's own location, an explicit project
  location, or a discovered repository root, and perform any required `cd`
  inside the script. Never require the human to `cd` first or rely on relative
  paths against their current working directory.

- **Preserve verified device storage topology in terminal instructions.** Once a
  device path, mount, removable-storage location, or capacity constraint has
  been established, reuse that verified topology instead of falling back to a
  generic shell, Termux, Unix, or repository convention. Before prescribing a
  checkout, download, extraction, build, cache, or other storage-heavy path,
  inspect repository-local instructions and durable target notes. Do not move
  work from an established removable or high-capacity workspace to internal
  storage merely because a familiar path such as `~/opt` is conventional. If
  the current target path is genuinely unknown, verify it with appropriate
  filesystem commands rather than inventing one.

- **Make human paste-back output visually scannable.** Every human-facing
  Termux acceptance, diagnostic, install, or device-test script must use ANSI
  color when the terminal supports it: cyan for section headings, yellow for
  actions or attention, green for PASS/success, and red for FAIL/errors. Apply
  the same convention to other terminal blocks whose output the human is asked
  to paste back. Keep literal receipt fields and other machine-readable evidence
  uncolored, include textual labels in addition to color, and provide a
  plain-text fallback when color is unavailable. Do not rely on color alone to
  convey evidence or status. Do not regress a previously colored device script
  to plain output in a later revision or follow-up.

- **Deliver runnable repository work through GitHub, not chat attachments, by
  default.** When the human needs a script, executable, APK, package, or other
  artifact produced by repository work, put or publish it in the repository,
  a GitHub release, or a GitHub Actions artifact and provide a self-contained
  current-directory-independent script or command that retrieves it from
  GitHub. Do not make a chat/sandbox download link the normal delivery path
  unless the human explicitly asks for one. Pin or report the repository ref,
  workflow run, artifact, or release being fetched; do not silently substitute
  an unrelated or stale artifact.

## ai-ci-specific enforcement

- Every new required assertion needs a passing fixture and a targeted known-bad
  fixture that fails for the intended diagnostic when failure classes matter.
- Scope runtime evidence to the exact process, service, job, or actor under test.
  Unrelated platform noise is not a target failure, and target failure must not
  be hidden by unrelated success.
- When a contract requires `fallback=none`, prove the implementation under test
  performed the work; a wrapper may not hide or relabel a fallback.
- Keep receipts explicit about executable/artifact identity, exact source
  revision, and the stage each result proves.

## Leader/follower enforcement

- Before finishing work led from a phone, tablet, or other architecture-specific
  environment, inspect the consumer repository's follower policy and target
  metadata. Run followers available in the current environment and leave
  durable jobs for the rest.
- Every follower job must name the exact source commit or artifact it follows.
  Do not leave follower obligations only in chat, agent context, or CI logs.
- Close or mark a follower accepted only when its required acceptance kind has a
  matching receipt. Build, runtime, artifact validation, and physical-device
  execution are not interchangeable.
- `unsupported`, inaccessible, and `not run` are never synonyms for green.
  Conditional `n/a` needs a reason.
- If newer work supersedes an unfinished follower, record the supersession
  explicitly. Do not erase the original dependency merely because the branch
  moved forward.
- See [`docs/followers.md`](docs/followers.md) and use `src/aici_followers.c` to
  verify, list pending followers, and render the exact-trigger matrix.

## GitHub workflow and runner enforcement

- Required CI assertions fail closed. Do not hide them behind
  `continue-on-error`, blanket shell `||`, or `set +e`; cleanup paths must
  not convert a failed required assertion into success.
- Pin remote GitHub Actions `uses:` references to a reviewed full commit SHA.
  Do not substitute mutable tags or branches for required CI.
- Maintained Linux GitHub Actions jobs use GitHub-hosted Ubuntu. `ubuntu-latest`
  and concrete `ubuntu-*` labels do not need a special exception.
- Do not recreate the superseded self-hosted Debian rule, a workload-specific
  Debian runner exception, or a generic Debian follower merely to satisfy GitHub
  Actions policy.
- Self-hosted Linux runners are outside the maintained runner policy. A historical
  self-hosted or Debian receipt remains historical evidence; it does not define
  current acceptance or authorize a new self-hosted job.
- Concrete Windows or macOS runners need a reviewed exact exception with a real
  workload reason. Dynamic `runs-on` selection remains outside the source-audited
  contract.
- Checked-in runner labels are configuration, not runtime evidence. Do not infer
  runner availability, provisioning, OS identity, or successful execution from
  workflow text alone.
- See [`github/README.md`](github/README.md) and use the `github/` action to scan
  repository workflow policy.
