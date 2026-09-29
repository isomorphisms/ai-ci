# Host-context execution control

Two interfaces now have deliberately different evidence claims:

| Interface | What it does | What success proves |
| --- | --- | --- |
| `execute.sh` / `./host-context/execute` | Measures this host, checks a request, launches it, waits, and writes a new receipt | The recorded direct child returned zero after the recorded checks; not application correctness |
| `src/aici_host_context.c` / legacy `./host-context` action | Checks the consistency of an externally supplied TSV history | Only that the supplied history satisfies the auditor's predicates |

**A caller-written history cannot authorize execution.** The executor has no
`--trace`, `--observed`, `--install`, or `--skip-preflight` input. A request
contains intentions (argv and expected constraints), not facts about the host.

## One path from request to result

`execute.sh` runs as a separate noninteractive POSIX shell process. It:

1. Creates a new receipt, mode 0600, refusing an existing path. A receipt-open
   failure stops before the requested operation. Receipt creation is the
   intentional evidence-file mutation before preflight.
2. Resolves its own probe dependencies from the current PATH. It never guesses
   PATH defaults or installs missing helpers. Empty/relative PATH components,
   aliases, functions, and builtins are not accepted as executable resolution.
3. Actually runs `uname -s/-m/-r/-n`, `id -u`, and `pwd -P`; records those facts,
   PATH, and the resolved probe paths. Expected OS and architecture are checked
   against measurements; optional release, node, uid and cwd constraints also
   fail closed.
4. Validates the text request and captures argv in this process. Resolves the
   program to an absolute executable path. An absent program produces
   `HC-COMMAND`, not an inferred package-manager or installer operation.
5. Records the exact captured arguments; invokes that resolved path with those
   same arguments, without evaluating a shell command string supplied as data.
6. Closes the journal descriptor in the child, gives it noninteractive input,
   waits for its actual exit status, and records success, failure or interruption.
   Child output saying `PASS` has no influence on the decision.

The runner depends on a trusted POSIX shell and executable `uname`, `id`, and
`od`. `od` checks the bounded request for NUL bytes before shell text parsing.
Missing dependencies are a blocked result, not permission to bootstrap a
compiler or guess an installation method. No new compiler stage is introduced.

Invoke it as a script, not with `source` or `.`. Start the supervising shell with
`ENV` and `BASH_ENV` empty to avoid user startup scripts running before it.
The supplied action does that. Existing shell options in the caller are not
changed by the executor.

## Request format

A request is a regular text file: the first line is the program, subsequent
lines are individual arguments. Empty argument lines are meaningful. Spaces,
quotes, dollar signs, semicolons and Unicode are literal data. Version 1 rejects
NUL, CR and TAB, limits the file to 65,536 bytes, each argument to 16,384 shell
characters, and argv to 256 entries. Embedded newlines cannot be represented as
one argument by this format. Do not put secrets in argv; use an appropriate
private input mechanism in the application instead.

Example **on a host whose Linux/x86_64 identity has already been established**:

```sh
# Both paths must be explicitly selected, absolute, and under an existing directory.
printf '%s\n' gh --version > "$REQUEST"
ENV= BASH_ENV= /bin/sh host-context/execute.sh \
  --request "$REQUEST" --receipt "$NEW_RECEIPT" \
  --expect-os Linux --expect-arch x86_64
```

The example does not assert that `gh` exists. The runner checks it and stops
without installation when absent. `--expect-node`, `--expect-uid`,
`--expect-release`, and `--expect-cwd` add exact constraints when material.
Omitting a constraint never establishes its expected value.

For GitHub, use `./host-context/execute` (or the matching remote action pinned
to an accepted revision). All inputs are passed through environment variables
and quoted argv, never interpolated into executable shell text. The executor
returns the child's status; preflight rejection returns 125. An opened receipt
without a final outcome is incomplete, never success. Some failures before the
receipt opens have only a failing exit status and stderr diagnostic.

## Tests and evidence

`ENV= BASH_ENV= /bin/sh host-context/tests/executor.sh` exercises real child
processes. It checks both sides of the boundary: successful effects/byte-exact
argument delivery, and absence of a child effect on blocked requests. It tests
missing gh with fake apt/pkg/brew launch sentinels, wrong host constraints,
invented trace/installer inputs, malformed requests, receipt reuse/symlinks,
forged success on stdout, and the private journal descriptor.

`.github/workflows/host-context-executor.yml` runs the same tests under Linux
sh, Bash, and a NetBSD 11 VM. Its action integration requests a real directory
creation and independently checks the directory and the executor's receipt.
Tests that haven't run successfully on an exact revision remain unverified.

## Limits that must not be promoted into guarantees

This is a **trusted local direct-child supervisor, not a security sandbox**.
An agent with arbitrary same-user filesystem/process access can still edit
scripts or receipts, replace probe executables, bypass the runner, or execute
commands through other channels. Mode 0600 and closing a descriptor do not
protect against a hostile process running as that same user.

The captured absolute path is not an open executable descriptor or a hash of
its bytes. Renames, changes to symlink targets, libraries/interpreters, mutable
input files, PATH-dependent descendants and executable replacement remain
races or unverified dependencies. The shell's native exec/script semantics
still apply. Explicitly requesting `sh`, `grease`, a script or another program
that starts children does NOT mean their internal commands were supervised.
Signals are forwarded to the direct child; process trees and per-operation
timeouts are not implemented. A killed runner has no completion receipt.

The node name is an observation, not a hardware or cryptographic identity.
Exit zero is not proof of authentication, permissions, a working remote
endpoint, successful semantic work, or a valid acquisition recipe. Generic
`run` can perform effects requested by its program; it is not a whitelist of
safe commands. No remote-transfer, credential-validation, or installation
adapter is implemented. Old receipts are never read back to avoid a new probe.

AICI's own action integration is wired. Cat Food and other operational callers
must still adopt the new interface explicitly; no claim of universal
consumer enforcement or automatic ChatGPT enforcement is made.

Keep #176 and #179 open. Their remaining work includes independent execution
isolation, exact executable/plan binding, readiness adapters, stale acquisition
proofs, hidden descendants, and bypass-resistant consumer wiring.
