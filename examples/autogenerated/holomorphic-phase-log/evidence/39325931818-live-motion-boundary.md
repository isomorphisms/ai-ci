# Current-head live-motion evidence boundary

Application `937a7aa0cfbec32d527b8bd44f3da63a6c76c82b`; run `39325931818`, emulator job `118324870950`. This is a read-only source/log/capture review, not another runtime experiment. No source change was made.

**Decision:** `live_motion_continuity=NOT_RUN` (unqualified); temporal smoothness, wall-clock motion rate and sustained performance remain unqualified. The current nearly static capture pair establishes neither a default pause state nor a concrete live-loop failure. Independent mathematical time-twin probes and selected-source acceptance remain separately PASS. Physical A1, C67 and TAB_P10 execution remains NOT_RUN.

The native activity has no run/pause control. Its initial coefficients and remote-pole time are zero. On gained focus the native loop enables animation; each focused, non-gesture update increments `remote_pole_time` and marks the frame dirty before checking CPU search-worker readiness. The update caps its timestep at 0.05 seconds. Consequently a slow renderer can advance simulated time much more slowly than elapsed wall time; the source does not define a paused default. A UI-thread focus message at 21:45:31.881 does not itself prove when the native thread processed its focus command.

`exercise-generated-emulator.grease` waits for `holomorphic field first frame:`, checks the target process and the numerical/provenance rows, then captures A, sleeps two seconds, verifies the same PID and captures B. It does not wait for a second successful presentation, record capture-time frame counters, or verify advancing simulation time. The first-frame native marker follows a center-pixel readback and **precedes `eglSwapBuffers`**. The helper retains the target-process log snapshot obtained while waiting for that marker and never refreshes it after the captures.

The actual current-head log reports SwiftShader, 2400×1080, numerical output completion at 21:45:33.917 and the first-frame marker at 21:45:36.756; the retained log ends there. It contains no subsequent native state or presentation-progress receipt. The capture helper exits at 21:45:52.081 in the Actions log; individual screenshot start/end times are not recorded. There is therefore no observed second-presentation/time-progress boundary with which to interpret the two stills. Slow or repeated presentation is a plausible explanation, not a measured current-head diagnosis. Historical f2ef captures are not substituted for this missing evidence.

Execution inspection measured only 117 changed pixels across the current 2400×1080 pair, 51 in the 1600×700 interior and 7 in a 400×250 marker/UI-free region. These small differences provide no meaningful animation, continuity or speed acceptance.

The remaining E2 runtime qualification needs a post-swap presentation count and simulation-time receipt bound to capture times, confirmation of focus and live input state, and multiple actual presented frames over a sufficiently long interval. GPU execution, CPU search, EGL presentation, thermal behaviour and sustained many-factor performance must remain distinct measurements on each named physical device. This receipt proposes an evidence requirement, not a speculative source repair.

| Bound input | Git blob | SHA-256 |
|---|---|---|
| `_/shader/exercise-generated-emulator.grease` | `3df0fa1d53c0a0d706afd5e7dfc56e316c987995` | `5f50fa9ba3d8d6630f81a8f3acaf29e0e9813865c9d9e92eba377f647941bc8d` |
| `android/app/src/main/cpp/analytic_continuation_random.c` | `684dd85d220dfa3ab34d7cf06fe909601051c46c` | `81a2cb765a6da5fda517051482eeee441a5131fe7459eafbb5c283be9c73a331` |
| `android/app/src/main/java/org/isomorphisms/analyticcontinuation/ExplorerActivity.java` | `68cdca0b233ea17583fcfa9fc1a58ffd87056996` | `04c0223c63c348ee3f418f8ca396c9d1a80bce29da49fdf9d9fed2419d10a0e5` |

| Current original evidence | SHA-256 |
|---|---|
| `final-937-emulator/generated-holomorphic-emulator.log` | `4d6adf51813a2a8720ec61ec24035fadfbb79cf7b9aa434d4f5f5c8a841b6c54` |
| `final-937-emulator/generated-holomorphic-frame-a.png` | `3c36ff1b35f23e40c3606e36ff92f6454a4657d7248fdb01fd607af7f329db20` |
| `final-937-emulator/generated-holomorphic-frame-b.png` | `18d2cb32e46a73e50bb285c832510e4f68006a795d45b363c6021e0d19003425` |

All evidence paths above are relative to `/workspace/scratch/3e66f41b73d4`. Pixel-difference measurements are retained in `final-937-execution-inspection.md`; source hashes were recomputed during this review.
