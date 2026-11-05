# Observe a new kernel after requesting reboot

Pasteboard source29d6a7a1dbad2dea7d577a710869757d8f8b9752 passes both-API
charcoal lifecycle acceptance. Its separate API35 workflow41978032646 fails at
the post-reboot launch with Activity-not-found. The old acceptance requests
reboot, waits for a connected transport, and accepts sys.boot_completed=1.
The old kernel may still answer both commands before disconnecting. This is a
source-level false-acceptance path; its responsibility for the captured failure
remains a hypothesis until fresh scoped execution supplies the boot identities.

The retained type boundary is previous UUID × observed UUID × completion text →
verified fresh boot or a specific refusal. The generic bounded Grease observer
captures actual kernel UUIDs, requires a different valid identity plus completed
Android boot, and refuses physical devices before rebooting. It records every
transport/readiness attempt. It never reinstalls the app, recreates history or
turns a failed launch into a pass.

Positive and stale-old-complete, new-but-incomplete and malformed-ID controls
exercise the real predicate. They are synthetic oracle fixtures, never evidence
of Android execution. Actual API29/API34/API35 reboot qualification remains a
separate hosted job, followed by the real Pasteboard retained-history comparison.
Grease is the existing process/file/ADB orchestration authority; no Python,
JavaScript helper, alternate runtime or candidate UI is introduced.
