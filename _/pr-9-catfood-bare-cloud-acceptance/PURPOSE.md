# Purpose

PR #9 was meant to give Cat Food an **independent clean-machine acceptance test** owned by ai-ci.

The intended contract was:

1. Begin inside a digest-pinned official Ubuntu 24.04 container.
2. Make the first provisioning commands the same commands documented for a fresh Cat Food machine.
3. Run Cat Food through its public documented entrypoint rather than through a private CI-only setup path.
4. Require Cat Food to have already produced the expected Grease, Idriç, Ithon, Fieldmouse, IR, ICU, and IB artifacts before ai-ci exercises them.
5. Prevent ai-ci from filling in missing Cat Food work by compiling a missing ICU or IB itself and then crediting Cat Food with success.
6. Own small independent fixtures in ai-ci and compare complete output byte-for-byte.
7. Exercise ICU against a deterministic loopback C HTTP server rather than making the acceptance result depend on the public network.
8. Exercise real language/tool behavior, not merely file existence.
9. Run on push and pull request changes and, once present on the default branch, run daily to catch drift in the moving workbench.

The central boundary was: **Cat Food constructs the environment; ai-ci independently verifies what Cat Food actually left behind.**
