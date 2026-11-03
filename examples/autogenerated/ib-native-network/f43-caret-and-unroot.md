# Qualify the actual fragment caret and quiet successful unroot

F43's source/native/signed-APK repetition and both required ART suites pass.
At independent observer84c6e7d46913f6f50a6debb63cb1fd786f077ea5, full API29,
all six isolated fragment/lifecycle/link profiles and decoder29 pass. Full34
and decoder34 remain failed evidence, for different observer problems.

Full34 job125049957900 (artifact13110124482, SHA256
ebe5467e85750b71124bc29aca7c52f1560712d0cf4ee336bda30adcc188b3ac)
did not reject the compiled cursor-settlement removal: its target was visibly
inside the viewport, but public SDK selection remained0,0 rather than on the
target line. The old viewport predicate could observe a transient or otherwise
visible target while missing the stale insertion point.

The independent FragmentViewport oracle now reads SelectionStart/End and Android
Layout lines in addition to its unchanged target visibility/beginning exclusion.
A fragment's insertion point must be collapsed on the Target text's actual
display line, located independently from the displayed fixture text. It never
sets selection, focus, scroll or private fields. It does not compare an internal
C offset or assume font/toolbar geometry. The zero-point control retains its
exact viewport failure. The settlement-removal control may fail only one of two
literal, designated assertions: wrong viewport or wrong insertion line.
Instrumentation code0 remains required; timeouts, process failures and other
assertions cannot count as rejection. The original must pass both conditions.
Fragment receiptv4 records the added SDK invariant.

Decoder34 job125049928125 completed actual decoded UI, copy/reflow and offline
reboot observations, then stopped before independent original-byte readback at
an unconditional unroot acknowledgement check. Read-only ai-ci41375984193,
source3596a96deba9b8a72896dc441f77192df91bc7b8, verified its original artifact:
unroot exit0 and exactly zero stdout/stderr bytes. Post-unroot UID was not
observed in that failed run and is not invented. Diagnostic artifact13111785008
has SHA256892e8dd3b2b5a5274ec10906fd0898cc240b01a1f31a39e8a680a53ac60ed20e.

The decoder now requires the known restart acknowledgement only for status1.
Status0 may have empty output. Both paths still require bounded reconnect and
an actual SDK shell UID2000; that observation is retained before source
readback and corruption controls. Unexpected statuses and a still-rooted shell
continue to refuse. No source, signing, network, byte, generation or identity
check is removed.

Type sketch: public displayed target line + collapsed SDK insertion line +
visible geometry form one consistent fragment state. A successful CLI result
is separate from the observed postcondition of shell authority. These are
oracle changes; the F43 APK and all nine compiled candidate controls remain
byte-identical frozen inputs. Fresh current-observer runtime results are pending.
Physical TAB_P10 and ARM runtime remain NOT_RUN.
