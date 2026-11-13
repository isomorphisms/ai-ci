# Explicit compiler selection at Android artifact gates

Requirement before implementation: maintained signer C must compile through
the qualified ICK stage, with no ambient cc fallback; preserve every existing
registry/APK/companion assertion and separate artifact evidence from runtime.

Type sketch: a companion gate consumes exact source, plan and finished APK
paths plus an explicit compiler path and returns a receipt only after all
checks. The checked negative oracle maps process status/text and the existence
of a receipt to rejection assertions. Filesystem/subprocess/environment APIs
are explicit standard-library boundaries; no owned Python checker is imported.

The old companion entrypoint, composite signing action and registry CI all
contained hard-coded cc invocations. They are changed to explicit qualified
ICK, and registry CI now checks out the exact PR head and executes the original
positive/hostile signer corpus through that compiler. The composite action
qualifies its pinned native ICK stage itself. Existing Bash orchestration is
retained as a named migration boundary, not described as Grease.

Actual local mandatory Ithon frontend: accepted source
9d530f4ad51f5b0a09c3e74dbe45cac5bb6d52d3 on Linux x86_64. The new checked
oracle executes both existing missing-input cases, then incomplete negative
fixtures for absent ICK and relative ambient cc. Both refuse at the compiler
selection gate before a receipt can exist. These dummy Git directories are
negative inputs only; they are never a positive source or APK receipt.

Local compiler-selection negatives and syntax checks pass. Actual native ICK
registry self-tests and the combined Wegert producer remain hosted gates.
No source-only, APK, installation, runtime or physical acceptance is claimed.
