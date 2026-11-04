# Independent autofile API acceptance

This checker links the exact candidate library but imports none of its tests or
expected outputs. It independently supplies transport observations and checks:

- one exact non-retryable PATCH followed by a matching post-read;
- rejection of a 2xx response whose post-read still shows the old state;
- rejection of stale source membership before mutation;
- rejection of a response bound to another workspace; and
- rejection of a mismatched approval digest before network access.

The maintained workflow compiles both this checker and the candidate through the
pinned ICK producer. These are synthetic transport facts. They do not establish
browser authentication, a live private endpoint, a real-account move or
physical-device behavior.

