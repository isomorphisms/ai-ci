# Charcoal text contrast

Purpose: qualify the requested opaque palette, not infer contrast from an
average screenshot. The canonical sRGB transfer and relative luminance formula
come from https://www.w3.org/TR/WCAG22/#dfn-relative-luminance; ordinary text
requires 4.5:1. Inactive controls are excluded from that text requirement.

Values: RGB channels are integers from 0 to255; luminance is bounded in millionths.
Input/output: fixed independently specified palette pairs → checked assertions.
`channel_lower : Integer → Integer` returns a conservative linear-sRGB lower
bound. `luminance_lower : Swatch → Integer` combines channels with WCAG weights.
`readable_light_text : Swatch → Swatch → Bool` requires a conservative 9/2 ratio.

Effects: main prints results and exits unsuccessfully on an assertion failure.
The numeric kernel is pure. Unbounded Integer exponentiation and a bounded
binary search implement the 12/5 power without Float16, Float32 or Double.
Each channel floor loses less than one millionth; weighted truncation loses
less than a second, so background+2 is an upper bound. The luminance offset is
50000 millionths. Twenty-four bisections cover the fixed million-step interval.

Invariants: primary and secondary text pass on all three application surfaces;
primary selected text passes on the selection surface; semantic text passes on
all three surfaces. Equal colors and insufficient gray contrast are rejected.
The source-token guard separately anchors the header/XML to these palette
values. This is not actual Android pixel, dialog, lifecycle or device evidence.

Compiler target: the existing IB producer's pinned checked Idriç frontend,
canonical Chez host runtime. No generated-C/RefC or language fallback.
Execution: PENDING; the first hosted compiler/run result must replace this
status. Local compiler is unavailable. Preserve this attempt if checking fails;
the exact diagnostic will identify the first language work required.
