#!/bin/sh
set -eu

syllabus_repo=${SYLLABUS_REPO:-https://github.com/bl4ckb4ll/syllabus.git}
blackball_repo=${BLACKBALL_REPO:-https://github.com/bl4ckb4ll/blackball.git}
syllabus_ref=${SYLLABUS_REF:-main}
blackball_ref=${BLACKBALL_REF:-main}
collection=${LIFE_CHANGING_MATHEMATICS_PATH:-life-changing mathematics}

tmp=$(mktemp -d "${TMPDIR:-/tmp}/aici-life-changing-mathematics.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

clone_ref() {
    repo=$1
    ref=$2
    dest=$3
    git clone --quiet --depth 1 --single-branch --branch "$ref" "$repo" "$dest"
}

clone_ref "$syllabus_repo" "$syllabus_ref" "$tmp/syllabus"
clone_ref "$blackball_repo" "$blackball_ref" "$tmp/blackball"

left="$tmp/syllabus/$collection"
right="$tmp/blackball/$collection"

if [ ! -d "$left" ]; then
    echo "FAIL: syllabus is missing '$collection' at $syllabus_ref" >&2
    exit 1
fi

if [ ! -d "$right" ]; then
    echo "FAIL: blackball is missing '$collection' at $blackball_ref" >&2
    exit 1
fi

left_sha=$(git -C "$tmp/syllabus" rev-parse "HEAD:$collection")
right_sha=$(git -C "$tmp/blackball" rev-parse "HEAD:$collection")

if [ "$left_sha" = "$right_sha" ]; then
    echo "PASS: life-changing mathematics mirrors match ($left_sha)"
    exit 0
fi

echo "FAIL: life-changing mathematics mirrors differ" >&2
echo "syllabus $syllabus_ref: $left_sha" >&2
echo "blackball $blackball_ref: $right_sha" >&2
LC_ALL=C diff -ru "$left" "$right" || true
exit 1
