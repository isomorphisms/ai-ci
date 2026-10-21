#!/bin/sh
# Independent, bounded AI-CI witness: not an IB source-side assertion.
# Inspect both the extracted document and the derived receipt from scratch.
set -eu
test "$#" -eq 1 || { echo "usage: $0 IB_HARVEST_DIRECTORY" >&2; exit 2; }
dir=$1
test -s "$dir/source.tsv"
test -s "$dir/document.html"
test -s "$dir/equations.tsv"
command -v xmlstarlet >/dev/null
doc="$dir/document.html"
doc_sha=$(sha256sum "$doc" | awk '{print $1}')
source_sha=$(sha256sum "$dir/source.tsv" | awk '{print $1}')
url=$(awk -F '\t' 'NR == 1 { print $3 }' "$dir/source.tsv")
document=$(awk -F '\t' 'NR == 1 { print $4 }' "$dir/source.tsv")
test "$document" = "$doc"

# Independently recover the first exact source formula, not an image alt.
source_expr=$(xmlstarlet fo --html --recover --dropdtd "$doc" 2>/dev/null |
  xmlstarlet sel -t -v 'string((//*[local-name()="math"])[1]/@alttext)' -n -)
test "$source_expr" = 'x^4 - x*y^3 - z^4 + z = 0'
math_count=$(xmlstarlet fo --html --recover --dropdtd "$doc" 2>/dev/null |
  xmlstarlet sel -t -v 'count(//*[local-name()="math"])' -n -)
test "$math_count" = 5

# This oracle fixes coefficient signs, degrees and a value/gradient:
# F(2,3,4) = -290; grad F(2,3,4) = (5,-54,-255).
# These numbers are independent of the SURFER parser's output.
awk -F '\t' -v docsha="$doc_sha" -v sourcesha="$source_sha" -v sourceurl="$url" '
  BEGIN { correct = "+1:4,0,0;-1:1,3,0;-1:0,0,4;+1:0,0,1" }
  NR == 1 {
    if ($1 != "ordinal" || $8 != "raw_formula" ||
        $16 != "settings" || $17 != "normalized_sparse") exit 1
    next
  }
  {
    if (NF != 17 || $1 != NR-1 || $2 != "2401.00001" ||
        $3 != sourceurl || $4 != docsha || $5 != sourcesha ||
        $6 != "math[" (NR-1) "]" || $9 != "real" || $10 != "W=1" ||
        $14 != "NOT_VERIFIED" || $15 != "BLOCKED_NO_EXACT_RESTORE") exit 1
  }
  NR == 2 {
    if ($7 != "math-alttext" ||
        $8 != "x^4 - x*y^3 - z^4 + z = 0" ||
        $11 != "EXACT" || $17 != correct ||
        $12 !~ /^ENGINE_HOST_PROBE_ONLY;pixels=1024;foreground=[1-9]/ ||
        $13 != "surfer-real-implicit" || $16 !~ /unit-sphere-clip/) exit 1
    x = 2; y = 3; z = 4
    if (x^4 - x*y^3 - z^4 + z != -290 ||
        4*x^3-y^3 != 5 || -3*x*y^2 != -54 || -4*z^3+1 != -255)
      exit 1
  }
  NR == 3 { if ($11 != "changed_polynomial" || $13 != "unsupported" || $17 != "") exit 1 }
  NR == 4 { if ($11 != "changed_polynomial" || $13 != "unsupported" || $17 != "") exit 1 }
  NR == 5 { if ($11 != "parse_error" || $13 != "unsupported" || $17 != "") exit 1 }
  NR == 6 { if ($11 != "conflicting_math_sources" || $13 != "unsupported" || $17 != "") exit 1 }
  END { if (NR != 6) exit 1 }
' "$dir/equations.tsv"

# Exact equation in unrelated image alt is not evidence of a render.
test "$(wc -l < "$dir/images.tsv" | tr -d ' ')" = 1
grep -F 'x^4 - x*y^3 - z^4 + z = 0' "$dir/images.tsv" >/dev/null
! grep -Eq '(\.png|\.mp4|surfer://|https://.*surfer)' "$dir/equations.tsv"
echo 'PASS: independent IB exact-equation host receipt'
echo 'NOT_RUN: finished still, movie, Android exact-restore, physical device'
