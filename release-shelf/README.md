# Current Android release shelf

This action collects current installable Android artifacts without treating collection as acceptance.

A consumer supplies a file containing one GitHub `owner/repository` per line. For each repository, the collector:

- finds the newest release containing APK assets;
- downloads those APKs unchanged;
- opens each APK as a ZIP and classifies it by its actual `lib/<abi>/` contents;
- places `armeabi-v7a` APKs in the phone shelf and `arm64-v8a` APKs in the tablet shelf;
- places APKs with no native libraries in both shelves;
- finds the newest release containing a standalone `.dex` asset and copies valid DEX bytes into the DEX shelf.

Some direct DEX products are shipped inside release archives rather than as standalone assets. The optional `dex_archive_repositories` input is a separate repository list for those producers. Only their `.zip`, `.tar.gz`, and `.tgz` release assets are downloaded and inspected for `.dex` members.

A consumer may also supply `supplemental_apks` plus `supplemental_apk_root` for installable APKs that do not have durable GitHub releases, such as an exact CI artifact retained in the consumer repository. The supplemental TSV uses the same APK manifest schema as the output. The collector verifies each declared file's ZIP structure, SHA-256, byte count, and observed ABI set before copying it to the appropriate device shelves.

The action validates APK ZIP structure and the four-byte DEX magic. APK manifests record source repository, source kind/ref, asset name, checked-in filename, SHA-256, byte count, ABI information, and source URL. The DEX manifest additionally records the archive member when a DEX was extracted from a release archive.

The consumer owns the Git commit. The action changes only the consumer working tree and reconstructs the three managed shelves from the current release population plus the declared supplemental APKs.

Collection proves artifact provenance and bytes only. It does not prove installation, replacement-update signing, launch, runtime behavior, emulator execution, or physical-device acceptance.

## Consumer example

```yaml
- uses: isomorphisms/ai-ci/release-shelf@FULL_40_HEX_COMMIT
  with:
    repositories: generated-release-repositories.txt
    dex_archive_repositories: android/dex-archive-repositories.txt
    supplemental_apks: android/apks/pinned-apks.tsv
    supplemental_apk_root: android/apks/pinned
    output_root: android
    phone_dir: apks/miro-a1
    tablet_dir: apks/tab-p10-row
    dex_dir: dex
    github_token: ${{ github.token }}
```

Pin a reviewed full commit SHA, not a branch or tag.
