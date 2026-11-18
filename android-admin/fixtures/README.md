# Transport-only PNG

`transport.png.base64` is a fixed 480×800 white PNG, encoded without line
wrapping. It is deliberately large enough to exercise multiple 12,000-character
transport chunks. The host test decodes and compares its bytes; it needs no
image-generation dependency.

The fixture was created with ImageMagick using `-size 480x800 xc:white -depth 1
-define png:compression-level=0`, then encoded with coreutils base64. It is
synthetic protocol input, never a screenshot of Android or IB. No acceptance
claim may use it as visible-product evidence.
