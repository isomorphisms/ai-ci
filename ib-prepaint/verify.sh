#!/bin/sh
# Independent acceptance of a generated ib-prepaint complete V1 witness.
# Receipts are matched to the *separately supplied* retained source bytes.
# Does not parse HTML or call the IB producer. No network.
set -eu
test "$#" -eq 6 || { echo 'usage: verify.sh PREPAINT GOLDEN SOURCE_RECEIPT BODY KEY GENERATION' >&2; exit 2; }
candidate=$1
golden=$2
receipt=$3
body=$4
key=$5
generation=$6
fail() { printf 'aici ib-prepaint: REFUSED (%s)\n' "$1" >&2; exit 1; }
for file in "$candidate" "$golden" "$receipt" "$body"; do
  test -f "$file" && test ! -L "$file" || fail missing_or_symlinked_input
done
test "$(wc -c < "$candidate" | tr -d '[:space:]')" -le 4194304 || fail oversized_projection
test "$(wc -c < "$receipt" | tr -d '[:space:]')" -le 4096 || fail oversized_receipt
LC_ALL=C awk -F '\t' '
  function refuse() { bad=1; exit 1 }
  function ok_escape(s, i, c, d, slash) {
    slash=sprintf("%c",92)
    for (i=1; i<=length(s); i++) {
      c=substr(s,i,1)
      if (c==slash) {
        ++i
        d=substr(s,i,1)
        if (d!="n" && d!="r" && d!="t" && d!=slash) return 0
      }
    }
    return 1
  }
  function valid_address(s) {
    return s ~ /^https?:\/\/[^[:space:]]+/ && s !~ /[[:space:]]/
  }
  { if (index($0,sprintf("%c",13))) refuse()
    for (i=1;i<=NF;i++) if (!ok_escape($i)) refuse()
    if (state == 0) {
      if (NF!=2 || $1!="ib-prepaint" || $2!="1") refuse()
      state=1; next
    }
    if (state == 1) {
      if (NF!=3 || $1!="revision" || $2 !~ /^[0-9]+$/ ||
        $3!="complete" || ++revision_count>1) refuse()
      state=2; next
    }
    if (state == 2) {
      if (NF!=2 || $1!="requested-url" || !valid_address($2)) refuse()
      state=3; next
    }
    if (state == 3) {
      if (NF!=2 || $1!="resolved-url" || !valid_address($2)) refuse()
      state=4; next
    }
    if (state == 4) {
      if (NF!=2 || $1!="title") refuse()
      state=5; next
    }
    if ($1=="end") {
      if (NF!=1) refuse()
      state=6; next
    }
    if (state != 5) refuse()
    ++block_count
    if (block_count>4096) refuse()
    if ($1=="heading") {
      if (NF!=3 || $2 !~ /^[1-6]$/) refuse()
    } else if ($1=="text") {
      if (NF!=2) refuse()
    } else if ($1=="link") {
      if (NF!=3 || !valid_address($3)) refuse()
    } else if ($1=="row") {
      if (NF<2) refuse()
    } else if ($1=="image") {
      if (NF<4 || NF>5 ||
        $2 !~ /^(content:|file:|asset:|resource:)/) refuse()
      if (NF==5 && !valid_address($5)) refuse()
    } else if ($1=="form") {
      # Forms require separate interaction qualification.
      refuse()
    } else refuse()
  }
  END { if (bad || state!=6 || revision_count!=1) exit 1 }
' "$candidate" || fail invalid_version1
awk -F '\t' '
  NF!=2 || $1 !~ /^[a-z_][a-z_0-9]*$/ || $2=="" || /\r/ {bad=1}
  {if (seen[$1]++) bad=1}
  END {if (bad || NR!=4) exit 1}
' "$receipt" || fail invalid_source_receipt
field() { awk -F '\t' -v wanted="$1" '$1==wanted {print $2}' "$receipt"; }
test "$(field source_key)" = "$key" || fail changed_source_identity
test "$(field source_generation)" = "$generation" || fail stale_generation
observed=$(sha256sum "$body" | cut -d ' ' -f 1)
test "$(field source_sha256)" = "$observed" || fail corrupted_source
count=$(wc -c < "$body" | tr -d '[:space:]')
test "$(field source_bytes)" = "$count" || fail truncated_source
cmp -s "$candidate" "$golden" || fail wrong_semantic_output
printf 'aici-ib-prepaint\tSTATIC_SOURCE_BOUND_PASS\n'
