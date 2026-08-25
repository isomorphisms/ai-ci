# F-Droid release contract

The `fdroid/` action is the shared fail-closed release gate for Android games
submitted to F-Droid. It validates a contract against a receipt produced by the
actual F-Droid build and review jobs. It does not treat an upstream Gradle build
as an F-Droid build, and it does not turn “the command ran” into “the release is
accepted.”

The gate binds every observation to:

- one full immutable source revision;
- one full `fdroiddata` revision;
- one full `fdroidserver` revision;
- one buildserver image digest, not a mutable image tag;
- the package, version name, and version code;
- a nonempty witness file whose current SHA-256 matches the receipt.

It also opens each declared APK as a ZIP, requires `AndroidManifest.xml`, checks
the native ABI inventory against the contract, verifies the current artifact
hash, and requires two clean F-Droid rebuilds of each declared rebuild artifact
to be byte-identical. Undeclared receipt rows, duplicate rows, missing evidence,
`fail`, and `not-verified` all block.

## Three gates, not one ambiguous green check

| Profile | Meaning | Additional evidence |
| --- | --- | --- |
| `candidate-v1` | The exact source release is ready to submit. | Local reproduction of the current fdroiddata checks, two clean builds, APK inspection, install/launch evidence, and policy reviews. |
| `submission-v1` | The submitted fdroiddata change has passed F-Droid's own review path. | Successful official fdroiddata pipeline and a resolved maintainer review. |
| `publication-v1` | The accepted build is actually available to users. | Exact package/version in the public index and an install of the published APK. |

A candidate pass does not claim that F-Droid accepted or published the app.
Likewise, an open merge request or a script that successfully queried GitLab is
not submission acceptance.

## Signing and reproducibility

Set `signing` to one of:

- `upstream`: the contract requires the developer-signed upstream APK, the
  expected signing-key evidence, and a successful F-Droid signature-copy
  reproducibility verification in addition to two byte-identical clean F-Droid
  rebuilds. This is the preferred starting point for a new app when it can be
  made reproducible.
- `fdroid`: F-Droid signs the APK. Two clean F-Droid rebuilds are still required
  by this contract, but there is no claim that a developer-signed APK was
  reproduced.

Choose before first publication. Moving from an F-Droid signing key to an
upstream developer key later normally requires users to uninstall and reinstall
because Android will not accept the new signer as an update.

Two builds made in the same pinned environment establish deterministic output;
they are not diverse double compilation. For `upstream`, the separate
`upstream-reproducible` row must witness F-Droid's actual verification of the
developer-signed APK against its source rebuild.

## Contract format

Contracts are UTF-8 TSV. Blank lines and `#` comments are ignored.

```text
receipt DIAGNOSTIC
release DIAGNOSTIC package version-name version-code full-source-revision
toolchain DIAGNOSTIC full-fdroiddata-revision full-fdroidserver-revision image@sha256:digest
profile candidate-v1|submission-v1|publication-v1
signing fdroid|upstream
native yes|no
artifact DIAGNOSTIC name rebuild|upstream package version-name version-code abi-list|none
same_artifact DIAGNOSTIC first-rebuild second-rebuild
abi_order DIAGNOSTIC lower-version-code-artifact ... higher-version-code-artifact
```

Every artifact must use the release package and version name, and no artifact
version code may exceed the release version code. At least one rebuild must use
the release version code. Every `rebuild` artifact must be in a
`same_artifact` pair with identical package, version, version code, and ABI
declarations. With `signing upstream`, each rebuild variant must have a matching
`upstream` variant and vice versa. With `native yes`, every artifact declares
one or more of `armeabi-v7a`, `arm64-v8a`, `x86`, and `x86_64`.

For a universal APK, list all included ABIs in one artifact row. For ABI-split
delivery, declare each APK separately, give it its real version code, pair each
split with its second clean rebuild, and use `abi_order` to enforce increasing
version codes. The contract rejects missing, duplicate, or out-of-architecture
ordering entries before it reads a receipt. F-Droid currently recommends the compatible ordering
`armeabi-v7a < arm64-v8a < x86 < x86_64`; all codes for a new release must also
exceed every code retained from the previous release.

The example contract pins the fdroiddata and fdroidserver heads inspected on
2026-08-25 and the then-current buildserver image digest. Copy it; do not reuse
its example package, version, or source revision, and re-review toolchain pins
when F-Droid changes its pipeline.

## Receipt format

The receipt has this exact header:

