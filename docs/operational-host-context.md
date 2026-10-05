# Operational host-context preflight

Operational instructions are executable claims about a specific environment.
Before an agent gives, accepts, or runs a command whose correctness depends on
host facts, it must bind the command to the environment in which that command
will execute.

This protocol applies to shell commands, build/install instructions, remote
copy/login commands, package-manager use, filesystem paths, device commands,
and other environment-sensitive operations.

## 1. Name the execution host

Keep these roles distinct:

- **execution host**: the machine on which the next command actually runs;
- **source host**: the machine that currently holds an input or artifact;
- **destination host**: the machine intended to receive or execute it;
- **build host**: the machine that produced an artifact, when different.

A visible prompt, direct system probe, connected-machine receipt, or explicit
human statement may establish a host role. Do not silently replace that evidence
with a familiar development-machine assumption.

If execution host and destination host are the same machine, do not introduce
an SSH/SCP hop from that machine back to itself unless the task explicitly needs
that loop.

## 2. Classify material environment facts

For every fact needed by the proposed command, classify it as one of:

- **observed**: directly measured in the current execution environment;
- **declared**: explicitly supplied by the human or a trusted machine receipt;
- **unknown**: neither observed nor declared.

Material facts commonly include:

- operating system and release;
- architecture;
- command availability;
- package manager;
- filesystem/path namespace;
- writable/executable locations;
- credentials or key paths;
- network reachability;
- current repository/worktree location.

A direct operational step may rely on observed or declared facts. Unknown facts
must be probed cheaply before mutation, or the command must fail closed before
using them.

## 3. Require positive platform evidence

Do not classify a platform from the absence of some other platform marker.

Bad:

```text
not Termux -> cloud
not Android -> Linux
not Windows -> POSIX target X
```

Good:

```text
uname / os-release / explicit target receipt -> supported target
otherwise -> unknown or unsupported
```

A catch-all branch may select `unknown`; it must not silently select a platform
whose implementation assumes a particular kernel, libc, distribution, package
manager, directory layout, or privilege model.

## 4. Prove commands before depending on them

Do not assume `gh`, `git`, `scp`, `rsync`, a compiler, a package manager,
or any other non-shell command exists merely because it is convenient.

Track **presence** and **acquisition** separately for every material external
command.

Command presence is one of:

- **observed-present**: the execution host directly proved the command runnable;
- **observed-absent**: the execution host directly proved it unavailable;
- **unknown**: no direct host evidence exists.

Command acquisition is one of:

- **not-needed**: the command is observed-present;
- **proven-for-host**: an installation/acquisition path is established for the
  exact relevant host facts and required privilege model;
- **unknown**: no such path has been established;
- **unsupported**: evidence shows that the proposed acquisition path does not
  apply to this host.

These are independent claims. Discovering that `gh` is absent does not imply
that `apt install gh`, `pkg install gh`, `brew install gh`, downloading a
binary, or any other acquisition method is valid.

When a command is material to a handoff, either:

1. use direct evidence that it is present on the execution host, including what `command -v` resolved; or
2. make a cheap availability probe the first operation and fail before mutation
   if the probe fails; or
3. choose a path that does not require that command.

If the command is absent and acquisition is unknown, stop at that boundary or
use another already-supported mechanism. Do **not** invent an installer.

An installation recipe is itself an environment-sensitive operational claim.
Before prescribing it, establish the material host facts it depends on, such as
OS, release, architecture, package manager or binary format, network source,
write/privilege requirements, and target path. A `proven-for-host` acquisition
claim is invalid until OS, architecture, and release have positive evidence.
Do not infer a package manager from the operating system name alone.

A later failure such as `command not found` is evidence that the presence
preflight was missing. A later `package not found`, wrong-architecture binary,
permission failure, or unsupported installer is evidence that acquisition was
claimed without sufficient host evidence.

## 5. Do not invent paths or credentials

A path from one machine is not evidence for the same path on another machine.
This rule applies especially to:

- SSH private keys;
- repository checkouts;
- artifact download directories;
- `/opt`, `$HOME/opt`, Android shared storage, and removable media;
- package-manager prefixes;
- device nodes and sockets.

Never assume a credential path such as `~/.ssh/id_ed25519` without direct
evidence. Prefer an already established connection or a command that leaves
credential selection to the host's configured client when that satisfies the
task.

## 6. Preflight before cost or mutation

Cheap context probes must precede expensive or state-changing work.

Examples:

```sh
uname -s
uname -m
command -v required-command
test -r required-input
test -w required-destination
```

Use platform-appropriate probes rather than blindly emitting these exact
commands on every system.

Do not install packages, compile a large tree, overwrite files, transfer a large
artifact, or alter remote state until the environment facts required for that
step have passed preflight.

## 7. Preserve host roles across a multi-machine handoff

A handoff must remain legible as a sequence of machine-local operations.

For example:

```text
workstation: obtain artifact
workstation -> SDF: transfer artifact
SDF: install artifact
SDF: execute benchmark
```

If the human is already on SDF, begin from the SDF-local state. Do not replay
the workstation-to-SDF transfer step unless the artifact still lives only on the
workstation and the human explicitly asks for that transfer path.

## 8. Evidence boundary

A successful build for an operating system proves neither:

- that the binary already exists on another host;
- that the host has a tool used to retrieve the artifact;
- that a transfer credential exists at a guessed path;
- nor that an instruction block was executed from the machine assumed by the
  author.

Keep build, artifact acquisition, transfer, installation, and execution as
separate evidence stages.

## Regression requirement

AICI semantic evaluations must include paired cases that reject:

- NetBSD inferred as Debian/Ubuntu from a negative catch-all;
- an unavailable command assumed present;
- a source/destination self-transfer introduced by host-role confusion;
- an unverified credential path;

and accept an answerable twin whose execution host, required command, credential
source, and distinct destination are all established.

The observed SDF incident is tracked by issue #176.
