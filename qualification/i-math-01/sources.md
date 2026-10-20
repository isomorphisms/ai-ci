# Literature, rights and mathematical fixtures

The existing repository catalogs remain the first source of prior intent.
`inventory.tsv` records their locations; empty literature columns mean no
standard catalog was found on the default branch, not that a subject has no
literature. Reference repositories retain their own licenses and attribution.

## Acquired source

Jahnke and Emde, *Tables of Functions with Formulae and Curves*, Dover 1945,
the specific [Digital Library of India / Internet Archive item](https://archive.org/details/in.ernet.dli.2015.212842)
already identified in theta's `sources/jahnke-emde.md`.

The source metadata was fetched anew on 8 October 2026. It states
`dc.rights: In Public Domain`. That is the archive's item-specific rights
statement, not a universal assertion about every edition or jurisdiction.
No rights assumption was inferred merely from a working PDF URL.

- Source bytes: [original PDF](https://archive.org/download/in.ernet.dli.2015.212842/2015.212842.Tables-Of.pdf), 53,144,192 bytes.
- Archive SHA-1: `99ded8cbb267f733bfc4ddf7f7121718bbeae5fd`; downloaded bytes match.
- Download SHA-256: `f01edd4425e03b3e64f2d59ce68b6b58d22e4c77624a76334199fc3b303f2551`.
- [Metadata endpoint](https://archive.org/metadata/in.ernet.dli.2015.212842); captured metadata SHA-256 `48bc2096f469dd78460c855a4b117af52d477bf5ac318040d1bc3391fcbcfe1c`.
- A persistent reference copy was saved as `jahnke-emde-tables-1945.pdf`.
  This ledger keeps provenance/checksums rather than duplicating a 53 MB scan.

Existing theta notes map printed pp.41–45 to theta definitions/tables and
pp.90–102 to Jacobi/Weierstrass reliefs. Those page mappings were recovered
from repository notes, not independently re-audited page by page in this pass.
The live [NIST DLMF theta definitions](https://dlmf.nist.gov/20.2) supply a
separately checked convention reference. The repository's series uses a
period-one coordinate while the DLMF formulas use the usual π-scaled argument;
fixtures must make that conversion explicit rather than compare unlike inputs.

## Source-to-fixture map

The table distinguishes executed checks from prepared future fixtures. A
bibliographic link is not evidence that the corresponding code passed.

| Repositories | Primary/reference source | Concrete mathematical fixture or gate | Rights/action and execution state |
| --- | --- | --- | --- |
| seifert, spinor, knotkit | [Dennis–Hannay, Geometry of Călugăreanu's theorem](https://arxiv.org/abs/math-ph/0503012), existing Seifert/Rolfsen/Morishita catalogs | Endpoint commanded turns stay distinct from framing twist. A closed-link number needs disjoint closed oriented boundaries. Genus arithmetic needs certified connected orientable counts. | Link and metadata only; no redistribution license inferred from arXiv access. Seifert readout/integer fixtures EXECUTED; no geometric invariant fabricated. |
| seifert, spinor, hopf_fibration, ortho, klein-quartic, knot-complement | [Hatcher, Algebraic Topology, author page](https://pi.math.cornell.edu/~hatcher/AT/ATpage.html); each repository's own cited construction | Check maps and domains before mesh topology, covering-space or lifted-state claims. A returned spatial orientation need not return the lifted spin state. | Author-hosted access confirmed; redistribution not assumed. Existing specific catalogs retained; broader fixtures PREPARED. |
| mostow, knot-complement, Hyperbolic-Honeycombs | Mostow's `books/mostow-rigidity.md`, `books/papadopoulos-quasiconformal.md`, `notes/motion-certificate.md`; Thurston sections 5.9/6.3 cited there | Distinguish n=2 flexibility from rigidity in n≥3; compare face singular values to [1/1.10,1.10]; reject a stretched mutant; keep quotient gluing independent of extrinsic intersections. | Existing links retained; no restricted notes copied. Mostow PL tests and actual producer gates EXECUTED. |
| mostow | Taimiņa and Institute For Figuring references in `books/hyperbolic-crochet.md` | A ruffled extrinsic model is not the Poincaré disk as a unique spatial shape. Ruffle appearance stays a user choice. | IFF photographs remain link-only; actual new screenshot is from the repository renderer. |
| theta, allegra, holomorphic, lacunary, wegert | Acquired Jahnke–Emde volume; [DLMF §20.2](https://dlmf.nist.gov/20.2); existing Mumford/Borcherds notes | Fix nome/argument conventions; test parity and quasi-periods; specify truncation and tail error. Do not identify unit-disc natural boundaries with whole-plane meromorphic domains. | One item-specific public-domain scan acquired; other books remain metadata/link-only. New theta/kernel fixtures PREPARED, not executed. |
| L | [DLMF §25.15](https://dlmf.nist.gov/25.15), `L/NOTES.md`, bundled LMFDB character descriptors | Compare Hurwitz-zeta finite-sum continuation with the convergent Dirichlet series only on Re(s)>1; check character periodicity/parity and conductor-specific values. | Reference page checked live; link-only. PREPARED. |
| p-adic | [Hazewinkel, Witt vectors, Part 1](https://arxiv.org/abs/0804.3888); repository's ghost-polynomial convention | For p=2 and coordinates (1,1,0), first ghost values are (1,3,3). Changing coordinate i cannot change lower ghost components. This does not define coordinatewise Witt addition. | Primary paper identity checked; link-only pending explicit redistribution terms. Exact fixtures PREPARED. |
| polya | User's `polyá.md` and original R histories | Signed increments (+1,-1,+1) give positions (1,0,1); return times of a ±1 walk are even. A simulated sample cannot prove recurrence. | Existing user material retained. Exact walk examples PREPARED. |
| Fourier-sound, pauli | Existing harmonic-decomposition/normalization notes; Tao's Fourier article linked by Fourier-sound; Pauli's book and source catalogs | Constant, one harmonic and superposition fixtures; decomposition/reconstruction error; preserve stream units. Camera motion differs from state rotation. | Metadata/link-only for ordinary copyrighted books and articles. PREPARED; existing CI observations are not a new numerical run. |
| sprott | [Sprott's own simple-flow archive](https://sprott.physics.wisc.edu/simplest.htm), `docs/sprott-b.md`, published 1994 paper | Preserve Case B equations and parameters; check fixed-step RK4 refinement and finite-state behavior. A chaotic-looking trail is insufficient. | Published mathematics can be independently implemented; personal-use software/images are not copied. PREPARED. |
| moishezon, threefold.exploration, algebraic-variety-explorer-mobile, coefficient-root-dance | Existing Hartshorne/Koras–Russell and SURFER/jsurf references; live root/normal issues | Exact polynomial identities, repeated-root fixtures and derivatives. For x+x²y+z²+t³, simultaneous vanishing of all partials is impossible since ∂/∂y=x² forces x=0 while ∂/∂x=1+2xy then equals 1. Smoothness is not an affine-space classification. | Independent elementary derivation; restricted books remain links. PREPARED. |
| soap | Brakke source/provenance entry and recovered catenoid/helicoid surface-player branch | Exact parametric vs implicit vs Evolver discretization labels; do not call a nodal approximation the exact minimal surface. | No catalog mirroring without source-specific license; closed implementation branch is not merged default. PREPARED. |
| coxeter, Cayley, Conway | Their existing presentation, reduction, Group Explorer and pattern-language references | Test generator relations in the specified representation, reduction traces, orbit/stabilizer counts and presentation-to-renderer mappings separately. | Inherited Group Explorer LGPL and other notices retained; no wholesale code migration. PREPARED. |
| indras-pearls, kleinian-groups | Pinned Rust reference `117dc5f34353e98cfae2f12bf386db5862110d92`, `notes/original-kleinian-restoration.md` | Trace pair 2.2/2.2, priority queue growth 4,6,8,…, finite centers and the historical raster-index expression. | Existing attributed source translation retained; no new unlicensed book copy. PREPARED. |
| Byrnes-Euclid, byrne-euclid | Default I.11 brief, closed III.1/I.47 experiments, inherited Byrne/Euclid edition | Select the proposition from actual intent before construction fixtures. Keep Euclid's source, modern typography and app interaction distinct. | Preserve the edition's GPL/CC BY-SA notices; no assumption that all modern assets are public domain. PREPARED. |
| non-poly, 3b1b-videos, manimi, yt-shorts, Fragmentarium, FragM | Existing bibliography, upstream scene/shader sources and licenses | Use only a selected, stated mathematical construction; animation/media tooling is not proof of its semantics. | Reference/tooling disposition; no speculative app kernel or copyrighted asset mirror. |
| solver-engine, pyggb, geogebra | Inherited upstream code and licensing documents | Adopt a particular rewrite/geometry algorithm only after recovering a user-specific target and its domain. | Reference-only; no new Kotlin/Java/Python production path or blanket license claim. |
| a-man-has-a-face, a-man-has-a-voice | No source history recovered | No invented subject matter, bibliography, implementation or acceptance criteria. | Empty repositories explicitly retained as NO_ACTION_WITH_REASON. |

## Reusable representation discipline

Prefer mathematical domain names above machine representation. Whole-number
`Number`, signed `Integer`, decoded `Text`, and explicit units are different
boundaries. Preserve requested float widths at checking and lowering. A
binary64 host oracle is not Float32 execution and a source file ending in
`.idric` is not compiler evidence. New programs begin with an Idriç attempt
and a type-system account; unsupported compiler/backend behavior stays visible.

Do not treat Freely readable as Redistributable. Each later acquisition needs
an item URL, edition, author, rights statement, hash and exact use. Existing
references are linked; no Morishita, Milnor, Mumford, Taimiņa, Sprott software,
Diproton video, IFF photo or unlicensed repository was silently mirrored.

## Six additional repositories from the closing scope refresh

These are recovered repository references and prepared fixtures, not newly
executed application tests or new rights clearances. No additional full text
was downloaded or mirrored.

| Repository | Existing source record | Next independently checkable boundary |
| --- | --- | --- |
| beauty | [anatomy/sources.tsv](https://github.com/isomorphismes/beauty/blob/34d0b6e04023c8ca4e7dd25b2381a2128f12c03a/anatomy/sources.tsv), retained FaceField Idriç attempt | Zero activation preserves the neutral point; bounded activation yields finite contraction coordinates with explicit millimetres. Approximate fields are not measured anatomy. |
| flower | [retained Net → Skin → Mesh model](https://github.com/isomorphismes/flower/blob/aa74149c17e1154c54b8db7d7ef3ef441614f37c/docs/net-model.md), existing GT3M notes | Coincident folded points do not gain graph adjacency; changing display density leaves material state unchanged; release freezes full state. Retain existing mutants. |
| crystal | [retained material/net model](https://github.com/isomorphismes/crystal/blob/63cfefc9c98eb3c10a0c797c788ee50678e75db2/docs/net-model.md) and material crystallographic references | Halite has 8 vertices, 6 quadrilateral facets and 12 boundary edges; preserve incidence, not counts alone. A static polyhedron is not a tested growth law. |
| young-tableaux | [existing Fulton/Sagan/Stanley/Macdonald shelf](https://github.com/isomorphismes/young-tableaux/blob/f16ca4008a0959753a50067281f869e34bab94cd/books/README.md), active independent audit | Preserve all ten existing UI/validation/overflow counterexamples and independent finite-range algebraic oracles. Publisher/author links do not grant scan redistribution. |
| mock-theta | [algebraic Tetris derivation](https://github.com/isomorphismes/mock-theta/blob/fa30b9a240838dfee3255f5003417901d5f94513/docs/algebraic-tetris.md), existing Duke/Zwegers/Zagier catalog | Compare exact signed expansion of (1−qⁿ)Bₙ and the five-panel coefficient vector; finite agreement is not mock modularity. Retain existing compiled proofs and gesture mutants. |
| pigeonhole | [consolidated author/Sullivan/Vakil/Hatcher bibliography](https://github.com/isomorphismes/pigeonhole/blob/aeec21f370a8677ef8b1b9bb8c84e8ec3bdf4b8c/books/BIBLIOGRAPHY.md) | A map from three elements into two supplies a collision; quotient by equal image maps bijectively to the image, not necessarily the entire codomain. Empty-fiber and injectivity cases stay explicit. |
