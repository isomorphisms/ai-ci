# Native-boundary implementation and local evidence — 2026-09-11 EDT

Implementation: PR #86, `native-bionic-boundary`.

The original local session had Debian 13 userspace, x86-64, GCC and Clang, but no Android NDK and no Android emulator or physical-device connection. Repository reads and writes succeeded, while direct container network access did not.

## Evidence actually obtained locally

- Both compilers passed strict C17 compilation (`-Wall -Wextra -Werror -pedantic -O2`).
- For each compiler, both offset-mode self-tests passed: 34 positive native executions and 34 targeted semantic rejections. A bad case only succeeds as a regression fixture when it exits at its own REJECT assertion, not on a setup error, signal or timeout.
- The host build produced a DSO, two PIE executables, actual ELF inspections, source/compiler provenance, checksummed bundle and tar archive.
- Both actual packaged host probes passed all 17 cases.
- Changed executable bytes, a missing DSO, a partial manifest and a duplicate manifest were all rejected with the intended packaging diagnostics.
- Shell syntax and workflow/matrix inspection passed.
- Missing NDK and reuse of an existing output directory were rejected.

These are local harness/platform observations, not remote exact-head acceptance. The original local build used a minimal local git snapshot `b69831339869d21c7a766c61c06c4642abaca072`; that is not a published GitHub commit. The native source files were compared with the published tree by Git blob identity.

An exploratory GCC `-fanalyzer -Werror` invocation was not accepted as evidence. It flagged intentional invalid-descriptor calls in the errno tests and early-return resource cleanup in isolated child cases. No analyzer-cleanliness claim is made.

## GitHub-hosted exact-source evidence

The old self-hosted-Debian requirement is not part of this boundary. The maintained workflow runs on `ubuntu-24.04`; Android build jobs download and verify Android NDK `27.3.13750724`.

After merging current `main` and preserving the hosted-Ubuntu runner policy, PR source-bearing head `e424d6d7dff0eca092351b9d601212645011782c` ran Native libc boundary workflow 35012458599 successfully for all three matrix targets:

- host job `104527531211`: build plus actual host execution passed;
- ARMv7a job `104527531400`: compile/link/ELF/package checks passed;
- AArch64 job `104527531439`: compile/link/ELF/package checks plus 16-KiB LOAD/RELRO alignment checks passed.

Both Android build manifests bind to native-boundary tree `4d38d894e861b37ef7a41acb5d97edbebe92d88c`, compile API 24, NDK `27.3.13750724`, and Ubuntu 24.04.5 LTS x86-64. Both explicitly record `android_execution=NOT_RUN` and `physical_device=NOT_ESTABLISHED`.

Retained runtime archives from that run:

- ARMv7a: `native-boundary-armv7a.tar.gz`, SHA-256 `c13136a004bf6f7a7e786ef0dbba4707b03155892af925674480e5024782b1f7`.
- AArch64: `native-boundary-aarch64.tar.gz`, SHA-256 `c2a896dae713659968f5910bae2fb993837de0cd1bb047caa6a21bcb7b02383c`.

The AArch64 inspected ELF LOAD alignment is 0x4000. That is build evidence for 16-KiB-compatible layout, not a 16-KiB runtime execution receipt.

The matching build follower jobs now have exact passing receipts. Subsequent commits that only reconcile these evidence records do not alter the `native-boundary/` source tree and must not be relabeled as new Android execution.

## Current acceptance scope — 2026-09-18

The maintained Android emulator workflow now exercises Bionic on API-35 4-KiB and 16-KiB x86-64 images. The follower ledger separately retains exact physical-device receipts for the actual ARMv7 phone and AArch64 tablet targets; the AArch64 tablet reports a 4096-byte runtime page size.

There is no maintained native AArch64 Android emulator target and no maintained native AArch64 16-KiB deployment target. Those two historical follower rows are therefore conditional `n/a`, not blockers. The exact AArch64 artifact has separate translated execution evidence on a 16-KiB Android emulator, which is useful compatibility coverage but is not native-AArch64 or physical-device evidence. Either conditional follower should be reactivated only if a corresponding deployment target is explicitly named.

Consumer-specific calls through JNI, compiler bindings, IB mapped storage and Grease/Ish wrappers are also not tested by this standalone C suite. Consumers must retain their own actual-implementation receipts alongside the platform probe.
