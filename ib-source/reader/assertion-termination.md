# Controlled independent assertion termination

IB run 41263232232, exact source `6d50def5788957fae58b3a7c27c710a414622664`,
failed on API 29 after its compiled admission mutant correctly produced
`FAIL count-mismatch-refusal`. The retained log records `System.exit` status 73,
then `destroying mutex with owner or contenders` and a segmentation fault in
the `Jit thread pool` while packing JIT debug information. The run remains
failed; exit 139 is never accepted as a semantic rejection.

`AssertionFailure` is an independent Smali observer, not candidate DEX. It
flushes the assertion's existing exact diagnostic, then uses the public Android
`Process.myPid` and `Process.killProcess` APIs to stop only its own process.
The controller requires both status 137 and the exact intended failure line.
Unexpected exceptions, crashes, timeouts, missing assertions and a compiled
mutant that returns normally still fail. Positive candidates must return zero
and print their complete independent success marker. ART/JIT execution of the
candidate is unchanged. Normal successful VM shutdown is still exercised.

The old observer remains recoverable at ai-ci `d62e6fe89f944585052cfc626e9c51dd1133034c`.
The original diagnostic archive is artifact 13067715538 from ai-ci run
41266155280, SHA-256 `7ee37743c2158573397817efa4fce358eb8b5bfbe3fefd7f7c7da8f60352a7ee`.
New API 29/34 execution is required before calling this correction qualified.

Platform contract: https://developer.android.com/reference/android/os/Process#killProcess(int)
