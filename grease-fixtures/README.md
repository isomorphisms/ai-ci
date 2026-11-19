# Grease host fixtures

Delivery, requirement binding, transfer handoff, framebuffer-stack and Subpixel
use the same source build for their Linux x86_64 fixtures. The action checks its
checkouts against the immutable inputs from [the Oils owner run](https://github.com/dilapidated-shed/oils/actions/runs/43791153450).
The checked Ithon adapter invokes the owner's Icky DMD bootstrap and the
matching druntime and Phobos build recipes. The fixture shell links through that
Icky DMD. The Ubuntu LDC package bootstraps the compiler.

Each caller receives an executable named `grease` and a build receipt from its
runner. The receipt includes source revisions, the actual compiler, library and
executable digests, the link command and observed loader dependencies. A missing
compiler, failed build or unexpected runtime identity stops the caller.

The runtime is the partial native D translation, scoped to the fixture suites
that execute here. Whole language qualification and managed runtime admission
require their own evidence. The transfer suite inspects the published ARM
packages as bytes and uses a synthetic GitHub fixture for its transfer effects.
