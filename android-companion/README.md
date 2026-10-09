# Cat Food Android companion artifact verifier (candidate)

This is the independent artifact-level gate for a Cat Food A1/C67 build plan.
It does not build code, authorize a model decision, install packages, or
qualify a physical phone.

Usage with environment:

    AICI_COMPANION_RECEIPT=/absolute/new/receipt.tsv \
      bash android-companion/verify.sh CATFOOD_CHECKOUT APP_CHECKOUT \
      APP_CONTRACT PLAN.tsv APK_MAP.tsv

APK_MAP.tsv has exactly two tab-separated columns, a header target<TAB>apk
and one absolute APK path per required target, named phone or c67.
A shared APK may be listed twice; a split APK must be two distinct files.

Fail-closed checks:
- the leaf contract is tracked and unmodified at the exact app source SHA;
- the canonical plan exactly regenerates from the approved Cat Food checkout;
- Cat Food revision is reachable from its freshly fetched main history;
- each required target has an actual APK, without contradictory extra rows;
- finished APK package, default application label, launcher activity, minSdk
  and numeric versionCode match the approved plan;
- apksigner verifies actual package bytes and the central test-only signing
  registry matches the observed certificate;
- ELF machine and class match each required APK library architecture;
- one common APK digest covers shared targets, or distinct digests cover split;
- blocked/unknown companions cannot disappear behind an A1-only PASS.

Only after all checks does the verifier emit a new, exact-hash receipt.
Build provenance, versionCode update continuity, icon visual comparison,
installation, runtime, emulator, and physical device are NOT_VERIFIED in
this receipt; those require their own producer or runtime gates.

This candidate is intentionally not authority until both AICI and the Cat
Food profile/label policy have been merged and validated on the applicable
main commits. It cannot certify the unmerged Cat Food PR #128 as a release.
