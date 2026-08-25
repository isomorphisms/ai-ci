# Finished-video contract

`aici-video` verifies a finished encoded video with FFmpeg and FFprobe. It is an
executable acceptance probe: source files, render logs, manifests, and sidecars
cannot satisfy it in place of the MP4.

The verifier is separate from the dependency-free repository kernel because
decoding a video honestly requires a media implementation. The current action
supports POSIX runners with a C17 compiler, `ffmpeg`, and `ffprobe` on `PATH`.

## Contract format

Contracts are UTF-8, tab-separated files. Blank lines and lines beginning with
`#` are ignored. Every assertion has a unique uppercase diagnostic code.

| Operation | Fields after code | Pass condition |
| --- | --- | --- |
| `video_decode` | `path` | FFmpeg decodes every audio/video stream to completion and treats a decode error as fatal. |
| `video_dimensions` | `path width height` | First video stream has the exact dimensions. |
| `video_duration` | `path minimum maximum` | Container duration is inside the inclusive range in seconds. |
| `video_fps` | `path expected tolerance` | Average video rate differs from expected by no more than the tolerance. |
| `video_audio` | `path present-or-absent` | At least one audio stream exists, or none exists, as declared. |
| `video_encoding` | `path codec pixel-format` | FFprobe names both values exactly. |
| `video_frame_mae` | `path t1 t2 x y width height minimum maximum` | Mean absolute RGB difference between the decoded rectangles is inside the inclusive range from 0 to 255. |

All media paths are relative to the supplied artifact root. Literal empty, `.`,
and `..` path components are rejected. Contract authors should put
`video_decode` first so a corrupt artifact gets the most useful first
diagnostic.

The frame comparison is deliberately neutral. A minimum greater than zero can
require visible change; a small maximum can require a hold. It does not assume
that every frame should move, that every Short should end with a hold, or that a
whole-frame difference proves the intended mathematical object moved. Choose a
rectangle that corresponds to a declared storyboard witness and leave margin
for lossy compression.

Example:

```text
video_decode	SHORT-DECODE	short.mp4
video_dimensions	SHORT-SHAPE	short.mp4	1080	1920
video_duration	SHORT-DURATION	short.mp4	14.8	15.2
video_fps	SHORT-FPS	short.mp4	30	0.01
video_audio	SHORT-AUDIO	short.mp4	present
video_encoding	SHORT-ENCODING	short.mp4	h264	yuv420p
video_frame_mae	PLOT-BUILDS	short.mp4	1.0	5.0	80	300	920	900	2	255
video_frame_mae	FINAL-HOLD	short.mp4	13.5	14.7	80	300	920	900	0	1.5
```

Run it directly:

```text
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 -o /tmp/aici-video src/aici_video.c -lm
/tmp/aici-video verify ci/short.contract.tsv media
```

Or pin the reviewed action commit:

```yaml
- uses: isomorphisms/ai-ci/video@0123456789abcdef0123456789abcdef01234567
  with:
    contract: ci/short.contract.tsv
    root: media
```

## Self-test and false-positive control

`video/tests/make_video_fixtures.c` creates small real H.264 fixtures at test
time. The suite includes a passing video plus targeted failures for decode,
dimensions, duration, frame rate, audio, encoding, required early change, and
required final hold. `aici-video self-test` checks the exact first diagnostic
for each failure and audits that every contract assertion has both positive and
targeted negative coverage.

The suite does not currently gate typography, safe areas, pacing, mathematical
meaning, source grounding, or source-to-artifact freshness. Those need either
episode-specific executable oracles or additional provenance design; a generic
pixel heuristic would create precisely the noisy gate this project is meant to
avoid.
