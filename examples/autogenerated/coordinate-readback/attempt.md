# Independent coordinate readback comparison

Control: https://github.com/isomorphisms/flexible-pipes/issues/116.

Input is the native runner's plain TSV output. Expected basis values follow
evaluation of the dual basis, independently of producer packing or lowering.
Every one of the ordered 32×32 cases must occur exactly once. Two exact
integer-valued coordinate-change samples must both give 31.

Input/output: Text filename → IO comparison, with a process failure for an
incomplete, reordered, duplicated or numerically incorrect case set. The
comparison claims only these exact representable cases. Runtime/API/producer
identity and artifact hashes must be anchored by the surrounding execution
receipt; a TSV file alone does not prove shader or hardware execution.

The first attempt is Idriç, with no Python or Ithon fallback. Its expected
results come from the mathematical basis definition and the independent
arithmetic 5×2+7×3 = 5×(−1)+12×3 = 31.

Status: compilation and actual independent comparison passed using Idriç API
2734ac5a86610eddfab73b1644d72b4ac85a65ee. The initial IO totality failure was
repaired by explicitly marking the unbounded file-input boundary `covering`;
the pure expectation functions remain total. No fallback was selected.

The project-specific backend mutant runner executed a shader that swaps
coordinates 0 and 31 in one operand; this checker rejected its recorded values.
It also rejected a receipt missing the (31,31) basis case. This is numerical
comparison of exact representable samples under actual Mesa llvmpipe, not a
mathematical proof of floating arithmetic or a physical GPU receipt. Execution
and source/artifact hashes are retained by the FP control repository.
