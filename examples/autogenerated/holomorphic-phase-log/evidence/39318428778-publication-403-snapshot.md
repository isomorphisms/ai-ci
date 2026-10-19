# Holomorphic qualification publication blocker

Status: **BLOCKED at publication**, snapshot 2026-10-19T21:03:05Z.
Repository/source files, credentials, rules, tags and releases were not changed
during this investigation.

The failed attempt is [run 39318428778, publication job 118303230931](https://github.com/isomorphismes/holomorphic/actions/runs/39318428778/job/118303230931).
It checked out the actual accepted source
`08f0e5ec9d377f1e38bca30f459101b9f19905ad` in
[isomorphismes/holomorphic PR #63, “Repair world-space divisors and verify the generated Holomorphic GPU path”](https://github.com/isomorphismes/holomorphic/pull/63).
The runner recorded `Actions: read` and `Contents: write`. At
2026-10-19T20:56:47.8314306Z, after the publisher's preceding APK, identity,
provenance and independent mathematical gates, its first release write failed:

```text
gh release create <source-and-APK-SHA-bound-tag> --repo isomorphismes/holomorphic --target 08f0e5ec9d377f1e38bca30f459101b9f19905ad --draft --prerelease ...
HTTP 403: Resource not accessible by integration (https://api.github.com/repos/isomorphismes/holomorphic/releases)
```

GitHub's current authoritative [Create a release documentation](https://docs.github.com/en/rest/releases/releases?apiVersion=latest#create-a-release)
states that a target whose `.github/workflows/` files differ from the default
branch requires workflow modification authority. It explicitly identifies
`403 Resource not accessible by integration` as one possible response and says
Actions' `GITHUB_TOKEN` cannot receive the required Workflows permission. The
[Update a release documentation](https://docs.github.com/en/rest/releases/releases?apiVersion=latest#update-a-release)
applies the same check to the resolved target.

The repository's default branch is `main`, observed at
`fcba8faa96f09efcd3db1f23039cee7feb00777e`. Exact-SHA Contents API reads confirm
the following workflow Git blobs:

| Workflow | Default `main` blob | `08f0e5ec` blob | Final `f2ef44e3` blob |
| --- | --- | --- | --- |
| `generated-holomorphic-apk.yml` | absent | `22785c741001360634cf3368c7ced5c2f3916adb` | `e912c4ebfd4f9d788a5a4a5f79722383a73d97a1` |
| `fdroid-build.yml` | `5dcda830c89ab3651e6e5c2d204b51af7c5385cf` | `532f766a6f3ea0df58af45a06d48c558ca404159` | same as `08f0e5ec` |
| `google-play.yml` | `8799b5b73ce59ee867fa8ceb3c0fc67b88150bd5` | `4bee4c669d3e7b16ecb1d4a33834907e7abf95e7` | same as `08f0e5ec` |
| `holomorphic-apk.yml` | `afda3f1f6ab919a26c0d9eb43b524f0d90fc8a9e` | `7b55b1ef52e90b552fe72a89c64c0711c68712f3` | same as `08f0e5ec` |
| `ick-compilers.yml` | `3d067073ff03faf5802f06f30e085591d94d3b6a` | `3660c603031e8b59f9bbb7553efeb21178b9b6a9` | same as `08f0e5ec` |
| `native-apk-release.yml` | `ad0df765c30963e14ff30f2bad5ed70f02c97cd2` | `f7993fee73cb1ac0a91b3a83634c43ee594beac7` | same as `08f0e5ec` |
| `tests.yml` | `461174b575df54b22c04bc881ca1184b204f0123` | unchanged | unchanged |

Thus both accepted/repaired source heads meet the documented workflow-difference
condition. The PR merge SHA versus actual source SHA distinction does not remove
this guard. A different trigger, checkout ref, additional `contents: write`, or
ordinary retry cannot supply the unavailable permission. Retargeting the release
to a merge/default SHA would break the source identity and is not a repair.

Read-only metadata additionally shows no `qualification-holomorphic-*` tag and
no qualification release. The only visible active ruleset is
[`protect-default-branch` #23719210](https://github.com/isomorphismes/holomorphic/rules/23719210),
targeting branches with `~DEFAULT_BRANCH`; it is not a qualification tag rule.

Latest exact source is `f2ef44e348bc37c90c1da951632c4fb1f5466c7d`,
[run 39319240088](https://github.com/isomorphismes/holomorphic/actions/runs/39319240088).
At this snapshot, checked host mathematics and all three Android compiler jobs
are PASS. Generated APK job `118305016491` is still running; its APK, emulator,
publication and Cat Food results are not yet final. Physical A1, C67, TAB_P10
and sustained performance remain NOT_RUN.

The supported publication routes require a separately authorized publisher
that already has the necessary workflow modification authority: an authorized
maintainer's existing release interface, or an approved existing workflow-capable
publisher. It must publish the unchanged signed qualification APK and exact
identity/acceptance receipt under the prescribed source-and-APK-SHA-bound tag,
then verify both public raw downloads before Cat Food acquisition. No credential
broadening, new secret, permission bypass, tag retargeting, policy change or
source change is proposed. The current Actions token cannot perform this
publication while the documented condition holds.

API evidence: [default branch](https://api.github.com/repos/isomorphismes/holomorphic/branches/main),
[default workflow blobs](https://api.github.com/repos/isomorphismes/holomorphic/contents/.github/workflows?ref=fcba8faa96f09efcd3db1f23039cee7feb00777e),
[failed-target workflow blobs](https://api.github.com/repos/isomorphismes/holomorphic/contents/.github/workflows?ref=08f0e5ec9d377f1e38bca30f459101b9f19905ad),
[final-target workflow blobs](https://api.github.com/repos/isomorphismes/holomorphic/contents/.github/workflows?ref=f2ef44e348bc37c90c1da951632c4fb1f5466c7d),
[qualification tags](https://api.github.com/repos/isomorphismes/holomorphic/git/matching-refs/tags/qualification-holomorphic-),
[releases](https://api.github.com/repos/isomorphismes/holomorphic/releases?per_page=100),
[ruleset](https://api.github.com/repos/isomorphismes/holomorphic/rulesets/23719210).
