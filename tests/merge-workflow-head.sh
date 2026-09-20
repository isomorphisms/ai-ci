#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
checker=${1:-"$root/merge/check-workflow-head.sh"}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM

good=$work/good.yml
bad=$work/bad.yml
dependency_only=$work/dependency-only.yml

printf '%s\n' \
    'on:' \
    '  pull_request:' \
    'jobs:' \
    '  verify:' \
    '    steps:' \
    '      - uses: actions/checkout@pinned' \
    '        with:' \
    '          ref: ${{ github.event.pull_request.head.sha || github.sha }}' \
    '          persist-credentials: false' \
    '      - uses: actions/checkout@pinned' \
    '        with:' \
    '          repository: example/dependency' \
    '          ref: 1111111111111111111111111111111111111111' > "$good"

printf '%s\n' \
    'on:' \
    '  pull_request:' \
    'jobs:' \
    '  verify:' \
    '    steps:' \
    '      - uses: actions/checkout@pinned' > "$bad"

printf '%s\n' \
    'on:' \
    '  pull_request:' \
    'jobs:' \
    '  verify:' \
    '    steps:' \
    '      - uses: actions/checkout@pinned' \
    '        with:' \
    '          repository: example/dependency' \
    '          ref: 1111111111111111111111111111111111111111' > "$dependency_only"

"$checker" "$good" | grep -F 'PASS' >/dev/null
if "$checker" "$bad" > "$work/bad.out"; then
    echo 'default synthetic checkout was accepted' >&2
    exit 1
fi
grep -F 'CI-EXACT-HEAD-CHECKOUT-MISSING' "$work/bad.out" >/dev/null

if "$checker" "$dependency_only" > "$work/dependency.out"; then
    echo 'dependency checkout was mistaken for the PR source checkout' >&2
    exit 1
fi
grep -F 'CI-EXACT-HEAD-PRIMARY-CHECKOUT-MISSING' "$work/dependency.out" >/dev/null

printf '%s\n' 'exact-head workflow fixtures pass'
