# BC-CF08 decision — 2026-10-14

Three distinct implementation continuations are justified: existing host-cell reconciliation, SDF acquisition eligibility/recovery, and the concrete C67 support-binary OS/runtime bug. A separate speculative Void installer is not justified by current host evidence.

## Current findings

Cat Food main is `8ba159f8322cd436aa8e6400b0eded2d74c14011`. Positive Debian/Ubuntu cloud detection is already implemented; do not reissue the repaired detector. Current `followers/targets.tsv` distinguishes A1/C67/TAB_P10/GitHub/container/Hetzner/generic Termux but lacks SDF/Void records. Missing target evidence is not permission to invent deployment requirements.

[Cat Food #130](https://github.com/isomorphisms/catfood/issues/130) reports a physical C67 failure before Android package delivery: generic Linux AArch64 jq probe failed, while Termux jq and a direct Android installer worked. Main still maps Linux+aarch64 directly to the generic lane. The C67 recorder demands the same generic jq hash/receipt. The installer also discards the current-reuse probe exit status before version matching. Tests inject shell programs and a platform override; they do not qualify Android ELF compatibility. BC-CF08-S03 owns this concrete repair, reused by CF03/CF06/CF05.

Retained `sdf/netbsd-grease@63898163b948d86e693b19a394508a02b5563bd5` contains portable preflight/acquisition and independent host-context mediation worth reusing. Its documented package invokes `greasecpp`, now ineligible. `sdf/netbsd-d-translations@6f973556b22b7f89c63f185bca3dc3c7bacc767e` does not establish completed Grease. The September SDF observation is NetBSD9.3 amd64/X5460; NetBSD11 VM and generic amd64 results do not accept it.

## New work does not erase eligibility

[isomorphisms/catfood PR #137, “Restore RHS Grease acquisition with verified owner provenance”](https://github.com/isomorphisms/catfood/pull/137), `90471095201bcabeb7ef920fa0101f4e667d1454`, fixes expiration using owner run38206821183/artifact11727693085 expiring October19. It does not supersede [#131's explicit no-C++ correction](https://github.com/isomorphisms/catfood/issues/131). Runtime-agent inspection identifies the same forbidden executable digest `7e31cd05b7a9d8fb2a4a9e003a7f3fcb0159138506d17f0fb28da8cbe22aa85c`; renewed availability is not eligibility. Source implementation and historical host test results remain separate from approved installation.

#89's October13 update records completed ICKY package/independent host replay at `bc2aad9006d3d44e896d2f5092a7ac82e7bf066b`, source-built Chez closure, and October27 artifact expiry. Reuse this newer result rather than recreating the old missing-compiled-app repair. Its separate Grease harness and absent FP admission/installation remain explicit; do not call the entire managed host ready.

## Coverage/disposition

| Proposed original boundary | Decision |
| --- | --- |
| Maintained host matrix/receipt separation | BC-CF08-S01, existing #89 |
| SDF qualified acquisition | BC-CF08-S02, source work ready, positive runtime conditional |
| Void-specific closure/acquisition | Account within S01 as UNKNOWN; no standalone installer without host/acquisition evidence |
| Android versus generic Linux utility selection | BC-CF08-S03, existing #130 |
| Complete runtime inventory/Grease eligibility | CF03 owner, consumed result |
| First-command behavior | CF05 owner; consumes repaired support acquisition |
| Cockswain completion interpretation | BC-S01 owner, consumes cells |

## Edit order and next action

Begin S01 matrix/disposition and S03 selector/probe repair independently. S02 can repair fail-closed eligibility and portable recovery now, but positive SDF runtime acceptance requires a fully qualified non-C++ artifact and current live host observations. Serialize S03's C67 recorder changes with S3's byte/fact seals. Feed resulting host cells to BC-S01 without a second matrix.

No whole-job cycle is necessary: released material identities and schemas suffice. SDF/Void access blocks their live receipts only. Existing stage-zero POSIX code remains an explicit bootstrap boundary; newly authored orchestration follows Grease/Ithon/Idriç instructions.

## Evidence scope and output

Three complete 12-field SUNs. All 17 current #89 comments, #88's 2, #131's 1 and #130's zero-comment body were collected/read. Source findings were not newly executed, no artifact was installed, and no remote mutation occurred.

