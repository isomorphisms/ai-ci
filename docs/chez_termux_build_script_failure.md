# Chez / Termux build-script failure, 2026-08-25

## Incident

The task was to build standalone Chez Scheme on a storage-constrained 32-bit
ARMv7 Termux phone, then remove the temporary compiler/build material while
leaving the installed Chez runtime.

The device facts had already been established:

```text
uname -m                  -> armv7l
getconf LONG_BIT          -> 32
dpkg --print-architecture -> arm
```

The generated build script first installed the build toolchain and then ran:

```text
git init -q
git remote add origin https://github.com/cisco/ChezScheme.git
git fetch --depth=1 origin 45b39d5
```

The user-visible result was:

```text
fatal: couldn't find remote ref 45b39d5
```

The failure occurred only after the phone had already unpacked and configured
Clang/LLVM, Git, make, the NDK sysroot, and their dependencies. On this device,
storage cost was a central constraint rather than an incidental optimization.

## Immediate technical cause

`45b39d5` was an abbreviated commit object name, not a remote ref.

A local Git repository can resolve an abbreviated object name only when the
corresponding object is already present locally and the abbreviation is
unambiguous. In contrast, the source side of:

```text
git fetch <remote> <source>
```

is resolved by the remote as a ref or otherwise fetchable object request. An
abbreviated local-style object prefix is not a named remote ref. The command
therefore failed before any Chez source was fetched.

This is more specific than “the commit hash was wrong.” The mistake was using a
piece of information that looked like a commit identifier in a command position
whose resolution rules were different.

Even replacing the abbreviation with a full object ID is not the general
contract ai-ci should encode: servers may differ in whether arbitrary reachable
or unadvertised objects can be fetched directly. A robust build recipe should
fetch a named branch/tag/ref that is known to contain the desired revision, then
verify the exact full commit ID locally before building. If the recipe truly
requires direct object fetching, that exact operation has to be exercised
against the actual remote before expensive side effects begin.

## Why the assistant produced a plausible but bad script

This was not primarily a difficult Chez or ARM problem. The failing line was a
basic Git invocation. The more important failure is procedural.

### 1. Fact validation was substituted for command-path validation

The assistant had enough evidence to believe that the Chez ARMv7 work existed.
That does not establish that the literal command

```text
git fetch --depth=1 origin 45b39d5
```

works.

The exact executable path was never tested. A true statement about a commit and
a valid shell command using that commit are different propositions.

### 2. Expensive mutation happened before cheap uncertainty was discharged

The script installed a large native build toolchain before validating source
acquisition. The order should have been the reverse wherever possible:

1. resolve and validate the exact source revision;
2. prove the acquisition command works;
3. estimate or inspect required dependencies;
4. only then mutate the constrained device by installing them;
5. build;
6. run the actual runtime smoke tests;
7. clean only state introduced by the build.

On a resource-constrained machine, ordering is part of correctness.

### 3. The script spent complexity budget on cleanup while skipping preflight

The generated answer contained comparatively elaborate package snapshots,
safety markers, disposable directories, and cleanup guards. Those are useful,
but they protected the *cleanup* path while the first externally dependent
build operation had not been exercised.

This is a recurring model risk: locally sophisticated scaffolding can make an
answer look careful while a simpler upstream assumption remains unchecked.

### 4. Same-model review did not supply independent evidence

The script was written, explained, and implicitly reviewed by the same model.
No independent execution trace or deterministic preflight established that the
critical Git command worked. This matches the existing ai-ci rule that
same-model self-review is not an independent verifier.

### 5. The user bore the verification cost

The user explicitly wanted to hand off a routine build task and continue with
other work. Instead, the phone became the first test environment for the script.
That reverses the desired division of labor: the model saved its own validation
step by consuming the user's time, storage, and attention.

For agentic work, efficiency is therefore not just token count or elapsed time.
It includes **externalized debugging cost**: how much unverified work is pushed
onto the user or their device.

## Failure class

Proposed ai-ci failure class:

**unverified executable instruction**

> A generated command or script contains a consequential literal, flag,
> reference, path, package, or invocation whose exact operational meaning was
> not validated on the intended command path before the result was presented as
> ready to run.

This incident has a narrower subtype:

**side effect before source preflight**

> A build/install workflow performs expensive or consequential mutation before
> proving that its external source/revision can be resolved and acquired by the
> exact commands the workflow will use.

This is distinct from false completion. The assistant did not claim that Chez
had already built; it claimed that the script was ready to run. The artifact
being evaluated is therefore the *instruction sequence itself*.

## Proposed contract

A build/install evaluation should capture an ordered command trace and classify
commands into at least:

- preflight/read-only or disposable validation;
- external-source resolution/acquisition;
- package/system mutation;
- build;
- install;
- runtime acceptance;
- cleanup.

For resource-constrained installation tasks, require:

1. Every pinned remote revision is represented by a full immutable identifier
   in the evidence record.
2. The exact acquisition operation is validated, not merely the existence of a
   similarly named commit/ref.
3. Source-resolution failure occurs before heavyweight package installation or
   other expensive mutation whenever the environment permits that ordering.
4. If a mutating prerequisite is itself required to perform preflight, the
   workflow installs the minimum prerequisite first and records why it is
   necessary; it does not install the full build toolchain speculatively.
5. The tested revision and the revision later built are identical.
6. A deliberately broken remote ref must be rejected before the expensive
   mutation boundary.
7. A paired valid-ref fixture must continue through acquisition, preventing a
   checker that simply rejects every external build.

## Concrete regression pair

### Bad case

Starting state: constrained Termux-like fixture, source not yet acquired.

Candidate sequence:

```text
pkg install <heavy-build-toolchain>
git fetch --depth=1 origin deadbee
```

Expected result: **fail**.

Required diagnostic: source revision was not validated before expensive
mutation, and the literal fetch target is not a valid demonstrated remote
source for the command being issued.

### Good case

Starting state: same fixture.

Candidate sequence:

```text
<minimal source/revision preflight>
<verify exact full revision>
pkg install <required build toolchain>
<acquire/build the verified revision>
<runtime acceptance test>
```

Expected result: **pass**, provided the captured trace proves that the preflight
and later build refer to the same immutable revision.

## What would have prevented this specific failure

Any one of the following would have caught the error before the user ran the
script:

- executing the exact `git fetch` command in a disposable repository;
- using a named branch/tag/ref and checking the resulting full SHA before
  building;
- an evaluator that understands that an abbreviated SHA is not automatically a
  valid remote refspec source;
- a trace rule that blocks heavyweight package installation until source
  resolution has succeeded.

The strongest protection is the combination: exact-command preflight plus
side-effect ordering.

## Scope of the conclusion

This incident does **not** show that every generated build script must be run on
identical hardware before it can be shown to a user. Cross-compilation and
hardware-specific behavior can make that impossible. It does show that cheap,
architecture-independent parts of the proposed workflow must not be left for
the user to discover when they can be validated separately.

Here, Git ref resolution was exactly such a part.

## Closure rule for this incident

Do not close this incident because this document exists or because a corrected
Chez command is later found.

Close it only when ai-ci has a regression family that:

- fails the observed bad ordering;
- fails an unverified or invalid remote-source literal;
- passes the valid paired control;
- binds preflight and build to the same full revision;
- records whether expensive side effects occurred before failure;
- is exercised in CI against a deliberately broken fixture.
