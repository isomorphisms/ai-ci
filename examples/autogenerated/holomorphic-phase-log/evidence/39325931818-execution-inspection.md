# Actual 937 artifact, publication and capture inspection

Application: `937a7aa0cfbec32d527b8bd44f3da63a6c76c82b`.
Checked workflow: https://github.com/isomorphismes/holomorphic/actions/runs/39325931818
Generated APK job: `118323257083`; emulator: `118324870950`;
qualification publication and Cat Food: `118325610641`. All completed successfully.
Inspection date: 2026-10-19. Runtime observations concern Android Emulator with
Google SwiftShader, not a physical GPU.

## Original captures and measured differences

Original PNGs remain unchanged under
`/workspace/scratch/3e66f41b73d4/final-937-emulator/`:

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| generated-holomorphic-frame-a.png | 396797 | 3c36ff1b35f23e40c3606e36ff92f6454a4657d7248fdb01fd607af7f329db20 |
| generated-holomorphic-frame-b.png | 396782 | 18d2cb32e46a73e50bb285c832510e4f68006a795d45b363c6021e0d19003425 |

Both are 2400 × 1080, 8-bit PNGs. ImageMagick 6.9.12-98 `compare` measured
differences without fuzz, using output destination `null:` and precision 16.
Return status 1 indicates differing images. Hashes were rechecked after all
measurements and remained identical; no modified image was written.

| Measurement | Result |
| --- | ---: |
| Whole image absolute-error pixel count | 117 / 2592000 |
| Interior rectangle 1600 × 700 at x=200, y=100 | 51 / 1120000 |
| Rectangle 400 × 250 at x=200, y=100, away from controls and divisor markers | 7 / 100000 |
| Default-channel normalized RMSE in the smaller rectangle | 0.00001894297613880972 |

This current pair is nearly static. These tiny pixel differences do not
establish meaningful animation, motion continuity, frame rate, or speed. The
larger differences in the previous f2ef capture pair belong to that earlier
run and are not promoted to this source head.

## Actual timing scope

The original log is
`/workspace/scratch/3e66f41b73d4/final-937-emulator/generated-holomorphic-emulator.log`.
It records CPU wall times:

| Operation | Milliseconds | GPU time |
| --- | ---: | --- |
| Vertex compilation | 0.905989 | NOT_RUN |
| Fragment compilation | 41.571517 | NOT_RUN |
| Program link | 4.672331 | NOT_RUN |

No `HOLO_FRAME_TIMING` or generic `EGL_emulation app_time_stats` row was observed
in this capture. Numerical readback timings are explicitly `readback_cpu_ms`
and do not isolate GPU execution. GPU timing, thermal behavior, many-factor
throughput, CPU-search/presentation separation and sustained performance remain
unqualified. No speed inference is drawn from successful compilation or tests.

## Actual signed APK contents

Artifact `12223314266`: ZIP 111338 bytes, SHA-256
`db07187a5aac6133b8c4c10ed9f7c5b57a0771cfa4cb4e8db1a4bf92a3dbcb38`.
Actual APK:
`/workspace/scratch/3e66f41b73d4/holo937-generated-apk/android/app/build/outputs/apk/debug/app-debug.apk`.

The APK is 253886 bytes, SHA-256
`934bd35433fa995503a59d5fce90bef1d48454ba6c1a3f740d5394f0135ae3fa`.
Embedded fragment and provenance compare byte-for-byte equal to actual qualified
generation artifact `12223512930`, extracted at
`/workspace/scratch/3e66f41b73d4/holo937-generated-fragment/`.
Fragment: 30577 bytes, SHA-256
`1e35d1ae21f01e0f499152511f9fac4bc0f38d854ebd2a7927a4f1e4ffce8f17`.
The generated binding requires generated mode and binds application 937a7aa0
and backend `8ecb501375110cb326e7fecb109f794185382112`.

Actual packed libraries were extracted and inspected with `readelf`; none contain
`.symtab` or `.debug_*` sections:

| ABI | ELF identity | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| armeabi-v7a | ELF32 ARM | 53912 | 86bc3134cfc88eb2a96710d649de7c427ab6085db9dd766c45541911192bda7f |
| arm64-v8a | ELF64 AArch64 | 67040 | 0a016489f14645b7015f96bc1c6c568f23e22f12f9430addc0fadf76b5e3cf97 |
| x86_64 | ELF64 AMD x86-64 | 69472 | 0fd3e08c1d39d6e82ee50df87f1623dbae61b46339c18c687b7cada48904d4a8 |

Hosted actual `aapt2`/`apksigner` records package
`org.isomorphisms.analyticcontinuation.lasso.dev`, version code 3,
version name `0.2.1-dev`, and one verified APK-v2 signer SHA-256
`27eee69b1cbeebc30eab35fe7eb5459c542784b4ccc68453a372cb6802ccf7cf`.
Local inspection rechecked actual APK/native/asset bytes; unavailable local
Android SDK tools were not represented as rerun.

## Publication and Cat Food receipts

Publication artifact `12224445836`: ZIP 10050 bytes, SHA-256
`f8096cb5edb7a959dd7a69899f23f9bff58461d28b7e99818575b3174cb71e11`.
Extracted receipts:
`/workspace/scratch/3e66f41b73d4/holo937-publication/`.

Public prerelease ID `417788505` has exact source 937a7aa0, APK asset `657521484`
and signed-producer receipt asset `657521531`. The receipt SHA-256 is
`1301c305715647b830310f854277bca0caac0bf0e104164adbab4704b525107d`.
Its producer prefix compares byte-for-byte equal to the original signed APK
producer identity from the build artifact. The hosted publisher also downloaded
and compared actual uploaded assets before publication.

`qualification-catfood-acquisition/acquisition.tsv` records real host file-mode
acquisition through Cat Food commit
`b387f90d3973aae39ba19d370a830da627299ab1`, with the same APK hash and length.
The original Cat Food receipt SHA-256 is
`6a9bb3b46dee8a6fc29fc630ae63d9d41c8e6c20093f2eab497d46fee33c7526`.
Its Android identity is explicitly the synthetic host-only test fixture,
command exposure is DEFERRED, and Android package installation is NOT_RUN.
Its file-prefix installation result is not a claim of installation on the A1,
C67, or TAB_P10.

Independent phase/log/RGBA8/runtime-source acceptance belongs to the separate
exact Ithon/AICI audit. Physical A1/GE8322, C67/GE8320, TAB_P10/Mali-G57 and
sustained performance remain NOT_RUN.
