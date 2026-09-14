# Native-boundary implementation and local evidence — 2026-09-11 EDT

Implementation: PR #86, `native-bionic-boundary`, source commit
`db58a65c1076e4e70c73299ecc79396045672463`.

The local session had Debian 13 userspace, x86-64, GCC and Clang, but no Android
NDK and no Android emulator or physical-device connection. Repository reads and
writes succeeded, while direct container network access did not.

## Evidence actually obtained locally

- Both compilers passed strict C17 compilation (`-Wall -Wextra -Werror -pedantic -O2`).
- For each compiler, both offset-mode self-tests passed: 34 positive native
  executions and 34 targeted semantic rejections. A bad case only succeeds as a
  regression fixture when it exits at its own REJECT assertion, not on a setup
  error, signal or timeout.
- The host build produced a DSO, two PIE executables, actual ELF inspections,
  source/compiler provenance, checksummed bundle and tar archive.
- Both actual packaged host probes passed all 17 cases.
- Changed executable bytes, a missing DSO, a partial manifest and a duplicate
  manifest were all rejected with the intended packaging diagnostics.
- Shell syntax and workflow YAML/runner/matrix inspection passed.
- Missing NDK and reuse of an existing output directory were rejected.

These are local harness/platform observations, not full-repository CI acceptance.
The build used a minimal local git snapshot
`b69831339869d21c7a766c61c06c4642abaca072`; that is not a published GitHub commit.
The actual native source files were compared with the published tree using their
Git blob identities:

| File under native-boundary/ | Git blob SHA |
| --- | --- |
| probe.c | 2d7f1bcccc29d4797b37a790899b2ce60700ee7d |
| fixture.c | a595bd2723cab30daa0d8ab7c714ad4a9a846546 |
| build.sh | b90b254073a9d808a608c81e7d93f1ddbe8918a4 |
| run.sh | 8c2354c70973e47daf4cc0355b0e3011fce077ea |
| test.sh | 06d427eac29e58e064bebdad55ba980e357c5df2 |
| README.md | 4375cac6bbb868d374c51679b03edd1dedb7cdcb |

Byte-identical tested source is useful evidence, but the local receipt must not
be relabeled as an exact remote-head execution.

An additional exploratory GCC `-fanalyzer -Werror` invocation did not pass. It
flagged intentional invalid-descriptor calls in the errno tests and early-return
resource cleanup (cases immediately exit their isolated process). No analyzer
cleanliness claim is made, and this was not substituted for the strict compiler
and executable tests above.

## GitHub-hosted build evidence

The self-hosted Debian requirement was removed. Exact-head GitHub Actions now run
on `ubuntu-24.04`; the Android build jobs download and verify Android NDK
27.3.13750724 themselves.

At PR head `128adbc09a7f167ef971ff70ea905c36dea42c6d`, Native libc boundary run
34848766075 completed successfully for host, ARMv7a and AArch64. The host job ran
the executable probes. ARMv7a and AArch64 establish compile/link/ELF/package
evidence only; they do not establish Android execution.

## Outstanding evidence

Android emulator execution, ARMv7 physical phone, AArch64 physical tablet and
AArch64 16-KiB runtime remain separate durable acceptance boundaries. Cross-build
success does not satisfy those runtime obligations.

Consumer-specific calls through JNI, compiler bindings, IB mapped storage and
Grease/Ish wrappers are also not tested by this standalone C suite. Consumers must
retain their own actual-implementation receipts, alongside the platform probe.
