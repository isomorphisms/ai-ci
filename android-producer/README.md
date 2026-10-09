# Android producer gate

This action composes the fail-closed checks required before a maintained direct
NativeActivity APK can be treated as a producer-approved artifact.

It verifies that:

- the action is pinned by a full AICI commit already reachable from protected
  `isomorphisms/ai-ci` `main`;
- the consumer's `ci/build-toolchain.tsv` satisfies
  `build-toolchain-v0`;
- the android-NDK packager receipt names a full packager commit already
  reachable from protected `isomorphisms/android-NDK` `main`;
- package ID and signer match the central Android signing registry;
- versionCode, ABI, APK SHA-256, signer, and NativeActivity launcher match the
  finished APK and the packager receipt;
- direct NativeActivity APKs contain no DEX by default;
- when a prior accepted receipt is supplied, package/signer identity remains
  stable and versionCode does not decrease.

A candidate policy or packager PR may be tested as candidate work, but this
normal producer gate deliberately refuses to let an unmerged policy or
packager commit authorize delivery. A full SHA proves byte identity; ancestry
from protected main supplies the additional approval boundary.

The resulting receipt distinguishes producer approval from update-continuity
evidence. If no prior accepted receipt is supplied,
`update_identity_result=NOT_VERIFIED`; producer success must not be relabeled
as replacement-install acceptance.

This gate does not prove physical-device launch, visual correctness, touch
behavior, or other runtime semantics.

The authority self-test distinguishes event roles: a pull-request run rejects
its exact unmerged head, while a main-push run accepts its exact merged SHA
through the authority stage. Both events reject the branch name `main` and
exercise a fixed known merged SHA. Accepted authority is witnessed only by the
deliberate later failure `unsupported packager receipt schema: bogus`; every
fixture must still fail the producer gate and produce no approval receipt.
The workflow logs each reference and its expected diagnostic. It proves no
APK build, install, launch, ABI, physical-device, or runtime acceptance.
