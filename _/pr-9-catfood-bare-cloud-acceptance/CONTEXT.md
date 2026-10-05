# Historical context

This work was originally paired with Cat Food PR #16, **“Build and verify the Idriç workbench tuple.”**

Cat Food #16 tried to strengthen construction and provenance inside Cat Food itself: build a coherent tuple, bind downstream builds to the exact Idriç revision, record receipts, check source/release freshness, and make the pinned Chez runtime available.

ai-ci #9 attacked the other side of the boundary. It started outside Cat Food with a nearly bare Ubuntu container, ran the documented Cat Food path, then used ai-ci-owned fixtures to ask whether the resulting programs actually worked.

That separation was intentional. A producer's own build log is useful evidence, but it is not the same thing as an independent consumer starting clean and proving that the promised environment can be reproduced.

The PR also tried to avoid two forms of false confidence:

- **hidden repair:** the acceptance job was not allowed to compile a missing Cat Food artifact and then pass;
- **network luck:** ICU used a small loopback HTTP server with exact expected output instead of depending on an external site.

There were no top-level PR comments or inline review threads at archival time. The design rationale is therefore carried by the PR description, the fixture runner, the workflow, and the fixtures themselves.
