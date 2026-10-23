# Independent continuous instrument-font acceptance

Producer: `isomorphisms/rough.framebuffer@83ea1bf4989a8857b9d70c9ae238aa9e0932bf0e`.
Public interface: `sf57_render_coverage`, with no access to producer controls.

`sensor_font_verify.c` independently computes finite Euclidean segment tubes
at all 64 midpoint samples per destination pixel. It checks slash, backslash,
plus, minus and multiplication at five scales/four positions, including the
integer origin. Union is Boolean before resolving coverage, so overlapping
strokes cannot double-darken. A disagreement above two samples/eight coverage
levels fails. All 100 actual-producer cases currently match exactly.

Separately, a four-neighbor flood fill of the actual resolved glyph image
checks the intended open/closed counters for 16 rounded glyphs at scales 3/5.
Those 32 sampled topology cases pass. This is not a proof of topology at all
scales or a guarantee of physical readability.

The negative fixture uses the retained historical bitmap/bilinear-threshold
slash as the image under test. It fails with the intended finite-segment-union
diagnostic and exit 1. It is a checker negative, not a mutated new producer or
an Android execution result.

The image shows, left to right: literal old 5×7 cells, the old 4×4 bitmap
reconstruction, and the real shared whole-path font at scale 8. Only the
historical test control contains bitmap reconstruction.

Initial host run: Linux x86_64, ICK source
`fbe86e23d55cfec2000c08e61deea2a407fd7175`, driver SHA-256
`810dc479ac07e267c6bc5901ff2f45a507ce4a4a3ad8601980b00dea23436a7f`, frontend SHA-256
`d8b2457cf91164b558b6a8d71bbccf77ff786edf057cae9727bb18edb92ef1c2`.
The configured hosted action qualifies its own pinned compiler separately.
Positive results, historical negative diagnostics and the specimen are retained
here; the workflow retains its executable/source/compiler materials separately.
No APK, emulator or physical-device evidence is implied by these numerical tests.
