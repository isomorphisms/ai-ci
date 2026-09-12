# Keyboard cross-reference watcher

This observer compares the physical programmer's keyboard with the phone
software keyboard without requiring them to be identical.

The hardware keyboard is the slower-moving concept surface: a PCB has to be
fabricated, while the software keyboard can be shipped and revised quickly.
That gives changes in `programmers-keyboard` stronger review precedence.

The watcher therefore has two asymmetric signals:

- if `isomorphisms/programmers-keyboard` moves beyond the reviewed baseline,
  emit a **warning** so the phone keyboard is reviewed for possible additions;
- if `isomorphisms/utilities-android-phone-user` moves beyond its reviewed
  baseline, emit a lower-priority **notice** so the PCB keyboard can optionally
  borrow useful ideas.

Neither direction automatically copies keys, fails a build, or asserts that
the two layouts should converge.

## What is compared

`cross_reference.tsv` maps hardware boards to software pages. Movement and
signals are explicitly hardware-only because the standalone phone Unicode
picker cannot represent those actions.

`observe.py` extracts key labels from:

- `programmers-keyboard/render-keypads/src/Renderer.idr`
- `utilities-android-phone-user/math-characters/idric/UnicodePicker.idric`

It removes display-only glyph prefixes such as `+` in `+\nADD`, normalizes a
small set of mechanical label variations, and emits deterministic rows:

- `shared`: the normalized concept occurs on both mapped surfaces;
- `hardware_only`: candidate for software review;
- `software_only`: low-priority candidate for eventual hardware review;
- `hardware_only_board`: an intentional scope exception;
- `unmapped_hardware_board`: a new hardware board that needs an explicit
  cross-reference decision;
- `unmapped_software_page`: a software page with no PCB mapping.

This is a lexical observation, not semantic equivalence. A `shared` row means
the normalized labels match; it does not prove the actions behave the same.

## Reviewed baseline

`baseline.tsv` records the last pair of repository revisions reviewed as the
starting state. The scheduled workflow deliberately checks out moving `main`
heads, records their exact revisions, and compares them with this baseline.

A hardware revision mismatch remains a warning until the cross-reference has
been reviewed and the baseline is intentionally advanced. A software mismatch
remains only a notice.

The workflow runs daily and on changes to the observer itself.
