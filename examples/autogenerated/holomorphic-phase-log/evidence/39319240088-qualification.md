# Exact f2ef generated shader emulator acceptance

Actual [run 39319240088](https://github.com/isomorphismes/holomorphic/actions/runs/39319240088) binds application `f2ef44e348bc37c90c1da951632c4fb1f5466c7d` to the checked generated fragment. The ordinary corpus, separate large-q diagnostic and independent source byte provenance all PASS under frozen checker 13231 and unchanged policy hashes.

The independent recheck used the exact restored Ithon d6e83969 host frontend, whose 42 qualification tests passed. It compared the actual host-generated fragment against `assets/continuation.frag` extracted from the signed APK and checked both the actual `glShaderSource` submission hash and driver source readback hash. All 30577 bytes agree.

All 34 actual phase/log and same-program RGBA8 observations pass, including four true singularities and both 24-pair scale probes. Maximum circular phase error is 2.4503960034394368e-6 radians against 1e-4. Maximum unreduced log error is 3.9424049226632896e-5; its applicable minimum-envelope budget is 1e-4. The maximum error/budget ratio across all regular raw-log observations is 0.39424049226632896. All observed RGBA8 channels equal the independent canonical reference exactly, within the unchanged one-level regular budget and exact singular/alpha requirements.

The old `24_displaced:0` counterexample now has phase -0.504855752 versus binary64 -0.5048554277997677 and exact expected RGBA (220,151,192,255). Historical failed runs 39310320206 and 39313673457 remain retained separately. First repaired predecessor 08f0 also passed and has its own receipt; its result does not replace this exact-head run.

The separate large-q observations preserve the expected divisor increments before Wegert conversion: phase/log delta errors 3.3399558326513261e-8 and 2.7000452404903205e-8 remain below the predeclared 2e-6 budget. The erased raw pair correctly returns produced=0 and stays **RANGE_REJECTED_UNQUALIFIED**. Its finite channels and explicit rejection are not qualified raw-field numerical success.

The 663-line focused ledger preserves every original input, coefficient, uploaded reduced factor, all 34 raw and colour rows, all separate large-q rows, graphics readback markers, actual driver/source identity and the emulator's informational EGL timing line. Audit transcripts and per-row errors/maxima are separate evidence files. The metrics command's structural-only NOT_RUN labels describe that command's scope; the separately executed numerical/colour audits provide the PASS classification.

Execution used Android Emulator/Google SwiftShader 4.0.0.1. Shader compilation/link measurements are CPU wall times. Its generic EGL_emulation app_time_stats line reports avg=2791.64ms, min=2766.41ms, max=2816.87ms, count=2. This is an informational presentation/emulation observation, not GPU time or performance qualification. No GPU execution timer, HOLO_FRAME_TIMING row, separately instrumented application EGL duration, CPU search timing, thermal or sustained physical result was observed. A1/GE8322, C67/GE8320 and TAB_P10/Mali-G57 remain NOT_RUN.

Publication remains separately FAIL at this snapshot. The first final-f2ef attempt created draft 417754546, then failed its release ID numeric assertion. The bounded second attempt uploaded the exact APK and receipt, then failed Grease's strict_errexit restriction at publisher line 141. A read-only API check observes a draft/prerelease with the correct target and two digest-bound assets. Public publication did not pass; fresh public Cat Food acquisition is NOT_RUN.

The earlier 08f0 HTTP403 snapshot remains historical evidence. Its documented workflow permission rule is consistent with that denial, but the same logged Contents:write permission class subsequently created the f2ef draft and uploaded its assets. That rule alone did not predict the observed final behaviour. The current final publication finding rests on the actual Grease failure, not a definitive final permission diagnosis.

This evidence-only addition changes no source, checker, corpus, fixture or policy.
