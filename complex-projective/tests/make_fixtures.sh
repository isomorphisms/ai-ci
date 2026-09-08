#!/bin/sh
set -eu

if [ "$#" -ne 1 ] || [ -z "$1" ] || [ "$1" = "/" ]; then
  echo "usage: $0 OUTPUT-DIRECTORY" >&2
  exit 2
fi

fixture_directory=$(CDPATH= cd -- "$(dirname -- "$0")/fixtures" && pwd)
output_directory=$1
mkdir -p "$output_directory"

for fixture in corpus-v1.json evidence.txt x86.contract.tsv x86.receipt.tsv \
    thumb.contract.tsv thumb.receipt.tsv gpu.contract.tsv gpu.receipt.tsv; do
  cp "$fixture_directory/$fixture" "$output_directory/$fixture"
done

awk -F '\t' 'BEGIN { OFS="\t" }
  $1 == "schema" { $2="wrong-contract-schema" }
  { print }
' "$output_directory/x86.contract.tsv" >"$output_directory/bad-contract.tsv"

awk -F '\t' 'BEGIN { OFS="\t" }
  $1 == "require" && $3 == "numeric" { $6="blocked" }
  { print }
' "$output_directory/x86.contract.tsv" >"$output_directory/bad-x86-downgrade.contract.tsv"

awk -F '\t' 'BEGIN { OFS="\t" }
  $1 == "identity" { $5="leader" }
  { print }
' "$output_directory/thumb.contract.tsv" >"$output_directory/bad-thumb-leader.contract.tsv"

awk -F '\t' 'BEGIN { OFS="\t" }
  NR == 1 { $1="wrong_header" }
  { print }
' "$output_directory/x86.receipt.tsv" >"$output_directory/bad-receipt.tsv"

awk -F '\t' 'BEGIN { OFS="\t" }
  NR == 2 { $1="stale-target" }
  { print }
' "$output_directory/x86.receipt.tsv" >"$output_directory/bad-identity.tsv"

awk -F '\t' 'BEGIN { OFS="\t" }
  NR == 2 { $8="refs/heads/stale-compiler" }
  { print }
' "$output_directory/x86.receipt.tsv" >"$output_directory/bad-corpus-binding.tsv"

awk -F '\t' 'BEGIN { OFS="\t" }
  NR == 2 { $16="refs/heads/stale-backend" }
  { print }
' "$output_directory/x86.receipt.tsv" >"$output_directory/bad-provenance.tsv"

# A lexical `root/relative` join is insufficient: an intermediate symlink can
# otherwise make valid witness bytes escape the receipt root.
ln -s /etc "$output_directory/escape"
host_sha=$(sha256sum /etc/hostname | cut -d' ' -f1)
awk -F '\t' -v sha="$host_sha" 'BEGIN { OFS="\t" }
  NR == 2 { $22="escape/hostname"; $23=sha }
  { print }
' "$output_directory/x86.receipt.tsv" >"$output_directory/bad-witness-escape.tsv"

