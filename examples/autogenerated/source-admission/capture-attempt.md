# GCC source-observation capture probe

## Type sketch and purpose

The input is an existing checkout or a recorded text file plus a selected observation phase. The output is a process exit, an explicit phase marker and, only when requested, a character count, row count or hidden-index finding. `probe_capture : Text → Text → Text → IO ()` distinguishes reading the actual Git process output from parsing that captured text. There are no source mutation, producer, build, acquisition or admission effects in the probe.

The concrete input is the independently acquired GCC source at locked commit `6294f1d9e7536e5ffcde09d1528c918d63abfef5`; its `git ls-files -v` output has 161,666 rows and 7,932,570 bytes (SHA-256 `1a4bf5e038c610207b943616f3937e050e1b0ab4c5d2a6be56a103bf956d3378`). An initial parent source-checker attempt crashed with an invalid memory reference before its committed-tree stage. The probe reuses only `SourceProcess`, then exercises the inherited text/list operations independently. It does not import the source-admission domain or classify any source as accepted.

This is real Idriç source compiled through registered compiler `2bce7677f513d711875e978bd6f5ad28b9e54d58`, Chez host backend. Pure operations are text unpacking, line splitting and hidden-index flag inspection. Effects are read-only Git invocation, optional recorded-file reading and diagnostics. No fallback is authorized or used.

## Commands and observations

Compiled `SourceCaptureProbe.idric` with the registered compiler at `/workspace/scratch/cacefc042759/toolchain/Idric/_/build/exec/idris2`, using its existing Chez executable and bootstrap/prelude/base library paths. Compilation exited zero. Probe entrypoint: `build/exec/source-capture-probe`.

Executed the actual GCC `ls-files -v` observation through `SourceProcess.observe_process`, then separately read an unchanged recorded copy of that output. Both captures exited zero. Character counting returned 7,932,570 and line counting returned 161,666. The source checker's exact nonempty-row filter and hidden-index flag predicate returned `False` through both capture routes. Eight consecutive real Git captures plus that predicate also completed with exit zero.

The command shape is `source-capture-probe git|file INPUT capture|characters|lines|flags`; `repeat INPUT flags` executes eight actual Git captures. Recorded input is reproducible directly from the pinned GCC checkout with `git ls-files -v`; it is not a maintained fixture or admitted source result.

The initial full-checker invalid-memory-reference attempt remains unexplained. Standalone capture, inherited text/list processing and repeated large observations did not reproduce it. A later full independent Idriç source checker completed recursive ICK/GCC admission with exit zero. These observations do not support attributing the initial failure to pipe capture, line splitting, compiler-wide behavior or a diagnosed runtime defect. No fallback or SourceProcess change was made, and further probes were stopped after the complete run succeeded.

## Language work exposed

No specific missing primitive or reproducible compiler/runtime defect was isolated. Preserve the failed full attempt separately from these passing bounded probes. If the invalid-memory-reference failure recurs, retain its exact executable identity and stage trace before choosing a language change.
