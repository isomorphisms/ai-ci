# Idriç source index

This is the human-readable companion to
[`source-inventory-v1.tsv`](source-inventory-v1.tsv).

The inventory is for **language-change propagation**: when Idriç syntax, typing,
primitives, or semantics changes, every `follow` entry is a migration/revalidation
obligation. `review-only` entries are historical snapshots and must not be
rewritten mechanically.

Current scan: 2026-09-26.

## Follow the language

### isomorphisms/ai-ci

- [`benchmarks/iridium-2014/IdricBench.idric`](https://github.com/isomorphisms/ai-ci/blob/main/benchmarks/iridium-2014/IdricBench.idric)
- [`tests/fixtures/coupled-bad-partial/coupled-substitution.idric`](https://github.com/isomorphisms/ai-ci/blob/main/tests/fixtures/coupled-bad-partial/coupled-substitution.idric)
- [`tests/fixtures/coupled-bad-precheck/coupled-substitution.idric`](https://github.com/isomorphisms/ai-ci/blob/main/tests/fixtures/coupled-bad-precheck/coupled-substitution.idric)
- [`tests/fixtures/coupled-bad-signature/coupled-substitution.idric`](https://github.com/isomorphisms/ai-ci/blob/main/tests/fixtures/coupled-bad-signature/coupled-substitution.idric)
- [`tests/fixtures/coupled-good/coupled-substitution.idric`](https://github.com/isomorphisms/ai-ci/blob/main/tests/fixtures/coupled-good/coupled-substitution.idric)

The three negative fixtures still follow language-level surface changes; their
specific intended failure must be preserved rather than accidentally replacing
it with a parser failure.

### isomorphismes/pauli

- [`raytracer/RayTracer.idric`](https://github.com/isomorphismes/pauli/blob/main/raytracer/RayTracer.idric)
- [`raytracer/RayTracerTypes.idric`](https://github.com/isomorphismes/pauli/blob/main/raytracer/RayTracerTypes.idric)

### isomorphismes/Conway

- [`wallpapers/ConwayWallpaper.idric`](https://github.com/isomorphismes/Conway/blob/main/wallpapers/ConwayWallpaper.idric)

### isomorphismes/hopf_fibration

- [`src/GenerateHeader.idric`](https://github.com/isomorphismes/hopf_fibration/blob/master/src/GenerateHeader.idric)
- [`src/GenerateSource.idric`](https://github.com/isomorphismes/hopf_fibration/blob/master/src/GenerateSource.idric)
- [`src/Hopf.idric`](https://github.com/isomorphismes/hopf_fibration/blob/master/src/Hopf.idric)

### isomorphismes/theta

- [`src/BrowserMain.idric`](https://github.com/isomorphismes/theta/blob/main/src/BrowserMain.idric)
- [`src/Main.idric`](https://github.com/isomorphismes/theta/blob/main/src/Main.idric)
- [`src/Theta/Interaction.idric`](https://github.com/isomorphismes/theta/blob/main/src/Theta/Interaction.idric)
- [`src/Theta/Math.idric`](https://github.com/isomorphismes/theta/blob/main/src/Theta/Math.idric)
- [`src/Theta/Model.idric`](https://github.com/isomorphismes/theta/blob/main/src/Theta/Model.idric)
- [`src/Theta/Surface.idric`](https://github.com/isomorphismes/theta/blob/main/src/Theta/Surface.idric)
- [`src/Theta/Touch.idric`](https://github.com/isomorphismes/theta/blob/main/src/Theta/Touch.idric)

### isomorphismes/ortho

- [`src/Generate.idric`](https://github.com/isomorphismes/ortho/blob/main/src/Generate.idric)
- [`src/Orthant.idric`](https://github.com/isomorphismes/ortho/blob/main/src/Orthant.idric)

### isomorphismes/L

- [`shader/LWegert.idric`](https://github.com/isomorphismes/L/blob/main/shader/LWegert.idric)

### isomorphismes/coxeter

- [`pseudocode/Dynkin.idric`](https://github.com/isomorphismes/coxeter/blob/main/pseudocode/Dynkin.idric)

## Review only: historical snapshots

These are still Idriç source files, but they record an old PR snapshot. Do not
silently modernize them when the language changes.

- [`_/pr-9-catfood-bare-cloud-acceptance/code/catfood/fixtures/ib/AiciCatfoodFixture.idric`](https://github.com/isomorphisms/ai-ci/blob/main/_/pr-9-catfood-bare-cloud-acceptance/code/catfood/fixtures/ib/AiciCatfoodFixture.idric)
- [`_/pr-9-catfood-bare-cloud-acceptance/code/catfood/fixtures/idric/Main.idric`](https://github.com/isomorphisms/ai-ci/blob/main/_/pr-9-catfood-bare-cloud-acceptance/code/catfood/fixtures/idric/Main.idric)

## Scope and completeness

This snapshot was built by walking repository trees rather than relying only on
GitHub code search, because several recent Idriç repositories are not present in
the code-search/repository-search index.

It covers the visible default heads of the repositories enumerated during the
2026-09-26 scan, plus known current Idriç compiler/backend/application
repositories that repository search omitted. It is a snapshot, not yet a proof
that a newly-created repository cannot escape the list. The next enforcement
step is to make ai-ci rediscover `*.idric` files and fail when the discovered
set differs from this inventory.
