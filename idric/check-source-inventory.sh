#!/bin/sh
set -eu

inventory=${1:-idric/source-inventory-v1.tsv}
discovered=${2:-idric/discovered-sources.tsv}
receipt=${3:-idric/source-inventory.receipt.tsv}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

[ -f "$inventory" ] || die "Idriç source inventory not found: $inventory"
[ -f "$discovered" ] || die "discovered Idriç source list not found: $discovered"

inventory_header=$(sed -n '1p' "$inventory")
expected_inventory_header=$(printf 'repository\tref\tpath\tpolicy\trole\tnote')
[ "$inventory_header" = "$expected_inventory_header" ] ||
  die "invalid Idriç source inventory header"

discovered_header=$(sed -n '1p' "$discovered")
expected_discovered_header=$(printf 'repository\tref\tpath')
[ "$discovered_header" = "$expected_discovered_header" ] ||
  die "invalid discovered Idriç source header"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

inventory_keys="$tmp_dir/inventory.keys"
discovered_keys="$tmp_dir/discovered.keys"
untracked="$tmp_dir/untracked.keys"
stale="$tmp_dir/stale.keys"

awk -F '\t' '
  NR == 1 { next }
  NF != 6 {
    printf "inventory row %d has %d fields, expected 6\n", NR, NF > "/dev/stderr"
    bad = 1
    next
  }
  $1 == "" || $2 == "" || $3 == "" || $4 == "" || $5 == "" {
    printf "inventory row %d has an empty required field\n", NR > "/dev/stderr"
    bad = 1
  }
  $4 != "follow" && $4 != "review-only" {
    printf "inventory row %d has unknown policy: %s\n", NR, $4 > "/dev/stderr"
    bad = 1
  }
  {
    print $1 "\t" $3
  }
  END { exit bad ? 1 : 0 }
' "$inventory" |
LC_ALL=C sort > "$inventory_keys"

if [ "$(uniq -d "$inventory_keys" | wc -l)" -ne 0 ]; then
  printf 'duplicate repository/path entries in Idriç source inventory:\n' >&2
  uniq -d "$inventory_keys" >&2
  exit 1
fi

awk -F '\t' '
  NR == 1 { next }
  NF != 3 {
    printf "discovered row %d has %d fields, expected 3\n", NR, NF > "/dev/stderr"
    bad = 1
    next
  }
  $1 == "" || $2 == "" || $3 == "" {
    printf "discovered row %d has an empty required field\n", NR > "/dev/stderr"
    bad = 1
  }
  {
    print $1 "\t" $3
  }
  END { exit bad ? 1 : 0 }
' "$discovered" |
LC_ALL=C sort -u > "$discovered_keys"

comm -23 "$discovered_keys" "$inventory_keys" > "$untracked"
comm -13 "$discovered_keys" "$inventory_keys" > "$stale"

inventory_count=$(wc -l < "$inventory_keys" | tr -d ' ')
discovered_count=$(wc -l < "$discovered_keys" | tr -d ' ')
untracked_count=$(wc -l < "$untracked" | tr -d ' ')
stale_count=$(wc -l < "$stale" | tr -d ' ')

status=PASS
if [ "$untracked_count" -ne 0 ] || [ "$stale_count" -ne 0 ]; then
  status=FAIL
fi

{
  printf 'status\tinventory_count\tdiscovered_count\tuntracked_count\tstale_count\n'
  printf '%s\t%s\t%s\t%s\t%s\n' \
    "$status" "$inventory_count" "$discovered_count" "$untracked_count" "$stale_count"
} > "$receipt"

if [ "$untracked_count" -ne 0 ]; then
  printf 'untracked Idriç source files:\n' >&2
  sed 's/^/  /' "$untracked" >&2
fi

if [ "$stale_count" -ne 0 ]; then
  printf 'inventory entries no longer discovered:\n' >&2
  sed 's/^/  /' "$stale" >&2
fi

if [ "$status" = FAIL ]; then
  printf 'Idriç source inventory drift detected; update source-inventory-v1.tsv deliberately.\n' >&2
  exit 1
fi

printf 'Idriç source inventory matches %s discovered files.\n' "$discovered_count"
