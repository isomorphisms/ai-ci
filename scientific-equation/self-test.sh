#!/bin/sh
set -eu
test "$#" -eq 1 || { echo "usage: $0 CHECKED_OUT_IB_ROOT" >&2; exit 2; }
ib=$1
self=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
test -x "${IB_SURFER_PROBE:-}"
test -x "${IB_EXACT_SURFACE_POLICY:-}"
tmp=$(mktemp -d)
server_pid=''
cleanup() {
  if test -n "$server_pid"; then
    kill "$server_pid" >/dev/null 2>&1 || true
  fi
  rm -rf "$tmp"
}
trap cleanup EXIT HUP INT TERM
port=$((21000 + ($$ % 17000)))
busybox httpd -f -p "127.0.0.1:$port" -h "$ib/tests/fixtures/arxiv_site" &
server_pid=$!
sleep 1
export IB_ARXIV_HTML_BASE="http://127.0.0.1:$port/html"
export IB_ARXIV_PDF_BASE="http://127.0.0.1:$port/pdf"

dir="$tmp/positive"
sh "$ib/bin/harvest_arxiv_images.grease" 2401.00001 "$dir"
sh "$ib/bin/accept_scientific_equations.grease" "$dir" real 'W=1'
sh "$self/verify.sh" "$dir"

# Three malicious receipt edits must be rejected by the independent oracle.
for mutation in media link coefficient; do
  awk -F '\t' -v OFS='\t' -v what="$mutation" '
    NR == 2 && what == "media" { $14 = "VERIFIED" }
    NR == 2 && what == "link" { $15 = "surfer://unverified" }
    NR == 2 && what == "coefficient" { $17 = "+1:4,0,0;-1:1,3,0;+1:0,0,4;+1:0,0,1" }
    {print}
  ' "$dir/equations.tsv" > "$dir/equations.tsv.mutant"
  mv "$dir/equations.tsv" "$dir/equations.tsv.good"
  mv "$dir/equations.tsv.mutant" "$dir/equations.tsv"
  if sh "$self/verify.sh" "$dir" >/dev/null 2>&1; then
    echo "BAD: independent verifier accepted mutant $mutation" >&2
    exit 1
  fi
  mv "$dir/equations.tsv.good" "$dir/equations.tsv"
done

# Changed source after extraction must invalidate source provenance.
cp "$dir/document.html" "$dir/document.html.good"
printf '\n<!-- unauthorized change -->\n' >> "$dir/document.html"
if sh "$self/verify.sh" "$dir" >/dev/null 2>&1; then
  echo 'BAD: source edit escaped provenance verification' >&2
  exit 1
fi
mv "$dir/document.html.good" "$dir/document.html"

# Real sign perturbation must not select SURFER for the original equation.
sed 's@- z\^4 + z = 0@+ z^4 + z = 0@g' \
  "$ib/tests/fixtures/arxiv_site/html/2401.00001" > "$tmp/sign-change.html"
mkdir -p "$tmp/sign-change"
cp "$tmp/sign-change.html" "$tmp/sign-change/document.html"
printf 'html\t2401.00001\thttps://arxiv.org/html/2401.00001\t%s\n' \
  "$tmp/sign-change/document.html" > "$tmp/sign-change/source.tsv"
: > "$tmp/sign-change/images.tsv"
sh "$ib/bin/accept_scientific_equations.grease" "$tmp/sign-change" real 'W=1'
test "$(grep -c 'surfer-real-implicit' "$tmp/sign-change/equations.tsv" || true)" = 0

# Equation written solely in image alt text must not be extracted.
mkdir -p "$tmp/image-only"
printf '<html><body><img alt="x^4 - x*y^3 - z^4 + z = 0"></body></html>\n' \
  > "$tmp/image-only/document.html"
printf 'html\t2401.00001\thttps://arxiv.org/html/2401.00001\t%s\n' \
  "$tmp/image-only/document.html" > "$tmp/image-only/source.tsv"
sh "$ib/bin/accept_scientific_equations.grease" "$tmp/image-only" real 'W=1'
test "$(wc -l < "$tmp/image-only/equations.tsv" | tr -d ' ')" = 1

echo 'PASS: independent mutation controls and image impersonation refusal'