for specification in \
    'CP-EXACT:exact:exact-corpus' \
    'CP-NUMERIC:numeric:numerical-corpus' \
    'CP-PROJECTIVE:projective:projective-equivalence-corpus' \
    'CP-RENDER:render:headless-render' \
    'CP-DIRECT-BUILD:pipeline:direct-build' \
    'CP-NATIVE-EXECUTION:pipeline:native-execution' \
    'CP-THIN-DEBIAN:pipeline:thin-debian-execution' \
    'CP-GITHUB-ACTIONS:pipeline:github-actions-execution'; do
  diagnostic=${specification%%:*}
  rest=${specification#*:}
  category=${rest%%:*}
  stage=${rest#*:}
  filename=$(printf '%s' "$diagnostic" | tr '[:upper:]' '[:lower:]' | tr '-' '_')
  awk -F '\t' -v category="$category" -v stage="$stage" \
      'BEGIN { OFS="\t" }
       $4 == category && $5 == stage { $6="blocked" }
       { print }
      ' "$output_directory/x86.receipt.tsv" >"$output_directory/bad-$filename.tsv"
done

cp "$output_directory/x86.receipt.tsv" "$output_directory/bad-extra.tsv"
awk -F '\t' 'BEGIN { OFS="\t" }
  NR == 2 {
    $4="pipeline"
    $5="undeclared-stage"
    $21="undeclared-environment"
    print
  }
' "$output_directory/x86.receipt.tsv" >>"$output_directory/bad-extra.tsv"

awk -F '\t' 'BEGIN { OFS="\t" }
  $5 == "shader-linked" { $6="pass" }
  { print }
' "$output_directory/gpu.receipt.tsv" >"$output_directory/bad-gpu-stage.tsv"

awk '{ sub(/synthetic-verifier-fixture/, "changed-verifier-fixture"); print }' \
  "$output_directory/corpus-v1.json" >"$output_directory/bad-corpus-v1.json"

cases=$output_directory/cases.tsv
{
  printf 'pass\t%s\t%s\t%s\t%s\t-\n' \
    "$output_directory/x86.contract.tsv" \
    "$output_directory/x86.receipt.tsv" \
    "$output_directory/corpus-v1.json" "$output_directory"
  printf 'pass\t%s\t%s\t%s\t%s\t-\n' \
    "$output_directory/gpu.contract.tsv" \
    "$output_directory/gpu.receipt.tsv" \
    "$output_directory/corpus-v1.json" "$output_directory"
  printf 'pass\t%s\t%s\t%s\t%s\t-\n' \
    "$output_directory/thumb.contract.tsv" \
    "$output_directory/thumb.receipt.tsv" \
    "$output_directory/corpus-v1.json" "$output_directory"
  printf 'fail\t%s\t%s\t%s\t%s\tAICI-CP-CONTRACT\n' \
    "$output_directory/bad-contract.tsv" \
    "$output_directory/x86.receipt.tsv" \
    "$output_directory/corpus-v1.json" "$output_directory"
  printf 'fail\t%s\t%s\t%s\t%s\tAICI-CP-CONTRACT\n' \
    "$output_directory/bad-x86-downgrade.contract.tsv" \
    "$output_directory/x86.receipt.tsv" \
    "$output_directory/corpus-v1.json" "$output_directory"
  printf 'fail\t%s\t%s\t%s\t%s\tAICI-CP-CONTRACT\n' \
    "$output_directory/bad-thumb-leader.contract.tsv" \
    "$output_directory/thumb.receipt.tsv" \
    "$output_directory/corpus-v1.json" "$output_directory"
  printf 'fail\t%s\t%s\t%s\t%s\tCP-RECEIPT\n' \
    "$output_directory/x86.contract.tsv" \
    "$output_directory/bad-receipt.tsv" \
    "$output_directory/corpus-v1.json" "$output_directory"
  printf 'fail\t%s\t%s\t%s\t%s\tCP-IDENTITY\n' \
    "$output_directory/x86.contract.tsv" \
    "$output_directory/bad-identity.tsv" \
    "$output_directory/corpus-v1.json" "$output_directory"
  printf 'fail\t%s\t%s\t%s\t%s\tCP-CORPUS-BINDING\n' \
    "$output_directory/x86.contract.tsv" \
    "$output_directory/bad-corpus-binding.tsv" \
    "$output_directory/corpus-v1.json" "$output_directory"
  printf 'fail\t%s\t%s\t%s\t%s\tCP-CORPUS\n' \
    "$output_directory/x86.contract.tsv" \
    "$output_directory/x86.receipt.tsv" \
    "$output_directory/bad-corpus-v1.json" "$output_directory"
  printf 'fail\t%s\t%s\t%s\t%s\tCP-PROVENANCE\n' \
    "$output_directory/x86.contract.tsv" \
    "$output_directory/bad-provenance.tsv" \
    "$output_directory/corpus-v1.json" "$output_directory"
  printf 'fail\t%s\t%s\t%s\t%s\tCP-EXACT\n' \
    "$output_directory/x86.contract.tsv" \
    "$output_directory/bad-witness-escape.tsv" \
    "$output_directory/corpus-v1.json" "$output_directory"
  for diagnostic in CP-EXACT CP-NUMERIC CP-PROJECTIVE CP-RENDER \
      CP-DIRECT-BUILD CP-NATIVE-EXECUTION CP-THIN-DEBIAN CP-GITHUB-ACTIONS; do
    filename=$(printf '%s' "$diagnostic" | tr '[:upper:]' '[:lower:]' | tr '-' '_')
    printf 'fail\t%s\t%s\t%s\t%s\t%s\n' \
      "$output_directory/x86.contract.tsv" \
      "$output_directory/bad-$filename.tsv" \
      "$output_directory/corpus-v1.json" "$output_directory" "$diagnostic"
  done
  printf 'fail\t%s\t%s\t%s\t%s\tCP-RECEIPT-EXTRA\n' \
    "$output_directory/x86.contract.tsv" \
    "$output_directory/bad-extra.tsv" \
    "$output_directory/corpus-v1.json" "$output_directory"
  printf 'fail\t%s\t%s\t%s\t%s\tCP-GPU-STAGES\n' \
    "$output_directory/gpu.contract.tsv" \
    "$output_directory/bad-gpu-stage.tsv" \
    "$output_directory/corpus-v1.json" "$output_directory"
} >"$cases"

printf '%s\n' "$cases"
