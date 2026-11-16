# Separate installed ownership from the worker's effective calling identity

Pasteboard source ae857b6178c1a8e3a7887574122fa3d9661eeb0e authenticates the
installed app owner in ClipboardObserver.onTransact, then calls
Binder.clearCallingIdentity before start_listener. The listener therefore logs
caller_uid=2000. The prior readiness observer required caller_uid to equal the
installed app UID and fabricated that identity in its positive fixture.

The corrected predicate still requires one current app process, one shell
worker, one installed package UID, an accepted code=1 current-epoch connection,
and actual listener registration or retained configuration. It now separately
requires successful worker initialization with owner equal to the installed app
UID and actual/shell UIDs both 2000. The listener caller must be 2000.
An accepted disconnect callback is not a connection.

The existing Grease input/output boundary remains three bounded process,
package-owner and log snapshots to either a nonzero refusal or plain TSV
identity evidence. No new Idriç or clipboard-state model is introduced. The
app's authorization and checked history reducer are unchanged.

## Host validation and retained emulator logs

The real Grease entrypoint runs Oils source
5651cf97a1b5042f24f14112a7ade9a1518eb0bc through native engine SHA-256
7e31cd05b7a9d8fb2a4a9e003a7f3fcb0159138506d17f0fb28da8cbe22aa85c.
ASAN_OPTIONS=detect_leaks=0 matches the maintained workflow; this host's process
tracing prevents LeakSanitizer startup otherwise.

Two synthetic positive cases (registered and retained) pass, and all twelve
targeted negative cases are rejected. These checks execute qualify.grease;
their scope is parsing and identity admission.

The unchanged retained snapshots from
[run42027659494](https://github.com/isomorphisms/ai-ci/actions/runs/42027659494)
also demonstrate the false rejection. For each artifact, use the three files
under ai-ci/ai-ci/producer/build/control-evidence named
after-server-restored.readiness.processes.txt,
after-server-restored.uid.txt and
after-server-restored.readiness.logcat.txt. The original observer at
91d31fef0fdb71787fc1777a6edb44361d88d9f5 exits 1 on all three; the corrected
observer exits 0 with these exact process identities:

| API | Artifact | App PID | Worker PID | Installed app UID |
| --- | --- | --- | --- | --- |
| 29 | 13415515973 | 9235 | 9799 | 10146 |
| 34 | 13415715705 | 8408 | 8834 | 10192 |
| 35 | 13414897906 | 6348 | 6775 | 10209 |

The ZIP SHA-256 values, checked against GitHub's artifact metadata, are:

- API29: df1f74ab36c98eac716df9d5c405d20f13a5fa466e08b7a0db3ea79fec5fa8f4
- API34: ac32123e221d6a7a96883c0bf87a37f0333dc86ea9df50ca20f4845a392fca9a
- API35: 6c105c59393960c92e7cccdd12c2d86b969a298e5e965f1e3315ed7a2acb40e6

This is an offline replay of retained emulator evidence. It does not qualify a
fresh server restart, A/B/C delivery after readiness, complete UI workflow,
physical C67 behavior or Shizuku autostart. All existing full-suite assertions
remain required. The earlier separate official-manager handshake failure is
not declared repaired.

## Exact runtime renewal

Artifact13062637698 is no longer listed by Grease producer run41253994123.
That run now provides artifact14161714564 from the same producer source
6d19932f7a63faf38444bd3693aa61304f061fda. Its ZIP SHA-256 is
f98957b49cde40f9a2ef10dc70fe4bbd67893d73fd23b4b0f5ec3f6d97af8ae4;
the included native engine exactly matches the unchanged SHA-256 above.
The workflow renews that artifact ID and retains its pinned canonical-launcher
helper and native-engine digest requirement. No consumer/oracle rebuild or
alternate shell is used.
