# Current Android release shelf

This action collects current installable Android artifacts without treating collection as acceptance.

A consumer supplies a file containing one GitHub `owner/repository` per line. For each repository, the collector:

- finds the newest release containing APK assets;
- downloads those APKs unchanged;
- opens each APK as a ZIP and classifies it by its actual `lib/<abi>/` contents;
- places `armeabi-v7a` APKs in the phone shelf and `arm64-v8a` APKs in the tablet shelf;
- places APKs with no native libraries in both shelves;
- finds the newest release containing a standalone `.dex` asset and copies valid DEX bytes into the general DEX shelf.

Some direct DEX products are shipped inside release archives rather than as standalone assets. The optional `dex_archive_repositories` input is a separate repository list for those producers. Only their `.zip`, `.tar.gz`, and `.tgz` release assets are downloaded and inspected for `.dex` members.

The action validates APK ZIP structure and the four-byte DEX magic. It records source repository, release tag, asset/member, SHA-256, byte count, ABI information, and source URL in TSV manifests.

The consumer owns the Git commit. The action only changes the working tree. Existing files not named by the previous release manifest are preserved, which lets a consumer retain a separately sourced CI artifact without having the release refresh erase it.

Collection proves artifact provenance and bytes only. It does not prove installation, replacement-update signing, launch, runtime behavior, emulator execution, or physical-device acceptance.

## Consumer example

```yaml
- uses: isomorphisms/ai-ci/release-shelf@FULL_40_HEX_COMMIT
  with:
    repositories: android/release-repositories.txt
    dex_archive_repositories: android/dex-archive-repositories.txt
    output_root: android/apks
    github_token: ${{ github.token }}
```

Pin a reviewed full commit SHA, not a branch or tag.
