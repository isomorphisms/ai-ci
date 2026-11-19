# Mostow independent mathematical acceptance

Invoke run.grease with AICI_ROOT, MOSTOW_ROOT and OUTPUT. It compiles the
consumer's real ICKY mathematical sources against this owner-maintained
independent verifier. MOSTOW_HOST_COMPILER must name the qualified ICK compiler.
The caller owns source/dependency pins and routes this stage through Flexible
Pipes and Kitchen/Ike. Source presence and a same-model review are not this
acceptance.

The triangulation data is pinned to
[SnapPy example_m004.tri at c3da53c2](https://github.com/3-manifolds/SnapPy/blob/c3da53c2b3105489b4d71531c4f781c92b237753/src/snappy/tests/files/example_m004.tri),
Git blob 02207ee5393033bfb85c2fe9063a3b7ad3c1b7dd. The implementation is not
imported. SnapPy's high-precision volume is an external numerical oracle;
[its documentation](https://snappy.computop.org/manifold.html#snappy.Manifold.volume)
distinguishes numerical volume from verified interval calculations.

The oracle methods intentionally differ from the producer:

- 73 asymmetric metric/differential fixtures solve the generalized eigenvalue
  identities tr(G⁻¹ Jᵀ H J) and det(J)² det(H)/det(G) in long-double
  arithmetic, without the producer's Cholesky/singular-value decomposition.
- The octagon's STAR marking, regular disk radius, reversed edge samples,
  vertex-cycle matrix product and 19 cover-continuity crossings are checked.
  The topology and area diagnostics must also match their exact expected
  invariants. A corrupted pairing and a nonisometry must be rejected.
- 23 asymmetric pairs-of-pants fixtures check both pants relations, all three
  cuff identifications, scalar seam/twist trace identities, closed-curve
  lengths and disk distances between the rendered hexagon endpoints.
  Each twist must change a fixed marked transverse length; changing a cuff
  must change its marked length. This does not infer unmarked nonisometry
  from a Dehn twist.
- The fixed m004 pairings agree with the pinned SnapPy data declared by the
  consumer; edge degrees and cusp cell counts match the authoritative example.
  Doubling a peripheral generator or duplicating the two curves must fail
  the primitive-basis check. The complete/edge-only pair remains separated.
  Six additional ideal shapes are compared to a long-double log-sine integral
  using composite Simpson quadrature, independently of the producer's zeta
  series. The regular total volume agrees with SnapPy's high-precision
  2.02988321281930725004240510854904057188.
- Half-integers independently force the sharp coarse-surjectivity bound
  B = 1/2; returned witnesses are bound to the queried real number.

The unchanged verifier must reject six actually compiled producer mutations:
constant dilatation, erased Euler characteristic, ignored twists, omitted cusp
conditions, removed peripheral primitivity, and erased volume. A compiler
failure is not accepted as successful mutant rejection; the wrong program
must execute and fail first at its intended diagnostic.

The runner snapshots all four sources and headers, the oracle, runner,
compiler driver and C frontend before execution and compares their hashes
afterward. It records both repository revisions and produced-artifact hashes.
A source change during acceptance fails; an uncommitted worktree result must
be rebound to its final committed revision by the caller.

This is deterministic numerical/combinatorial acceptance for the specified
fixtures. Long double and libm are not interval arithmetic; the quadrature
tolerance is a test threshold, not rigorous certification. The finite regular
volume samples do not prove the ideal-simplex extremal theorem or Mostow
rigidity. Rendering, Android packaging, installation, physical GPU behavior,
persistence and resume require their own evidence.
