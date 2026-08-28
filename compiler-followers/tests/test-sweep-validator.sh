#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

git init -q "$tmp/upstream"
git -C "$tmp/upstream" config user.name test
git -C "$tmp/upstream" config user.email test@example.invalid
printf one > "$tmp/upstream/probe"
git -C "$tmp/upstream" add probe
git -C "$tmp/upstream" commit -qm one
from=$(git -C "$tmp/upstream" rev-parse HEAD)
printf two >> "$tmp/upstream/probe"
git -C "$tmp/upstream" commit -qam two
through=$(git -C "$tmp/upstream" rev-parse HEAD)

mkdir "$tmp/receipt"
policy_hash=$(sha256sum "$root/compiler-followers/policy.tsv" | awk '{print $1}')
{
  printf 'field\tvalue\n'
  printf 'receipt_version\t1\n'
  printf 'upstream_repository\tisomorphisms/idric-arm-thumb\n'
  printf 'from\t%s\n' "$from"
  printf 'through\t%s\n' "$through"
  printf 'policy_sha256\t%s\n' "$policy_hash"
  printf 'coverage\tfull-policy-matrix\n'
} > "$tmp/receipt/meta.tsv"
printf 'commit\tdimensions\ttarget\toutcome\trationale\n' > "$tmp/receipt/classifications.tsv"

if UPSTREAM_GIT="$tmp/upstream" sh "$root/compiler-followers/validate-sweep.sh" "$root/compiler-followers/policy.tsv" "$tmp/receipt" "$from" "$through"; then
  echo 'incomplete classification matrix was accepted' >&2
  exit 1
fi

if UPSTREAM_GIT="$tmp/upstream" sh "$root/compiler-followers/validate-sweep.sh" "$root/compiler-followers/policy.tsv" "$tmp/receipt" "$through" "$through"; then
  echo 'receipt with a forged starting checkpoint was accepted' >&2
  exit 1
fi

echo 'unsafe sweep receipts rejected'
