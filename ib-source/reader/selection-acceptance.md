# Independent source selection and native-copy boundary

The reader-v3 profile requires all earlier source, admission, search, numeric,
Prepaint, reflow and retained-history checks, plus source selection. Frozen v1
and history-v2 profiles retain their declared inputs; they do not silently
skip a missing v3 input. V3 also verifies the packaged platform DEX bytes.

`SelectionObserver` has literal expectations for visible wrapping and exact
decoded source copying: spaces at wrap boundaries, discretionary hyphens,
hidden-character endpoint affinities, supplementary Unicode and invalid
surrogate endpoints, combining text, CRLF/NEL/line/paragraph separators,
zero-width breaks, both established reflows, and checked link coordinates.
The expected text does not come from a producer serialization helper. Full
selection checks take the native UTF-16 length of the actually displayed text
and compare the result to the literal original decoded source.

`SelectionWireObserver` invokes the same exported copy ABI on the fixture and
on the actual framework Activity DEX. It checks a literal source/paint map,
then changed source bytes, out-of-bounds metadata, initial gaps and canonical
number spelling. Calling a pure checked export under ART does not qualify an
Activity launch or native touch event; installed application tests remain
separate. Each observer retains a separate output, including when the same
candidate is observed twice.

Producer-compiled mutants count supplementary scalars as one UTF-16 unit,
disable source/paint verification, and return the display string from the actual
Activity copy export. Each must fail at its intended independent assertion,
with exact diagnostic and status 137. Positive candidates require normal zero
exit. This uses the controlled independent assertion helper; it never accepts
an ART crash as semantic rejection.

Both observers assembled with Smali 3.0.10 on the host. Fifteen corresponding
literal CLI checks passed through the maintained Idriç implementation on Chez;
those are host results. New DEX/ART qualification, native clipboard and actual
touch/link navigation remain pending. No physical TAB_P10 evidence is inferred.
