#!/bin/sh

set -eu

manifest=${1:-idric/current-heads-v1.tsv}
receipt=${2:-idric/current-heads.receipt.tsv}
tab=$(printf '\t')
failures=0

header=$(sed -n '1p' "$manifest")
expected="lane${tab}repository${tab}requested_ref${tab}role${tab}receipt_owner"
[ "$header" = "$expected" ] || {
  printf 'invalid current-head manifest header\n' >&2
  exit 2
}

temporary="${receipt}.tmp.$$"
trap 'rm -f -- "$temporary"' EXIT HUP INT TERM
printf 'lane\trepository\trequested_ref\tresolved_sha\trole\tselection_status\tdiagnostic\n' > "$temporary"

tail -n +2 "$manifest" |
while IFS="$tab" read -r lane repository requested_ref role receipt_owner extra; do
  if [ -z "$lane" ] || [ -z "$repository" ] || [ -z "$requested_ref" ] ||
     [ -z "$role" ] || [ -z "$receipt_owner" ] || [ -n "${extra:-}" ]; then
    printf 'malformed current-head row for lane %s\n' "${lane:-unknown}" >&2
    exit 2
  fi
  resolved=$(git ls-remote --exit-code --heads "https://github.com/$repository.git" "refs/heads/$requested_ref" 2>/dev/null | awk 'NR == 1 { print $1 }') || resolved=
  if [ -n "$resolved" ]; then
    printf '%s\t%s\t%s\t%s\t%s\tPASS\tresolved; compatibility owned by %s\n' \
      "$lane" "$repository" "$requested_ref" "$resolved" "$role" "$receipt_owner"
  else
    printf '%s\t%s\t%s\t-\t%s\tFAIL\tdeclared ref not found; compatibility SKIP\n' \
      "$lane" "$repository" "$requested_ref" "$role"
    exit 1
  fi
done >> "$temporary" || failures=1

mv "$temporary" "$receipt"
trap - EXIT HUP INT TERM
cat "$receipt"
exit "$failures"
