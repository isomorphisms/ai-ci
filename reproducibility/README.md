# Independent complete-build comparison

This gate compares two complete consumer builds after each build has run in its
own source, work and output roots. It consumes the version 2 NativeActivity
receipt released by [isomorphisms/android-NDK PR #17, “Make NativeActivity
packaging reproducible with a source epoch”](https://github.com/isomorphisms/android-NDK/pull/17)
at exact head `75d2c6b88443c9cf865c30146a06b89868a182c5`. That pull request remains
draft and unmerged; callers must check out the exact head rather than assuming
the contract exists on `android-NDK` main.

The exact S01 schema SHA-256 used by this qualification is
`1b6af10a2e81197b5ebb8413577f6834c440e4eb78e0df6b95f13a4bbaca1c70`.
The contract also binds the independently approved compiler, dependency,
profile, recipe, policy, signer and package-tool closures. Two builds made with
the same wrong inherited NDK therefore cannot pass merely because their bytes
match.

## Inputs

The consumer supplies one fixed contract and two attempt receipts. All are
strict ordered two-column TSV.

The contract fixes:

- consumer and exact source revision;
- dependency and compiler closure digests;
- the digest of the eight package tools named by the S01 receipt;
- profile, recipe, policy, signer, ABI and S01 packager revision;
- exact S01 receipt-schema bytes; and
- the independently verified execution-witness schema.

Each attempt records its distinct source, work and output roots, timezone,
input order and mode profile, exact material identities, witness bytes,
executed-case bytes, package receipt, native library and signed APK. The
verifier resolves every root and rehashes the actual witness, case list, native
library, signed APK, attempt and package receipt. It independently recomputes
the S01 material digest and the approved package-tool closure.

The two attempts must use disjoint roots, different environment variations and
different execution witnesses. Evidence or outputs cannot share an inode. The
native, unsigned, aligned and signed stage digests must all match. Attempt IDs,
paths and witness bytes remain outside the canonical package material and may
differ.

## Result

On success the verifier emits `aici-independent-build-verdict-v1`. The verdict
binds both attempt and witness hashes, both executed-case hashes, the exact
package receipts, contract, every approved material identity and all four
output stages. Any
source, dependency, tool, profile, recipe or policy change makes that verdict
inapplicable and requires a new comparison.

The reusable action accepts these paths:

```yaml
- uses: isomorphisms/ai-ci/reproducibility@FULL_AI_CI_COMMIT
  id: reproducibility
  with:
    contract: reproducibility.contract.tsv
    left-attempt: build-a/attempt.tsv
    left-output-root: build-a/output
    right-attempt: build-b/attempt.tsv
    right-output-root: build-b/output
    ndk-receipt-schema: android-NDK/apk/nativeactivity-receipt-v2.schema.tsv
```

## Hostile controls and evidence boundary

The self-test accepts equivalent independently witnessed builds and rejects a
reused first-attempt witness, hidden dependency drift, wrong NDK revision,
omitted unsigned stage, unequal signed bytes, shared output inodes, unchanged
environment variation, an unverified witness and stale policy reuse.

This comparator consumes a separately verified process witness; it does not
authenticate the witness issuer itself. Until BC-P01 releases and qualifies
that interface against real isolated execution, fixture witnesses prove parser
and comparison behavior only. A passing package comparison proves this fixed
hosted build boundary. It does not prove installation, launch, application
behavior, physical display, publication or release admission. ARMv7 and
AArch64 use separate contracts and verdicts; this gate never asks their output
bytes to match each other.

