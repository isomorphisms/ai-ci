#!/bin/sh
# Runtime only: no compiler, package installation, or source checkout.
set -eu
if [ "$#" -ne 1 ]; then
  echo 'usage: sh bundle/run.sh NEW_RECEIPT_DIRECTORY' >&2
  exit 2
fi
bundle=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
mkdir -p "$(dirname -- "$1")"
mkdir "$1"
receipts=$(CDPATH= cd -- "$1" && pwd)
scratch="$receipts/scratch"
mkdir "$scratch"
trap 'rmdir "$scratch"' EXIT
cd "$bundle"
# Reject partial, duplicate, unexpected, or path-traversing manifests.
if awk '
  BEGIN {split("probe-default probe-largefile libnative-fixture.so build.tsv compiler.txt commands.txt source.sha256 run.sh", names, " "); for(i in names) expected[names[i]]=1}
  NF != 2 || length($1) != 64 || $1 ~ /[^0-9a-f]/ || !($2 in expected) || seen[$2]++ {bad=1}
  END {for(name in expected) if(seen[name]!=1) bad=1; exit bad}
' SHA256SUMS; then :; else
  echo 'invalid checksum manifest' >&2; exit 2
fi
if sha256sum -c SHA256SUMS > "$receipts/integrity.txt"; then :; else
  echo 'bundle checksum verification failed' >&2; exit 2
fi
target=$(awk -F '\t' '$1=="target" {print $2}' build.tsv)
revision=$(awk -F '\t' '$1=="suite_revision" {print $2}' build.tsv)
case "$target" in
  host) expected_libc=glibc; evidence=host-runtime ;;
  armv7a|aarch64)
    expected_libc=bionic; evidence=android-runtime-unclassified
    if [ ! -x /system/bin/getprop ]; then echo 'Android runtime required' >&2; exit 2; fi
    /system/bin/getprop ro.build.version.sdk > "$receipts/android-api.txt"
    /system/bin/getprop ro.build.fingerprint > "$receipts/android-build.txt"
    /system/bin/getprop ro.product.cpu.abilist > "$receipts/android-abis.txt"
    /system/bin/getprop ro.kernel.qemu > "$receipts/android-qemu-property.txt"
    ;;
  *) echo 'unknown bundle target' >&2; exit 2 ;;
esac
{
  printf 'schema\taici-native-execution-v1\nsuite_revision\t%s\ntarget\t%s\n' "$revision" "$target"
  printf 'execution_class\t%s\nphysical_device\tNOT_ATTESTED\n' "$evidence"
  printf 'utc\t%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf 'uname\t%s\n' "$(uname -a)"
} > "$receipts/runtime.tsv"
cp build.tsv SHA256SUMS "$receipts/"
status=0
for mode in default largefile; do
  if (cd "$scratch"; "$bundle/probe-$mode" "$bundle/libnative-fixture.so") \
      > "$receipts/$mode.tsv" 2> "$receipts/$mode.stderr"; then
    if awk -F '\t' -v libc="$expected_libc" -v revision="$revision" '
      $1=="libc" && $2==libc {l++}
      $1=="source" && $2==revision {s++}
      $1=="mode" && $2=="native-execution" {m++}
      $1=="case" {if ($3!="native" || $4!="PASS" || seen[$2]++) bad=1; n++}
      $1=="summary" && $2=="PASS" && $3=="failures=0" {p++}
      END {exit !(l==1 && s==1 && m==1 && n==17 && p==1 && !bad)}
    ' "$receipts/$mode.tsv"; then :; else status=1; fi
  else
    status=1
  fi
done
if [ "$status" -eq 0 ]; then
  printf 'result\tPASS\n' >> "$receipts/runtime.tsv"
else
  printf 'result\tFAIL\n' >> "$receipts/runtime.tsv"
fi
cat "$receipts/runtime.tsv"
exit "$status"
