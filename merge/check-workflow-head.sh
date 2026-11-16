#!/bin/sh
# Existing POSIX compatibility entrypoint; all policy lives in the C kernel.
set -eu
if [ "$#" -eq 0 ]; then
    echo 'usage: merge/check-workflow-head.sh WORKFLOW [...]' >&2
    exit 2
fi
if [ -z "${AICI_BIN:-}" ] || [ ! -x "$AICI_BIN" ]; then
    echo 'CI-EXACT-HEAD-VERIFIER-MISSING: AICI_BIN must name the qualified C verifier' >&2
    exit 2
fi
exec "$AICI_BIN" workflow-head "$@"
