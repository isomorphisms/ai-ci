#!/bin/sh
set -eu
root=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM
body="$root/testcases/fixture.html"
golden="$root/testcases/fixture.prepaint"
cp "$golden" "$work/candidate"
key=fixture:aici-html
generation=generation-1
{
  printf 'source_key\t%s\n' "$key"
  printf 'source_generation\t%s\n' "$generation"
  printf 'source_sha256\t%s\n' "$(sha256sum "$body" | cut -d ' ' -f 1)"
  printf 'source_bytes\t%s\n' "$(wc -c < "$body" | tr -d '[:space:]')"
} > "$work/receipt.tsv"
run_good() {
  sh "$root/verify.sh" "$work/candidate" "$golden" "$work/receipt.tsv" "$body" "$key" "$generation"
}
reject() {
  name=$1
  if run_good > "$work/out" 2> "$work/err"; then
    printf 'aici ib-prepaint: accepted mutant %s\n' "$name" >&2
    exit 1
  fi
  printf 'aici-refusal\t%s\tPASS\n' "$name"
}
run_good
sed 's@^heading\t1\t@heading\t2\t@' "$golden" > "$work/candidate"
reject changed_heading
sed 's@https://example.com/next@https://example.com/other@' "$golden" > "$work/candidate"
reject changed_link
sed '/^text\tOne/d' "$golden" > "$work/candidate"
reject dropped_text
sed 's@^heading\t1\t@heading\t7\t@' "$golden" > "$work/candidate"
reject invalid_heading
sed 's@^title\tExample@title\tbad\\q@' "$golden" > "$work/candidate"
reject malformed_escape
cp "$golden" "$work/candidate"
key=fixture:changed-identity
reject changed_source_identity
key=fixture:aici-html
generation=generation-2
reject stale_generation
generation=generation-1
printf '\377' > "$work/bad.html"
body="$work/bad.html"
reject corrupted_source
body="$root/testcases/fixture.html"
sed 's@^source_bytes.*@source_bytes\t999999@' "$work/receipt.tsv" > "$work/altered"
mv "$work/altered" "$work/receipt.tsv"
reject changed_count
printf 'aici-ib-prepaint-self-test\tPASS\n'
