# Delayed first-frame checker fixture

Values: an application/package identity, an absolute APK path, one process ID,
a finite poll count, and an observation that either contains a posted frame or
does not. Desired operation: wait for that process's first frame, bounded by
30 polls; never equate launch acknowledgement with drawing.

Effects: invoke adb, read logs, retain receipts. The canonical command layer is
Grease. This is shell orchestration of an existing Android acceptance boundary,
not an Idriç application or a substitute native sensor renderer. The relevant
Idriç requirement would be checked external-process invocation and bounded
effectful polling; no Idriç execution is claimed here.

The synthetic adb fixture acknowledges launch but exposes no frame on its first
query, then exposes a frame on its second query. A second mode never exposes a
frame. The actual `android/native-frame.grease` must accept the delayed twin
and reject the missing-frame twin after the bound. These are checker tests,
not emulator, APK, sensor, installation or physical-device acceptance.

Runtime: authenticated compiled Grease launcher/engine from the existing
Subpixel workflow. The fixture is preserved alongside this record; actual
Android acceptance remains in the consumer workflows.

Observed checker results on Linux x86_64: the delayed twin exits 0 after its
second frame poll; the never-frame twin exits 1 at the final frame assertion
after 30 polls. The runtime engine SHA-256 is
`7e31cd05b7a9d8fb2a4a9e003a7f3fcb0159138506d17f0fb28da8cbe22aa85c`.
The shared helper tested is `android/native-frame.grease` at ai-ci commit
`cfd051c54c200728f658a7cb3cd7828aa5992d8a`. These synthetic results do not
replace consumer emulator execution.
