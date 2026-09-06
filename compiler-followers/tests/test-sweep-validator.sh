#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
exec python3 "$root/test_sweep_validator.py"
