#!/usr/bin/env bash
# Build/test orchestration only; the assertions and self-test live in native C.
set -euo pipefail
if [[ $# != 2 ]]; then
  echo 'usage: bash native-boundary/build.sh host|armv7a|aarch64 OUTPUT_DIRECTORY' >&2
  exit 2
fi
target=$1
output=$2
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
. /etc/os-release
if [[ "$ID" != debian ]]; then echo 'requires a Debian build environment' >&2; exit 2; fi
case "$target" in host|armv7a|aarch64) ;; *) echo 'unknown target' >&2; exit 2;; esac
if [[ -e "$output" ]]; then echo 'output already exists; use a fresh directory' >&2; exit 2; fi
revision=$(git -C "$root" rev-parse HEAD)
tree=$(git -C "$root" rev-parse HEAD:native-boundary)
if [[ -n "$(git -C "$root" status --porcelain -- native-boundary)" ]]; then
  echo 'native-boundary source must be committed and clean' >&2; exit 2
fi
for file in probe.c fixture.c build.sh run.sh test.sh; do
  git -C "$root" ls-files --error-unmatch "native-boundary/$file" >/dev/null
done
mkdir -p "$(dirname "$output")"
mkdir "$output"
output=$(cd "$output" && pwd)
bundle="$output/bundle"
mkdir "$bundle"
flags=(-std=c17 -Wall -Wextra -Werror -pedantic -O2)
links=(-Wl,-z,relro,-z,now)
ndk=not-applicable
api=not-android
compiler=${CC:-cc}
reader=readelf
if [[ "$target" != host ]]; then
  : "${ANDROID_NDK_HOME:?provide the pinned Android NDK 27.3.13750724}"
  ndk=$(awk '$1 == "Pkg.Revision" && $2 == "=" {print $3}' "$ANDROID_NDK_HOME/source.properties")
  if [[ "$ndk" != 27.3.13750724 ]]; then echo 'wrong Android NDK revision' >&2; exit 2; fi
  tools="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin"
  api=24
  case "$target" in
    armv7a) triple=armv7a-linux-androideabi; machine=ARM; class=ELF32; interpreter=/system/bin/linker; width=4 ;;
    aarch64) triple=aarch64-linux-android; machine=AArch64; class=ELF64; interpreter=/system/bin/linker64; width=8
      links+=(-Wl,-z,max-page-size=16384 -Wl,-z,common-page-size=16384) ;;
  esac
  compiler="$tools/${triple}${api}-clang"
  reader="$tools/llvm-readelf"
  flags+=(-DAICI_REQUIRE_BIONIC=1 "-DAICI_EXPECT_POINTER_SIZE=$width")
fi
command -v "$compiler"
command -v "$reader"
"$compiler" --version > "$bundle/compiler.txt"
{
  printf 'schema\taici-native-build-v1\nsuite_revision\t%s\nsuite_tree\t%s\n' "$revision" "$tree"
  printf 'target\t%s\ncompile_api\t%s\nndk\t%s\n' "$target" "$api" "$ndk"
  printf 'build_userspace\t%s\nbuild_machine\t%s\n' "$PRETTY_NAME" "$(uname -m)"
  printf 'evidence\tcompile-link-package\nandroid_execution\tNOT_RUN\nphysical_device\tNOT_ESTABLISHED\n'
} > "$bundle/build.tsv"
: > "$bundle/commands.txt"
build() {
  printf '%q ' "$@" >> "$bundle/commands.txt"
  printf '\n' >> "$bundle/commands.txt"
  "$@"
}
build "$compiler" "${flags[@]}" -fPIC -shared "$root/native-boundary/fixture.c" \
  "${links[@]}" -o "$bundle/libnative-fixture.so"
for mode in default largefile; do
  offsets=()
  if [[ "$mode" == largefile ]]; then offsets=(-D_FILE_OFFSET_BITS=64); fi
  build "$compiler" "${flags[@]}" "${offsets[@]}" \
    "-DAICI_NATIVE_REVISION=\"$revision\"" -fPIE -pie \
    "$root/native-boundary/probe.c" -pthread -ldl "${links[@]}" -o "$bundle/probe-$mode"
done
# Inspect actual ELF files, never a source declaration or one archive member.
for name in libnative-fixture.so probe-default probe-largefile; do
  "$reader" -h -l -d --wide "$bundle/$name" > "$output/$name.elf.txt"
  if [[ "$target" != host ]]; then
    awk -v machine="$machine" -v class="$class" '
      /Class:/ {if ($2 != class) exit 1; c++}
      /Machine:/ {if ($2 != machine) exit 1; m++}
      /Type:/ && $2 == "DYN" {t++}
      END {if (c != 1 || m != 1 || t != 1) exit 1}
    ' "$output/$name.elf.txt"
    if [[ "$name" == probe-* ]]; then
      grep -F "Requesting program interpreter: $interpreter]" "$output/$name.elf.txt"
    fi
    awk '/\(NEEDED\)/ {
      value=$0; sub(/^.*\[/, "", value); sub(/\].*$/, "", value)
      if (value != "libc.so" && value != "libdl.so" && value != "libm.so") exit 1
    }' "$output/$name.elf.txt"
    if [[ "$target" == aarch64 ]]; then
      awk '
        function hex(s, n,i,d) {
          sub(/^0x/, "", s); n=0
          for(i=1;i<=length(s);i++) {
            d=index("0123456789abcdef", tolower(substr(s,i,1)))-1
            if(d<0) exit 1
            n=16*n+d
          }
          return n
        }
        $1 == "LOAD" {
          if (hex($NF)<16384 || hex($NF)%16384 || hex($2)%16384 != hex($3)%16384) exit 1
          loads++
        }
        $1 == "GNU_RELRO" {if ((hex($3)+hex($6))%16384) exit 1; relro++}
        END {if (!loads || !relro) exit 1}
      ' "$output/$name.elf.txt"
    fi
  fi
done
cp "$root/native-boundary/run.sh" "$bundle/run.sh"
(cd "$root"; sha256sum native-boundary/probe.c native-boundary/fixture.c \
  native-boundary/build.sh native-boundary/run.sh native-boundary/test.sh) > "$bundle/source.sha256"
(cd "$bundle"; sha256sum probe-default probe-largefile libnative-fixture.so \
  build.tsv compiler.txt commands.txt source.sha256 run.sh > SHA256SUMS)
if [[ "$target" == host ]]; then
  bash "$root/native-boundary/test.sh" "$output/host-self-test" "$bundle"
  sh "$bundle/run.sh" "$output/host-runtime"
fi
tar -C "$output" -czf "$output/native-boundary-$target.tar.gz" bundle
(cd "$output"; sha256sum "native-boundary-$target.tar.gz" > "native-boundary-$target.tar.gz.sha256")
printf 'Built %s; Android runtime and physical-device acceptance are not inferred.\n' "$target"
