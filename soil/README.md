# ai-ci Soil job acceptance

This action keeps Soil's useful build/test machinery and removes Soil's remote
publisher from the acceptance boundary.

A consumer checks out one exact Oils/Soil revision, then calls this action for
one named Soil job. The action binds execution to that exact revision, calls
`soil/github-actions.sh run-job`, and independently verifies Soil's local
commit record, job record, per-task `INDEX.tsv`, task logs, and
`_soil-jobs/JOB.status.txt`.

It never calls `publish-html`, `publish-and-exit`, or
`publish-cpp-tarball`. A publisher failure therefore cannot retroactively turn
a passed compiler or language test into a failed semantic check.

## Use

Pin ai-ci by a reviewed full commit SHA:

```yaml
- uses: isomorphisms/ai-ci/soil@0123456789abcdef0123456789abcdef01234567
  id: soil
  with:
    root: source-worktree
    job: cpp-spec
    expected_revision: 6d29702a10ea9eb72a43950554dbcd4174d07a89
    container: podman
```

The action emits a verified receipt path as `steps.<id>.outputs.receipt`.
Its receipt explicitly records `publisher	not_run`.

For independent jobs, use a GitHub Actions matrix. Soil jobs that exchange a
generated tarball or another artifact still need an explicit producer/consumer
handoff; this action does not recreate the upstream shared web server as hidden
transport.

## Evidence boundary

This proves that the named Soil job ran at the exact source revision and that
every recorded task completed with status zero. It does not prove publication,
deployment, installation, physical-device behavior, or a later consumer of a
generated artifact.

The immediate motivation was the September 18, 2026 Oils fork failure: the
substantive Soil jobs passed, while the upstream web publisher could not index
the fork's low GitHub run number and tarball publication separately required an
upstream SSH key.
