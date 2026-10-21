#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
check="$root/idric/check-source-inventory.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

write_inventory() {
  file=$1
  shift
  {
    printf 'repository\tref\tpath\tpolicy\trole\tnote\n'
    for row in "$@"; do
      printf '%s\n' "$row"
    done
  } > "$file"
}

write_discovered() {
  file=$1
  shift
  {
    printf 'repository\tref\tpath\n'
    for row in "$@"; do
      printf '%s\n' "$row"
    done
  } > "$file"
}

expect_fail() {
  name=$1
  inventory=$2
  discovered=$3
  if sh "$check" "$inventory" "$discovered" "$tmp/$name.receipt.tsv" >/dev/null 2>&1; then
    printf '%s unexpectedly passed\n' "$name" >&2
    exit 1
  fi
}

inventory="$tmp/inventory.tsv"
discovered="$tmp/discovered.tsv"

write_inventory "$inventory" \
  "$(printf 'example/repo\tmain\tsrc/Main.idric\tfollow\tprogram\tcurrent program')" \
  "$(printf 'example/repo\tmain\ttests/old.idric\treview-only\thistorical-snapshot\told source')"
write_discovered "$discovered" \
  "$(printf 'example/repo\tmain\tsrc/Main.idric')" \
  "$(printf 'example/repo\tmain\ttests/old.idric')"

sh "$check" "$inventory" "$discovered" "$tmp/good.receipt.tsv" >/dev/null
grep -F "$(printf 'PASS\t2\t2\t0\t0')" "$tmp/good.receipt.tsv" >/dev/null

write_discovered "$tmp/untracked.tsv" \
  "$(printf 'example/repo\tmain\tsrc/Main.idric')" \
  "$(printf 'example/repo\tmain\ttests/old.idric')" \
  "$(printf 'example/repo\tmain\tsrc/New.idric')"
expect_fail untracked "$inventory" "$tmp/untracked.tsv"

write_discovered "$tmp/stale.tsv" \
  "$(printf 'example/repo\tmain\tsrc/Main.idric')"
expect_fail stale "$inventory" "$tmp/stale.tsv"

write_discovered "$tmp/ref-drift.tsv" \
  "$(printf 'example/repo\tnext\tsrc/Main.idric')" \
  "$(printf 'example/repo\tmain\ttests/old.idric')"
expect_fail ref-drift "$inventory" "$tmp/ref-drift.tsv"

write_inventory "$tmp/bad-policy.tsv" \
  "$(printf 'example/repo\tmain\tsrc/Main.idric\tmaybe\tprogram\tbad policy')"
write_discovered "$tmp/one.tsv" \
  "$(printf 'example/repo\tmain\tsrc/Main.idric')"
expect_fail bad-policy "$tmp/bad-policy.tsv" "$tmp/one.tsv"

write_inventory "$tmp/duplicate.tsv" \
  "$(printf 'example/repo\tmain\tsrc/Main.idric\tfollow\tprogram\tone')" \
  "$(printf 'example/repo\tmain\tsrc/Main.idric\tfollow\tprogram\ttwo')"
expect_fail duplicate "$tmp/duplicate.tsv" "$tmp/one.tsv"

printf 'Idriç source inventory self-test PASS\n'
