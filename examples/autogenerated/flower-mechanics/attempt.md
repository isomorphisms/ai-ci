# Independent finite annular mechanics acceptance

The domain is a synthetic four-row annulus and a six-coordinate stationary
point of its explicitly declared energy. A converged numerical model, a
calibrated yarn material, an embedded zero-thickness surface and a physical
specimen are different evidence kinds.

Type sketch: reference_length, thickness and modulus are positive; the four
ordered rings carry immutable row counts; coordinates belong to the positive,
strictly increasing-height domain. energy : model → coordinates → energy;
stationarity : model → coordinates → checked_residual. Reading TSV/OBJ and
writing a verdict are effects. Acceptance independently reconstructs the
energy and material IDs; it never imports candidate C or trusts its PASS flag.

The Idriç arithmetic slice and invocation use the unchanged one-step
entrypoint files from isomorphisms/Idric e8b9173ab2d840ef0cf212698ea2fee97bd9e807.
The acquisition probe for the same task, squared_extension 2 ≟ 4, exited 2
before type checking: `Idriç one-step emitter: compiler is not bootstrapped;
run ./_/edric bootstrap`. The slice is preserved beside this record. This is
missing acquisition, not evidence of an arithmetic or floating-backend defect.

The bounded fallback is checked Ithon, accept.pi, for independent file parsing,
binary64 energy reconstruction, independently sized finite-difference stencils,
material-marker and mesh reconstruction, and known-bad output controls.
It runs through the real Ithon frontend, not as unchecked foreign Python.
Its result must be bound to the exact Flower source and output artifacts by
the calling workflow. No physical, GPU or handmade acceptance is inferred.

The first Idriç language-work requirement remains acquisition of a bootstrapped
compiler and a maintained native execution path for the checked arithmetic
slice. A complete oracle would additionally require bounded file parsing and
binary64 transcendental mathematics. Ithon success is not Idriç success.
