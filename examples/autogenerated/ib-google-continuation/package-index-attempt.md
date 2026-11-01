# Extra-package source refresh

The Google continuation inspector failed before reading any original response:
its declared libxml2-utils install returned100/Unable to locate package on
both APIs. The same signed custom source exists (the guard passes), but the
preceding literal-verifier step refreshed the runner's different default apt
sources. The maintained extra-packages owner now refreshes its own declared
signed source indexes immediately before installing packages. It preserves
the fixed deadlines, HTTPS source/keyring, retries and refusal status.

This repairs a reusable dependency contract rather than substituting an HTML
parser or swallowing apt failure. The original failed run41329752193 remains
failed evidence. Validation is the actual inspector stage and parser/version
receipt on the next source-bound run; no package success or Google result is
inferred at authoring. No device or user data is changed.
