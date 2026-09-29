# Operational host-context gate

This gate prevents an operational handoff from silently inventing facts about
the machine on which its commands will run.

It is intentionally not a universal package installer and does not maintain a
database claiming how to install every command on every operating system.

## Evidence model

The verifier consumes an ordered TSV trace:

```text
event<TAB>status<TAB>host<TAB>role<TAB>subject<TAB>value<TAB>evidence
```

Supported events record:

- host roles: execution, source, destination, build;
- execution-host OS and architecture;
- command presence;
- command acquisition;
- command installation;
- command use;
- credential presence/use;
- transfers between source and destination hosts.

Evidence provenance must begin with one of:

- `observed:` — directly measured on the relevant host;
- `declared:human:` — explicitly supplied by the human;
- `declared:receipt:` — supplied by a machine receipt whose provenance is
  handled by the surrounding workflow;
- `declared:reviewed-source:` — taken from a source explicitly reviewed for
  this host/acquisition claim.

A generic model-authored `declared:` string is rejected.

## What the gate enforces

- An execution host must be identified.
- Its OS and architecture need positive evidence.
- A command cannot be used before an observed `command -v`-style presence
  check says it is present and records what name/path resolution actually won.
- An absent command cannot be installed until acquisition is separately marked
  `proven-for-host`, with OS, architecture, and release already established.
- After installation, the command must be re-probed before use.
- A credential path cannot be used before it is observed readable.
- Transfer source and destination roles must already be established.
- A source-to-itself transfer is rejected unless the human explicitly declared
  that self-transfer is required.

## Live probe

`probe.sh` emits only facts it can directly observe without mutation:

```sh
sh host-context/probe.sh HOST gh git scp > host-context.tsv
```

It records `uname -s`, `uname -m`, `uname -r`, and command resolution/presence. It does not infer
a package manager or an installation recipe for an absent command.

Consumers may append reviewed/declarative rows for source/destination roles,
acquisition, credentials, and intended operations, then run the verifier.

## Verification

Build once on the verifier host:

```sh
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 \
  src/aici_host_context.c -o aici-host-context
```

Then:

```sh
./aici-host-context check host-context.tsv
```

GitHub consumers can use the local composite action in this directory with a
trace file.

## Boundary

This gate checks the trace semantics mechanically; it cannot by itself prove
that a dishonest producer did not fabricate an `observed:` row. Strong
consumers should generate observed rows on the execution host and bind the
trace to the command/execution receipt. A follow-up adversarial audit tracks
that remaining trust boundary rather than treating this first implementation as
complete.
