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
