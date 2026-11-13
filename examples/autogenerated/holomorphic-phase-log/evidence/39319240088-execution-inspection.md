# Actual f2ef artifact and capture inspection

Application: `f2ef44e348bc37c90c1da951632c4fb1f5466c7d`.
Checked workflow: https://github.com/isomorphismes/holomorphic/actions/runs/39319240088
Original generated APK job: `118305016491`; original emulator job: `118306493311`.
Inspection date: 2026-10-19. These observations concern the Android emulator using
Google SwiftShader; they are not physical-device qualification.

## Original captures

Both original files remain unchanged in
`/workspace/scratch/3e66f41b73d4/final-f2ef-emulator/`:

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| generated-holomorphic-frame-a.png | 396782 | 18d2cb32e46a73e50bb285c832510e4f68006a795d45b363c6021e0d19003425 |
| generated-holomorphic-frame-b.png | 377117 | 456e9cf3b4231ef3361fd55d61ab05b1510d71eadf15e1727acc30e709617a5d |

ImageMagick `identify` reports both as 2400 × 1080, 8-bit sRGBA PNGs.
ImageMagick 6.9.12-98 `compare` measured differences with no fuzz and output
destination `null:`. A return status of 1 indicates differing pixels. Original
file hashes were rechecked after measurement and remained identical.

| Read-only measurement | Result |
| --- | ---: |
| Whole image absolute-error pixel count | 2587320 / 2592000 |
| Interior rectangle 1600 × 700 at x=200, y=100 | 1119793 / 1120000 |
| Rectangle 400 × 250 at x=200, y=100, away from controls and divisor markers | 100000 / 100000 |
| Default-channel normalized RMSE in that smaller rectangle | 0.08087058500250018 |

The smaller rectangle contains mathematical-field pixels away from the visible
controls and zero/pole markers. Its changes establish a field-image difference
between two captures. Two stills do not establish motion continuity, frame rate,
GPU speed, or sustained behavior. No difference image or modified capture was
written.

## Actual timing scope

The original `generated-holomorphic-emulator.log` records CPU wall times:

| Operation | Milliseconds | GPU time |
| --- | ---: | --- |
| Vertex compilation | 0.829659 | NOT_RUN |
| Fragment compilation | 24.343892 | NOT_RUN |
| Program link | 3.676125 | NOT_RUN |

An emulator `EGL_emulation app_time_stats` line reports average 2791.64 ms,
minimum 2766.41 ms, maximum 2816.87 ms, count 2. This is an emulator presentation
observation, not GPU timing. Numerical sample timings are explicitly
`readback_cpu_ms`; they do not isolate GPU execution. There is no qualified GPU
time, thermal measurement, many-factor throughput result, CPU-search separation,
or sustained-performance acceptance in these captures.

## Actual signed APK contents

Downloaded artifact `12220889548` is 111335 bytes with ZIP SHA-256
`5ac170e1bcde06e9d256d8ad3ed750635ddc51c1b8ac246bda951160c3d98091`.
The extracted APK is at
`/workspace/scratch/3e66f41b73d4/holof2ef-generated-apk/android/app/build/outputs/apk/debug/app-debug.apk`.

The APK is 253882 bytes, SHA-256
`c2199b4ca49576ec181cd67947dd6fa2daa371331bf5ce7b886742d725cbda4d`.
Its embedded fragment and provenance compare byte-for-byte equal to the actual
qualified generated artifact `12221731335`. The fragment is 30577 bytes, SHA-256
`1e35d1ae21f01e0f499152511f9fac4bc0f38d854ebd2a7927a4f1e4ffce8f17`.
The generated header requires generated mode and binds this application commit
and backend `8ecb501375110cb326e7fecb109f794185382112`.

Actual extracted native libraries were inspected with `readelf`; none contain
`.symtab` or `.debug_*` sections:

| ABI | ELF identity | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| armeabi-v7a | ELF32 ARM | 53912 | 5e6036f9b79861f8dfc255c6a215a05f7d0278913fc4b3b78028d7964273c2cc |
| arm64-v8a | ELF64 AArch64 | 67040 | 4b00827b1927029a69de062fdb06900d9bcc024e0565d8a9e359fb3944a6989d |
| x86_64 | ELF64 AMD x86-64 | 69472 | 73b415d47ae642c5fec526a9da8ffe8b9ec44389f0ad3f6b367db75e28316a84 |

Hosted actual `aapt2`/`apksigner` output records package
`org.isomorphisms.analyticcontinuation.lasso.dev`, version code 3, version name
`0.2.1-dev`, one verified APK-v2 signer SHA-256
`27eee69b1cbeebc30eab35fe7eb5459c542784b4ccc68453a372cb6802ccf7cf`.
The local inspection rechecked actual APK/native/asset bytes; it did not rerun
the unavailable local Android SDK signature tools.

Independent numerical, colour, and runtime-source acceptance belongs to the
separate exact Ithon/AICI audit. Physical A1/GE8322, C67/GE8320,
TAB_P10/Mali-G57 and sustained performance remain NOT_RUN.
