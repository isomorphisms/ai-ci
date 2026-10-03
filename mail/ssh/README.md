# SSH contract and deterministic server plan

The pinned original provides separate transport, host-key, authentication,
channel, data, EOF and exit-status operations. `ssh-*` corpus cases exercise
observable state/byte receipts through `ssh-model`. They are not encrypted wire
tests. Real issh adapters and server-controller integration remain NOT_RUN.

## Local fixture configuration

Use a loopback OpenSSH server in an isolated disposable host/container, bound
only to 127.0.0.1 on a dynamically selected unprivileged port. Pin the server
package/container digest and record `sshd` executable hash/configuration. Generate
two ephemeral host keys and one client key in a private temporary directory;
commit no private keys. The controller owns the trust file, authorized key,
failure injection and independent event log. Disable password authentication,
forwarding, agent forwarding, PTY allocation and unrelated subsystems. Enable
internal-sftp only for the retained SFTP lane. Test legacy SCP separately from
modern OpenSSH scp's default SFTP behavior.

For the success command, use `fixture_command.c`: stdout is six octets
`00 4f 55 54 0a ff`, stderr is five octets `45 52 52 0d 0a`, and exit status is
23. Compare those streams independently. The synthetic file is eleven octets
`00 ff 0d 0a 46 72 6f 6d 20 78 0a`. Adapter stdout/stderr are only diagnostics;
they must not be confused with these remote command streams.

## Required live scenarios

| Scenario | Controller action and independent observation |
| --- | --- |
| Lifecycle | Start server, connect, negotiate, verify host, authenticate, open channel, execute, drain both streams, observe EOF, collect status, close and release resources |
| Host conflict | Reuse hostname/port trust entry while serving the other key; assert no authentication or command event reaches the server |
| Missing host trust | Empty trust store; no automatic acceptance or write-back of the unknown key |
| Authentication failure | Wrong public key and unknown user; no successful channel/command |
| Negotiation failure | Disjoint supported algorithm sets; explicit setup failure, no auth success |
| Channel denial | Auth succeeds but server refuses session channel; command absent |
| Setup close | Close server connection before banner or during key exchange; setup failure |
| Short reads / would-block | Fragment/restrict transport and alternate idle readiness; preserve payload exactly |
| Abrupt close | Kill connection after a recorded byte count before orderly channel EOF; result remains incomplete/error |
| EOF vs exit | Complete stream with exit 23; success at reading does not imply command success |
| Extended data | Interleave stderr and stdout; require both streams separately, without assuming inter-stream total order |
| SFTP and SCP | Stream the synthetic file with short reads; missing file, denied access and interrupted transfer fail distinctly |

Record negotiated methods where observable without imposing algorithms absent
from a selected retained backend. Include rekey and flow-control/window pressure
as follow-up cases once the adapter exposes their control points. Keep callback,
platform, and backend differences explicit. The complete upstream libssh2 tests
remain upstream obligations; this set compares the mail-relevant observable
contract across translations.

The current mutation receipt proves the observation checker rejects host trust,
auth-stage, status and stream corruption. It does **not** prove a library really
verified a host key. That requires the live server's independent no-auth/no-exec
witness in the conflicting-key scenario.
