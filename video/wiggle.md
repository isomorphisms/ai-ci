# Independent wiggle candidate gate

`wiggle.pi OUTPUT INDEPENDENT_CONTRACT` checks retained trace and checkpoint
hashes, exact frame count/names/dimensions, actual PPM bytes and hashes, MP4
hash/count/dimensions/rational fps/audio presence, full FFmpeg decode and the
mean RGB error between each decoded frame and its corresponding source still.
It imports no Kitchen producer code. `test-wiggle.pi` generates explicit
synthetic color test images, assembles them through canonical Kitchen, and
requires specific rejection diagnostics for changed input/frame/movie and
reordered source frames, even with a matching reordered hash manifest.

The independent contract is TSV: scope=offline-media, maximum_rgb_mae, plus
expected SHA-256 for trace/run.tsv, controls.tsv, events.tsv, inputs.tsv,
tools.tsv, sources.tsv (each with trace/ prefix), timeline.tsv and states.tsv.
Trusted acceptance must supply those expectations from its own source/domain
oracle; copying the producer's own output hashes is a fixture convenience,
not independent mathematical verification.

The result is deliberately scoped to retained-frame/media integrity. It does
not certify the application equation, group, Fourier coefficients, physics,
renderer/compiler provenance, recorded gesture authenticity, audio sample
alignment, physical capture, Android behavior, or complete SUN assignment.
The current per-frame decoder process is suitable for bounded test movies;
large-stream qualification remains pending. No action or global required gate
has been promoted from this candidate.
