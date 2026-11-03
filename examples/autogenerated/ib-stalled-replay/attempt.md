# Stop two stalled current-emulator attempts for diagnosis and targeted retry

F43's producer and both required ART suites pass. At current observer ecea325a,
both full profiles, both lifecycle/link profiles, decoder29/34 and fragment29
pass. Only isolated fragment34/job125058071021 and search34/job125058070979
remain stalled beyond twenty minutes. GitHub's live decoded log endpoint
returns BlobNotFound until these attempts end.

This one-off Grease controller may cancel only runs41376593878/41376593837
at exact source ecea325a32d7d922540a51d6e460349d4d9fabef and branch
acceptance/ib-chordreader-handoff. It verifies that only the named job remains
active, no job is queued, and that the current step has exceeded1200 seconds.
Completed records are retained. Completed runs are skipped; another active
job/name/source or a shorter duration refuses cancellation. No source branch,
release, artifact or application data is changed.

Type sketch: fixed run identity + exact active job/name + measured stalled
duration -> stop request. This is CI process management, never acceptance.
Read the resulting actual logs before targeted reruns. The F43 APK and all
checks remain fixed. No physical device operation is attempted.
