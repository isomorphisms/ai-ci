# Independent inspection of the failed worker repetition

Purpose: read only frozen DCE source archive13108753418 (469333550 bytes,
SHA2560184dffe97bafb6508095682edcaccf62ac3010627da9f1863e3ef5d5edf01c1).
The real producer comparator exited1 on icu-worker.dex versus icu-worker-repeat.dex.
Backend153's source contract deliberately includes requested_output_name in
managed getArgs()[0]. This inspection must establish the actual decoded
difference before assigning a cause.

Type sketch: frozen archive identity -> unchanged original DEX pair -> independent
baksmali class trees -> bounded literal difference. A comparison-only copy may
replace exactly one decoded command-name string to classify the remaining
difference. Original DEX is never changed; no normalized file becomes a candidate,
compiled input or runtime acceptance artifact. The unmodified pair must fail
byte and decoded-text equality first. All other decoded classes must then match.

The result is forensic input diagnosis only. It cannot qualify compiler repairs,
a working reader, an APK reproduction, ART or physical TAB_P10 behavior. The IB
build must repeat the same command name in fresh directories and retain its real
byte comparator. Results are pending.