```text
kind	name	status	source_revision	fdroiddata_revision	fdroidserver_revision	image_digest	package	version_name	version_code	abis	witness	sha256
```

`kind` is `release`, `toolchain`, `check`, or `artifact`. `status` is exactly
`pass`, `fail`, or `not-verified`; only `pass` satisfies a required row. Witness
paths are relative to the action's `root`. Each witness must be a nonempty
regular file and its receipt digest must match its current bytes.

The candidate profile requires these check names:

| Check | Required witness |
| --- | --- |
| `source-public` | The public repository was acquired through the same URL/path F-Droid will use, and the contract's full source revision exists there. |
| `license-review` | Commit-bound review of application code, dependencies, art, fonts, audio, and other shipped assets. |
| `dependency-review` | Commit-bound review for non-free libraries, services, tracking, ads, executable downloads, and declared anti-features. |
| `tag-binding` | The release tag resolves to the contract's full source revision and version fields at that revision match. |
| `version-history` | Every declared APK version code exceeds every retained APK from prior releases, including every ABI variant. |
| `metadata-read` | `fdroid readmeta` succeeded. |
| `metadata-schema` | The current fdroiddata JSON schema accepted the app metadata. |
| `metadata-rewrite` | `fdroid rewritemeta APPID` made no change. |
| `metadata-lint` | `fdroid lint APPID` returned no warning/error. |
| `update-check` | The current fdroiddata update check made no unexpected change. |
| `git-redirect` | The repository URL is direct rather than a redirect. |
| `metadata-tools` | Current fdroiddata localized-metadata, image/EXIF, summary, and signature checks passed. |
| `fastlane` | Current fdroiddata source/Fastlane check passed for title, descriptions, icon, screenshots, and changelog. |
| `fdroid-build` | The production-like buildserver job built the declared app/version from source with scanner refresh enabled. |
| `gradle-audit` | Current fdroiddata Gradle audit passed. |
| `source-scan` | F-Droid's source scanner found no undeclared/unacceptable binary input. |
| `apk-scan` | `fdroid scanner --exit-code` accepted the finished APK. |
| `apk-identity` | Package, version name, version code, manifest flags, and ABI contents were read from the finished APK itself. |
| `signing-policy` | The artifact is unsigned for F-Droid signing, or the upstream signer and verification configuration are exactly the declared ones. |
| `install-launch` | The exact candidate APK installed, launched the expected package, and completed the app-specific smoke path on a declared Android target. |

`signing upstream` additionally requires `upstream-reproducible` and
`signing-key`. `submission-v1` adds `fdroiddata-pipeline` and
`fdroiddata-review`. `publication-v1` adds `published-index` and
`published-install`.

`fdroid/official-checks-v1.tsv` records the current command/job mapping used to
produce those witnesses. The receipt-producing workflow is trusted executable
policy: keep it reviewed and do not let untrusted pull requests replace it or
run it in a secret-bearing context.

## Use

After the F-Droid jobs have produced the receipt, logs, and APKs:

```text
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 -o /tmp/aici-fdroid src/aici_fdroid.c
/tmp/aici-fdroid verify ci/fdroid-release.contract.tsv out/fdroid/receipt.tsv out/fdroid
```

Or pin the reviewed action commit:

```yaml
- uses: isomorphisms/ai-ci/fdroid@0123456789abcdef0123456789abcdef01234567
  with:
    contract: ci/fdroid-release.contract.tsv
    receipt: out/fdroid/receipt.tsv
    root: out/fdroid
```

Do not copy the placeholder action SHA.

## Deliberate limit

No generic program can determine all copyright ownership, license
compatibility, privacy behavior, anti-features, or whether a game is genuinely
functional. Those rows therefore require explicit review witnesses bound to the
same source revision; absence or uncertainty blocks. F-Droid maintainers retain
the final inclusion judgment. This gate prevents missing, stale, mutable, or
contradictory evidence from being mislabeled as acceptance.

The v1 boundary is grounded in F-Droid's
[submission guide](https://f-droid.org/docs/Submitting_to_F-Droid_Quick_Start_Guide/),
[inclusion policy](https://f-droid.org/docs/Inclusion_Policy/),
[build metadata reference](https://f-droid.org/docs/Build_Metadata_Reference/),
[reproducible-build documentation](https://f-droid.org/docs/Reproducible_Builds/),
and the pinned
[fdroiddata pipeline](https://gitlab.com/fdroid/fdroiddata/-/blob/4498e27635a1c3b737510342c1f2355c25ce0211/.gitlab-ci.yml).
