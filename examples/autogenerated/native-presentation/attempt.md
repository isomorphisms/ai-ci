# Independent native presentation acceptance

Values: retained source occurrences keep identity, generation, order and cursor.
The displayed metadata revision grants no mutation authority after it becomes
stale. A View callback must implement the Android listener's exact signature.

Operations: `select_projected_source : Text → Text → Int32 → Either Text BrowserHistory`
is the actual IB implementation. The observer chooses expected identities and
cursor bytes independently, including a repeated identity at a newer generation.

The host observer runs through the pinned Idriç frontend (Chez target); the same
source also emits direct DEX. Host execution is not ART acceptance. A separately
compiled producer mutation bypasses the revision guard and must fail the stale
history assertion. Other controls reject corrupt generations, negative/absent
positions, truncated metadata, and unknown history versions.

`CallbackProbe.smali` is an independent ART reflection observer, never a product
DEX source. It requires View.OnClickListener, onClick(View), native and void.
The typed producer's onClick(Int32) mutation must fail that observer.

## Native timeline worker

The input remains FastChat's existing typed `HistoryTurn` and committed journal
prefix. A borrowed read-only worker projection yields at most three ordered
turns with bounded exact UTF-8 previews. Its effects are positional file reads
and pthread scheduling; the Android renderer alone owns Views. The independent
C observer exercises that actual C platform boundary and the actual durable
store. This does not introduce alternative Idriç conversation semantics.

The observer constructs five real committed turns with independently chosen
Unicode prompts and responses spanning the preview boundary. It requires
identities 2,3,4 before focus 5; an earlier focus, empty history, unavailable
source and invalid focus are separate results. It calls the actual publication
boundary with a superseded revision and retired owner. Separately compiled
actual producer mutations reverse history and bypass revision refusal; exact
diagnostics are required. Thread completion times out as failure. Host pthread
execution does not qualify Android UI, UI stalls or physical behavior.

The first executed oracle incorrectly expected attempt 1 for every request.
FastChat's actual `begin_request` advances one conversation-wide durable attempt
counter; its existing tests also require advancement across retries. Run
41750520306 rejected that oracle while the worker preserved the source values.
The correction adds an explicit retry on request 2, so preceding requests
2,3,4 must retain attempts 3,4,5. Request identity and attempt identity are
checked separately. This changes a disproved expectation, not the producer or
its identity contract; original failure remains in that retained run.
