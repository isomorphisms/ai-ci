# Recover transport between completed reboot and UI acceptance

Run43786811357 at 4a127a0251bdbd69283d7116cb7deed446560402 passes API29
and API34. API35 completes the real clipboard controls, server restart,
fresh-kernel reboot and exact history comparison, then reports `device offline`
at observe-ui.grease's initial emulator-identity check. The failed boundary is
transport readiness between stages; no application failure is established.

The saved run-suite.patch supplies a bounded recovery idea, but resolves its new
helper under the producer workspace rather than the independent observer. The
maintained helper belongs next to the observer and is invoked through that
existing absolute observer path. It also checks the exact kernel UUID already
accepted by control-evidence/reboot/after.txt, so another boot cannot silently
satisfy recovery. It never requests a reboot or changes the emulator/app state.

The Grease boundary is ADB path, serial, API, accepted kernel-identity file and
fresh output directory to a transport-readiness receipt or refusal. A bounded
optional attempt count allows fast hostile-fixture execution; production uses
60 attempts. Two consecutive complete identity samples are always required.
The fixed Android shell probe is the ADB command interface; it does not require
a Grease runtime on Android. Process execution, bounded timeouts and evidence
files remain owned by the established Grease controller. No second clipboard
model or Idriç semantic program is needed.

Controls must reject wrong API, non-emulator context, root/wrong UID, incomplete
boot, changed kernel, duplicate fields, failed probe despite plausible stdout,
and exhausted transport. They must demonstrate that an offline sample resets
the two-sample requirement. Parser/transport fixtures are host evidence only;
the complete unchanged signed APK and compiled Idriç oracle still need fresh
API29/34/35 execution. Physical C67 and Shizuku autostart remain separate.

Host validation through the exact maintained native Grease engine passes all
thirteen transport cases: two positive sequences and eleven refusal sequences.
The original listener-identity fixture suite also passes unchanged. The first
host attempt exposed Grease's explicit environment access: `$PATH` is not an
implicit shell variable, so the fixture now reads ENV.PATH before constructing
the child process environment. That failed fixture setup did not execute the
recovery helper and is not counted as a transport failure or pass.
