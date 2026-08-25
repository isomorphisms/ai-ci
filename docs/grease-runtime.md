# Grease runtime gate

The intended Grease invocation is:

```text
.grease/source/bin/ysh path/to/check.ysh
```

The canonical upstream extension is `.ysh` and the shebang is
`#!/usr/bin/env ysh`.

As of 2026-08-24, `isomorphisms/grease@main` pins
`isomorphisms/oils@e9a54ad727d89cd593d0bfe56136046808ea81d2`, but a fresh
GitHub Actions runner cannot yet execute it:

1. `source/bin/ysh` is a `/bin/sh` launcher for a Python 2 development
   interpreter, and ordinary runners do not provide `python2`.
2. The attempted native bootstrap reaches `build/py.sh minimal` but fails
   because `readline/readline.h` is unavailable.

Current repositories also contain misleading conventions that must not become
the ai-ci foundation:

- files named `*.grease` with `#!/bin/sh`, executed with `sh`;
- YSH-shebang scripts syntax-checked or executed with Bash;
- workflow path filters that omit the checks they supposedly protect.

The v0 native verifier is therefore deliberate. It provides real gates now
without calling Bash or Python “Grease.” The Grease command layer becomes
eligible only when this acceptance case passes on a clean runner:

1. obtain the pinned Grease source;
2. build or obtain a pinned native YSH runtime;
3. execute a `.ysh` smoke program with that runtime;
4. execute the ai-ci positive and negative fixtures through that runtime;
5. fail if any workflow invokes a Grease/YSH file through `bash` or `sh`.
