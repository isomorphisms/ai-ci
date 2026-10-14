# BC-P03 decision — retain reproducibility repairs and close actual reuse gaps

Research2026-10-14. Parent https://github.com/isomorphisms/ai-ci/issues/239; canonical https://github.com/isomorphisms/android-NDK/issues/14.

Three coherent SUNs are justified; a fourth generic FP receipt job would duplicate FP02/FP03. Reuse [isomorphisms/android-NDK PR #17, “Make NativeActivity packaging reproducible with a source epoch”](https://github.com/isomorphisms/android-NDK/pull/17) at live `max/reproducible-nativeactivity-candidate@12b509b6244848d1b90276344eb9ab52bf3fea81`. Its normalization, ZIP-extra removal and API24+ v2 signing are implemented candidate behavior, not missing work. Its existing valid/old-packager/ZIP-mutant results are historical reports, not new execution in this STAR. Current main `11edd1e0d9748d7c618413ec9f5afad52049046a` also contains merged resource/label/publication safeguards.

| Boundary | Disposition |
| --- | --- |
| Shared packager epoch/metadata behavior | P03-S01 continues exact candidate, adds missing stable-material receipt and resource/asset perturbation coverage. Do not rebuild its original implementation. |
| Complete independently repeated consumer production | P03-S02 extends actual retained Wegert/FastChat routes and independently compares native, unsigned, packaged and signed boundaries. |
| Incremental build and retained material reuse | P03-S03 repairs the demonstrated shared OwnedC dependency omission and proves clean/incremental equivalence through Wegert. No new cache service. |
| Generic request/replay/cache admission | FP02 consumes exact material/output verdict; FP03 owns registered producer. No extra P03 FP implementation. |
| Ike receipt no-recipe/future-mtime behavior | Reuse T01-S04; do not duplicate its acceptance. |

Concrete source finding: ai-ci `f6d825d15cd3c0c34ae1b43240a463ff5d343090/ick-android/OwnedC.cmake` creates custom ICK assembly→NDK object commands whose explicit DEPENDS are only source and driver. It emits `-MMD` depfiles, excluding system headers. The actual child cc1, assembler, builtin/sysroot headers and approved material/policy identity are not complete explicit invalidation inputs. This is a source-grounded missing dependency, not an executed stale-object reproduction yet. P03-S03 must reproduce the targeted failure before repair and reuse P02 material identity instead of writing another inventory.

Wegert `sun/ick-paired-direct-apks@52f6d47332f84015987f3bc0903123f6cb8e9267` already independently rebuilds clean source twice and verifies complete external compiler stages via `_/build/icky/Restore.mk`. Both clean builds use the same pathname sequentially: they do not yet establish path perturbation. Existing restore verification must be preserved; it is stronger than a stamp-only cache. Its `_/build/fdroid/build-apk.sh` still permits inherited NDK defaults, while `release/fdroid-020-verification@5f05c95400fd97821c5f587d895ae686c9aea131` contains the explicit observed-version selector. The branches diverge17/15; reconcile their behavior rather than replacing either with a simplistic new script.

FastChat `max/native-production-candidate@47fe8a6f9401d4b2c82996c5627d104602c0c038` already recompiles native source and repackages twice, but shares HTTP2 libraries/Lua/tool material. Its workflow still pins the CatFood131-forbidden C++ Grease binary. This historical disposable route cannot qualify managed runtime eligibility. The separate current `work/fc-m1-m5-20261014` line was discovered but not source-audited; refresh its producer before adoption, preserving concurrent application work.

Acceptance contracts stay per target: never require ARMv7 and AArch64 byte identity. SOURCE_DATE_EPOCH's API floor must not be raised silently for Pauli's API21 route. Signing identity/installation remain CF07; presentation remains P04. Compare raw unchanged debug/native outputs where promised; unexplained differences fail rather than being stripped away after observation.

Order: source P03-S01 and P03-S03 can begin independently on their own owners. P03-S02 consumes their released material/receipt artifacts plus P01 witness and P02 closure. Registered integration consumes FP02/FP03 interfaces without a whole-job cycle. First execution blocker remains approved obtainable actual compiler/runtime/signer lane; no expensive build or substitution was run here.
