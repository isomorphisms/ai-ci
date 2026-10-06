#!/bin/sh
# Compatibility entrypoint. v1 sidecars are no longer producer authority.
exec grease "$(dirname "$0")/check.ysh" "$@"
