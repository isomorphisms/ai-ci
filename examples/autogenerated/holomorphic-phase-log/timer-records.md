# Keep GPU timing separate from numerical observations

Holomorphic run41967292308 at product5025b41cea08b2f173eb54b9344819be7c82fc55
builds its checked shader and signed three-ABI APK, executes actual Android
GLES readbacks and passes source provenance. The independent checker then
crashes with KeyError:case on a real HOLO_GPU_TIMER metadata row. The emulator
reports the disjoint timing extension missing; that is not a numerical case.

Ignore only the explicitly separate HOLO_GPU_TIMER event in gpu_audit. It cannot
supply a required mathematical observation. Preserve every input, divisor,
measurement, colour, count, policy, tolerance and same-program requirement.
Unknown GPU events still fail, now before reading their case field.

The same actual native source emits HOLO_GPU_QUERY_WINDOW after every60 frames,
including a NOT_RUN record without the timing extension. The bounded streamed
capture retains those later records too. Recognize that exact periodic timing
event alongside HOLO_GPU_TIMER; neither may replace a mathematical observation.
The positive fixture includes both production-shaped timing records, and a
query-window-for-measurement mutant must fail for missing numerical output.

Extend the existing Ithon self-test with a valid corpus plus real-shaped timer
metadata, a timer-for-measurement replacement that must fail for missing numeric
output, and unknown metadata that must fail as an unexpected event. Existing
mathematical/provenance/precision mutants remain mandatory. This changes an
existing owned Ithon parser, not the shader or oracle mathematics; no Python
consumer source or alternate interpreter is introduced.

Actual retained runtime logs must be requalified with this exact checker. Timing
stays NOT_RUN on the captured emulator, and no physical timing or C67 acceptance
is inferred from successful numeric/colour qualification.

Local execution through Ithon d6e83969f82512e920fb17b44326cb54f31d015c passes the
complete checker self-test and new controls. Replaying the actual retained log
still rejects it: only33/34 numerical and33/34 colour rows are present, and the
separate large-q observations are incomplete. The parser repair does not turn
that real failure into a pass. A fresh complete actual capture is required;
reported OUTPUT_READY totals alone are never accepted as observations.
