# Diagnose repaired recursion with exact compiled consumer replay

Compiler 150ae18dcac6e97e6bb5150e868929245f133594 emits and independently
decodes the actual unchanged IB ReaderProjection, with deterministic
positive bytes. Its canonical checked DEX/JNI/ART workflow passes.
The full runtime lanes pass their existing core/native/JNI/field/Text/
alias positive and mutation controls, then the 84007-byte real consumer
does not return within the unchanged 180-second limit on either API.
The 231-byte exact source/control passes. Absence of a captured exception
before timeout is not a successful large-document render.

This independent replay consumes the exact failed runtime archives and
verified actual prepaint DEX SHA-256
9b734b1a545112a53a4a0ad9ab48f9ad0db788933afce11d525c3c877a3a1642.
It checks original NDK/IB source receipts and immutable size/archive digest.
No candidate compilation, DEX patch, replacement parser or source rewrite
occurs in ai-ci.

Run the already-compiled 12000-depth/list/sibling/mutual semantic controls
and four compiled mutants first, then the same real document export.
The observer adds exact intermediate sizes and elapsed-time observations,
retaining the original 84007-byte target and final output expectation.
A daemon SDK Thread samples only the executing thread's bounded
class/method stack every 10 seconds. It reads no exception messages,
source text, URLs, capability values or program local values.
The original 180-second deadline and all semantic gates remain required.
Actual method names map through the retained exact compiler plan.

Generated boundary shape: immutable checked DEX + independent SDK
Thread/stack observations -> actual execution locations and exact output.
Smali remains confined to the independent ART/SDK observer, as in the
existing acceptance suite. Candidate DEX is the real Idriç compiler output;
no alternate interpreter or speculative compiler optimization is introduced.
This supplies the evidence for the next reusable compiler/algorithm repair.
All new replay results are NOT_RUN at authoring. Physical TAB_P10 remains
BLOCKED / NOT_RUN; no release or merge.
