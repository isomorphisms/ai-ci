# Independent geometry acceptance language boundary

Status: BLOCKED Idriç bootstrap; host checker uses checked Ithon, not Python.

The mathematical inputs have distinct roles: tetrahedron/face/vertex labels,
material stitch IDs, parent incidence, measured Lorentz vectors, permutations,
instructions, and source-bound observations. Representing all of them as numbers
or text does not identify their meanings. The first pure slice checks that a
claimed row total equals its parent total plus explicitly inserted children.
Its signature is `valid_increase_count : Number → Number → Number → Bool`.
The complete checker additionally needs bounded text parsing, finite floating
arithmetic, process/file effects, and an explicit foreign call to SnapPy's
installed mathematical-software API. Candidate source is never imported.

The Idriç slice uses current canonical Number and equality-question spelling.
The exact repository-owned entrypoint at e8b9173ab2d840ef0cf212698ea2fee97bd9e807
was invoked via its existing shell implementation as
`sh edric --emit-one-step geometry-acceptance.idric -o geometry-acceptance.core`.
It exited 2: `Idriç one-step emitter: compiler is not bootstrapped; run ./_/edric bootstrap`.
The initial direct invocation exited 126 because the recovered entrypoint did
not have its executable mode restored; invoking its existing shell entrypoint
then reached the actual bootstrap check. No core file or backend result exists.
An unavailable bootstrap is an environment result, not a language defect.
No RefC or generated-C backend is an acceptance substitute.

The operational independent checks use AICI's existing Ithon source and checked
execution path. This is a narrow executable host-language boundary because the
established SnapPy software exposes its API through a foreign Python module.
First-party source remains `.pi`, receives a whole-module check, and records the
Ithon source/lowered-source digests. Foreign SnapPy is versioned separately;
its result is ordinary floating execution, not Sage interval certification.

The next language requirement is a maintained Idriç native runtime that can
consume bounded plain-text observations and call the explicitly foreign SnapPy
interface without rewriting its mathematical algorithms. This record does not
claim that missing facility has been proved absent from the whole language.
