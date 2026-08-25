# Chez / Termux source-compatibility failure, 2026-08-25

## Incident

After the first Chez/Termux build-script failure was traced to an abbreviated
Git object prefix used as a remote fetch source, a replacement script switched
to the upstream `main` branch and asserted that the ARMv7 naming cleanup was
already merged and usable.

Source acquisition then succeeded, but the build failed with:

```text
building boot files for tarmv7le using pb
missing input file: "s/armv7.def"
...
make: *** [Makefile:8: build] Error 1
```

The upstream ARMv7 rename had changed build-system references from `arm7` to
`armv7`, but the corresponding source file was still named `s/arm7.def` in the
merged tree. The follow-up upstream change is literally a rename of
`s/arm7.def` to `s/armv7.def`, with the maintainer noting that it should have
been part of the previous rename.

## Immediate technical cause

The replacement script acquired a source tree whose build metadata expected:

```text
s/armv7.def
```

while the exact merged source tree still contained:

```text
s/arm7.def
```

The failure was therefore not an ARM compiler problem, a Termux peculiarity, or
a difficult runtime bug. It was a source-tree coherence error that could have
been detected without Clang, LLVM, the NDK sysroot, or an ARM device.

## What went wrong in the reasoning

### 1. Merge status was treated as build evidence

Knowing that a PR was merged established that its listed changes entered the
repository. It did not establish that the resulting tree contained every file
required by the renamed machine type.

A merged change and a coherent build input tree are different propositions.

### 2. Diff inspection replaced exact-tree inspection

The relevant rename PR visibly changed references in `configure`, build logic,
tests, and machine-type tables. That made the rename look complete. But the
cheap decisive question was simply whether the exact revision contained
`s/armv7.def`.

The script was presented before that question was answered.

### 3. A mutable branch was substituted for the revision that had been reasoned about

The replacement used a shallow clone of `main` rather than resolving the
validated source to a full immutable revision and building that exact revision.
This weakened the first incident's own lesson: evidence about a source revision
must be bound to the revision later built.

When correctness depends on a recent upstream fix, `main` is not a sufficient
identity.

### 4. Source acquisition preflight was necessary but not sufficient

The first regression correctly required proving that the source could be
resolved and acquired before heavyweight mutation. This second failure shows a
second cheap boundary:

**source compatibility preflight**

> Before expensive mutation, prove that the exact acquired revision satisfies
> cheap build-specific invariants that can be checked without the heavyweight
> toolchain.

Examples include:

- required generated or handwritten input files exist;
- renamed files and renamed build references agree;
- expected submodules are present;
- configuration-selected machine definitions exist;
- a cheap configure or manifest check succeeds;
- a patch that the proposed build relies on is actually present in the exact
  tree being built.

### 5. Repository regressions do not help unless the answer path is held to them

The first ai-ci regression was already being created while the second script
was produced. Merely having a regression in a repository does not constrain an
assistant response unless the response-generation process actually applies the
same contract.

The operational rule therefore has to be simple enough to apply before a
ready-to-paste script is emitted:

1. resolve source;
2. bind it to a full immutable revision;
3. probe cheap build-specific source invariants at that revision;
4. only then perform heavyweight mutation;
5. acquire/build the same revision;
6. run the target acceptance test.

## Executable regression

The build-preflight fixture now contains two deterministic source revisions:

- `refs/tags/broken`: the build references have conceptually moved to `armv7`,
  but the source file remains `s/arm7.def`;
- `refs/tags/verified`: the source file is correctly named `s/armv7.def`.

The fixture executes this cheap source-tree probe against the fetched revision:

```text
git cat-file -e FETCH_HEAD:s/armv7.def
```

The oracle now requires a successful `source-compatibility` event, bound to the
same full source revision as source resolution, before heavyweight mutation.

New exact diagnostics are:

```text
BUILD-PREFLIGHT-MUTATION-BEFORE-COMPATIBILITY
BUILD-PREFLIGHT-SOURCE-INCOMPATIBLE
BUILD-PREFLIGHT-SOURCE-COMPATIBILITY-UNVERIFIED
```

The paired good fixture must still proceed through mutation, acquisition, and
build at the identical immutable revision, so the rule cannot pass merely by
rejecting all external builds.

## Rule for user-facing build scripts

A build/install script should not be described as ready to paste merely because
its commands look plausible or the relevant upstream PR is merged.

For cheap facts that can be established off-device, the user's machine must not
be the first verifier.

In particular, before a resource-constrained device installs a heavyweight
build toolchain, require evidence for all of the following that apply:

1. the exact acquisition command works;
2. the source resolves to a full immutable revision;
3. required build inputs exist at that revision;
4. claimed renames or patches are actually reflected in the source tree;
5. the later build is bound to the same revision;
6. target-specific uncertainty that cannot be tested elsewhere is isolated and
   stated explicitly instead of being hidden behind script complexity.

## Closure rule

Do not close this second incident merely because the corrected Chez script
works.

Close it only when the executable regression family:

- rejects heavyweight mutation after source resolution but before compatibility
  validation;
- rejects the source tree with `s/arm7.def` when the build requires
  `s/armv7.def`;
- passes the corrected source-tree control;
- binds source resolution, compatibility evidence, acquisition, and build to the
  same full immutable revision;
- records both mutation-before-source and mutation-before-compatibility; and
- runs in repository CI.
