# Installed native Shizuku client acceptance

This independent instrumentation runs against the installed checked IB Activity
and its native platform adapter. Candidate classes remain compiler-generated;
the small observer alone is assembled from smali. It verifies an actual emulator,
the declared API/ABI, official Shizuku release bytes and signer, then installs
without uninstalling or clearing data. The same UID and signed APK byte readback
are required after every replacement.

The official Shizuku server owns real Binder delivery, attachment, permission UI
and permission queries. The observer clicks the checked Activity's native
controls, denies and grants through the real manager, stops that isolated
emulator server and checks revocation and reconnection. An unrelated application
UID must fail Android's provider permission guard. A separate well-formed fake
peer is used only to reject an ordinary app's delivery attempt before the server
starts. It is never counted as Shizuku authorization. Compiled UID-bypass and
death-no-op candidates must fail their specific independent expectations.

The fixed kill command is confined to a fresh, independently identified emulator.
These controls do not launch Grease/ICU, publish source, render a document, prove
retained-source update compatibility or establish physical TAB_P10 acceptance.
Synchronous SDK RPC timeout behavior also requires further qualification.
