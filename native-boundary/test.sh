#!/usr/bin/env bash
# Good/bad C fixtures: expected semantic rejection is exit 1; setup failure,
# signal death, timeout, and accidental success do not satisfy a bad fixture.
set -euo pipefail
if [[ $# -lt 1 || $# -gt 2 ]]; then echo 'usage: bash native-boundary/test.sh NEW_OUTPUT_DIRECTORY [HOST_BUNDLE]' >&2; exit 2; fi
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
mkdir "$1"
output=$(cd "$1" && pwd)
mkdir "$output/scratch"
compiler=${CC:-cc}
flags=(-std=c17 -Wall -Wextra -Werror -pedantic -O2)
"$compiler" "${flags[@]}" -fPIC -shared "$root/native-boundary/fixture.c" -o "$output/libnative-fixture.so"
for mode in default largefile; do
  offsets=()
  if [[ "$mode" == largefile ]]; then offsets=(-D_FILE_OFFSET_BITS=64); fi
  "$compiler" "${flags[@]}" "${offsets[@]}" -DAICI_NATIVE_SELF_TEST \
    "$root/native-boundary/probe.c" -pthread -ldl -o "$output/self-test-$mode"
  (cd "$output/scratch"; "$output/self-test-$mode" --self-test "$output/libnative-fixture.so") \
    > "$output/$mode.tsv" 2> "$output/$mode.stderr"
  awk -F '\t' '
    $1=="case" {if($4!="PASS") bad=1; if($3=="native") good++; if($3=="known-bad") rejected++}
    END {exit !(good==17 && rejected==17 && !bad)}
  ' "$output/$mode.tsv"
  # One specific rejection diagnostic per declared bad case, not incidental
  # setup failure or a signal accepted as the expected negative.
  awk -F '\t' '
    $1!="REJECT" || seen[$2]++ {bad=1}
    END {exit !(NR==17 && !bad)}
  ' "$output/$mode.stderr"
done
printf 'PASS: 34 native case executions and 34 targeted semantic rejections\n'

if [[ $# == 2 ]]; then
  bundle=$(cd "$2" && pwd)
  sh "$bundle/run.sh" "$output/good-bundle" > "$output/good-bundle.log"
  for fault in changed-binary missing-library partial-manifest duplicate-manifest; do
    broken="$output/$fault"
    mkdir "$broken"
    cp "$bundle/"* "$broken/"
    diagnostic='bundle checksum verification failed'
    case "$fault" in
      changed-binary) printf X >> "$broken/probe-default" ;;
      missing-library) rm "$broken/libnative-fixture.so" ;;
      partial-manifest) sed '$d' "$bundle/SHA256SUMS" > "$broken/SHA256SUMS"; diagnostic='invalid checksum manifest' ;;
      duplicate-manifest) head -n 1 "$bundle/SHA256SUMS" >> "$broken/SHA256SUMS"; diagnostic='invalid checksum manifest' ;;
    esac
    if sh "$broken/run.sh" "$output/$fault-receipt" > "$output/$fault.log" 2>&1; then
      echo "bad bundle accepted: $fault" >&2; exit 1
    fi
    grep -F "$diagnostic" "$output/$fault.log"
  done
  printf 'PASS: real host bundle plus four targeted packaging rejections\n'
fi
