# Repaired installed reader input

The installed replay previously consumed IB b75157e6, whose real Google
response failed in the original-octet traversal. The passing large-source
component alone cannot establish that a repaired installed Activity renders
that acquired response.

Freeze the unchanged signed candidate from IB
`966a613a79b2a5800c209298800678bd984d4966`, producer run 41315891303,
job 124875730013. Its API 29 and API 34 observer steps both completed
successfully. The uploaded archive is artifact 13088228711, 837240680 bytes,
SHA-256 `8de69e0bbf2e4a443cf5bc4a5f7296e25ea8f2a7a56bc298035947182f5f4de1`.
The source receipts, size and archive digest remain mandatory; no new APK is
assembled, signed or substituted by this replay.

The input type remains the existing immutable source-bound APK bundle. The
four existing jobs exercise actual installed Binder/ICU/Arena/navigation,
decoding, source clipboard, reflow, recovery and genuine ChordReader handoff
on fresh API 29/34 emulators, with the retained independent negative controls.
The SEARCH log and screenshot capture the actual checked-renderer outcome.
Handoff success or original-byte readback still does not establish usable
Google results or clicked-result navigation. Those remain separate assertions
to add only after observing the repaired application's actual response.

This branch isolates the installed input change from concurrent recursive
compiler replay in ai-ci PR #331. It extends the same maintained observer;
there is no copied parser, receiver, application, transport or store. The
later IB 569ad902 Unicode repair requires its own fresh candidate evidence.

Grease syntax and diff checks are local qualification. Fresh emulator replay
is NOT_RUN at authoring; all physical TAB_P10 acceptance remains BLOCKED.
