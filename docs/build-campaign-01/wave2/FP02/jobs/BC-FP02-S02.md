# BC-FP02-S02 — Execute one declared model worker and replay its exact accepted output

**1. Identity and execution:** SUN / Ultra; owner `isomorphisms/flexible-pipes`; parent BC-FP02 and [campaign239](https://github.com/isomorphisms/ai-ci/issues/239); canonical [FP19](https://github.com/isomorphisms/flexible-pipes/issues/19), replay [FP1](https://github.com/isomorphisms/flexible-pipes/issues/1), regression [FP18](https://github.com/isomorphisms/flexible-pipes/issues/18).

**2. Outcome:** An explicitly selected capable model worker returns bounded raw output that deterministic downstream stages validate; recorded replay consumes those exact accepted bytes without calling or loading any model.

**3. Recovered intent:** Preserve the existing named large-model catalog and distinctions among cataloged, resolved, downloaded, loaded and inferred. Fixed seed/temperature does not establish deterministic fresh inference. Ordinary deterministic jobs need no model download or inference.

**4. Current evidence:** [FP main](https://github.com/isomorphisms/flexible-pipes/tree/b7f944b1391a8a2ea96ee07f6b9c0431311842b0) README/catalog describes GPT-OSS, Qwen and Pythia; `scripts/run-pipeline` rejects non-command kinds. The [pipeline contract](https://github.com/isomorphisms/flexible-pipes/blob/b7f944b1391a8a2ea96ee07f6b9c0431311842b0/docs/pipeline-contract.md) specifies model and replay boundaries. FP19 has no implementation comments; model bootstrap alone is not inference evidence.

**5. Reuse:** Extend the existing stage interface and selected registered controller, not another worker framework. Inspect existing catalog/fetcher and retained model-understanding experiment before editing. Preserve historical deterministic regression corpus and explicitly distinguish its field validator from actual model evaluation.

**6. Scope and ownership:** FP owns bounded worker capture/replay. Owner deterministic validators decide acceptance; Cockswain supervision and application semantics remain outside this job. Only one actually available runtime adapter is required; unsupported catalog entries remain explicit.

**7. Prerequisites:** Consume S01 stable-plan artifact and BC-FP01-S01 admitted interface. Resolve a named model's exact provider revision, tokenizer, prompt/template, conversion/quantization, runtime and target-resource capability. Actual inference requires an already configured capable worker and applicable resource authority. Missing hardware, credentials or permission blocks that stage, not source/replay implementation; never substitute another model. Read current shared/local instructions: Idriç-first helpers, Grease orchestration, checked Ithon, scoped Ike and exact ICK/NDK stages; no new Python/Bash debt or runtime substitution.

**8. Work:** Implement explicit fresh inference and recorded-replay stage behavior in the maintained path. Bound input/output, time and cancellation; persist literal prompt and returned bytes, observed executable/model identity, streams, exits and acceptance. Admit replay by exact original receipt and payload; expose current admission separately from historical replay authority. Connect one existing regression case through a real deterministic consumer.

**9. Acceptance:** A real available worker's accepted output feeds the consumer once; replay in a second environment produces equal downstream results with an independently observed model-call count of zero. Reject modified raw output, missing receipt, wrong model/tokenizer/runtime identity, incomplete streaming response, over-limit output, stale requirement and cancellation before side effects. Benign ragged output/Unicode and a separately authorized fresh inference remain valid. Test doubles prove adapter mechanics only and cannot fill the real-inference case.

**10. Evidence limits:** A replay success proves those recorded bytes, not model quality or future response identity. Preserve NOT_RUN for unavailable real workers and unsupported catalog configurations.

**11. Completion and continuation:** Release source, deterministic replay tests, actual inference receipt when possible and exact missing-worker acceptance job otherwise. Update FP1/19/18 without closing unrelated model review/calibration obligations.

**12. Authority:** Implement and perform bounded already-authorized verification. No model-family download, purchase, new hosted deployment, schedule, live external mutation, merge, closure or dispatch is inferred.

END OF BC-FP02-S02
