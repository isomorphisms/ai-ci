#!/usr/bin/env bash
set -euxo pipefail

IDRIC_COMMIT=081b9cde0591154839fb5d80d76e5570e0436300
IDRIC_DIR=${IDRIC_DIR:-"$PWD/upstream-idric"}
ARTIFACTS=${IDRIC_ARTIFACTS:-"$PWD/artifacts/idric"}
PREFIX="$IDRIC_DIR/.comparison-install"
PREFIX_MARKER="$PREFIX/.idric-source-commit"
SOURCE="$PWD/benchmarks/iridium-2014/IdricBench.idric"
EXPECTED="$PWD/benchmarks/iridium-2014/expected-output.txt"
OUTPUT_NAME=iridium-idric-refc
COMPILER_WORK="$ARTIFACTS/compiler-work"
BINARY="$ARTIFACTS/$OUTPUT_NAME"

mkdir -p "$ARTIFACTS"

test -d "$IDRIC_DIR/.git"
test "$(git -C "$IDRIC_DIR" rev-parse HEAD)" = "$IDRIC_COMMIT"
printf '%s\n' "$IDRIC_COMMIT" | tee "$ARTIFACTS/idric-source-commit.txt"
git -C "$IDRIC_DIR" status --porcelain=v1 > "$ARTIFACTS/idric-source-status.txt"
test ! -s "$ARTIFACTS/idric-source-status.txt"

uname -a | tee "$ARTIFACTS/uname.txt"
uname -m | tee "$ARTIFACTS/host-arch.txt"
cat /etc/os-release > "$ARTIFACTS/os-release.txt"
cc --version > "$ARTIFACTS/c-compiler-version.txt" 2>&1
ld --version > "$ARTIFACTS/linker-version.txt" 2>&1

# Build the exact Idriç revision using its own pinned Chez bootstrap, then make
# an isolated install so the benchmark does not depend on a system Idris 2.
# The install is safe to cache only behind an exact source-commit marker; the
# workflow cache key also contains this commit and the pinned Chez archive hash.
if [ -x "$PREFIX/bin/idris2" ] \
   && [ -f "$PREFIX_MARKER" ] \
   && [ "$(cat "$PREFIX_MARKER")" = "$IDRIC_COMMIT" ]; then
  printf 'verified-cache-hit\n' > "$ARTIFACTS/idric-compiler-cache.txt"
else
  rm -rf "$PREFIX"
  (
    cd "$IDRIC_DIR"
    ./edric bootstrap
    make install \
      PREFIX="$PREFIX" \
      IDRIS2_PREFIX="$PREFIX" \
      SCHEME="$IDRIC_DIR/.tools/bin/scheme"
  )
  printf '%s\n' "$IDRIC_COMMIT" > "$PREFIX_MARKER"
  printf 'built-from-pinned-source\n' > "$ARTIFACTS/idric-compiler-cache.txt"
fi

COMPILER="$PREFIX/bin/idris2"
test -x "$COMPILER"
test "$(cat "$PREFIX_MARKER")" = "$IDRIC_COMMIT"
IDRIS2_PREFIX="$PREFIX" "$COMPILER" --version | tee "$ARTIFACTS/idric-version.txt"
sha256sum "$COMPILER" > "$ARTIFACTS/idric-compiler.sha256"
sha256sum \
  "$IDRIC_DIR/src/Compiler/RefC/CC.idr" \
  "$IDRIC_DIR/src/Compiler/RefC/RefC.idr" \
  > "$ARTIFACTS/refc-source.sha256"

# RefC is the first native Linux comparison row. Make the C optimization policy
# explicit. The historical Idris compiler's exact generated-C flag policy has
# not yet been normalized against this row, so these timings are not used for a
# cross-compiler speed ratio.
export IDRIS2_PREFIX="$PREFIX"
export IDRIS2_CFLAGS='-O2 -fwrapv -fno-strict-overflow'
printf '%s\n' "$IDRIS2_CFLAGS" > "$ARTIFACTS/idric-cflags.txt"
rm -rf "$COMPILER_WORK"
mkdir -p "$COMPILER_WORK"
printf '%s\n' \
  "cd $COMPILER_WORK && IDRIS2_PREFIX=$PREFIX IDRIS2_CFLAGS='$IDRIS2_CFLAGS' $COMPILER --source-dir $(dirname "$SOURCE") --cg refc -o $OUTPUT_NAME $SOURCE" \
  > "$ARTIFACTS/compile-command.txt"

# Idris 2's -o names the executable inside its build/exec tree; it is not a
# literal destination pathname. Compile from a controlled directory, declare
# the source tree explicitly, and copy the generated executable afterward.
TIMEFORMAT='%3R'
set +x
(
  cd "$COMPILER_WORK"
  { time "$COMPILER" --source-dir "$(dirname "$SOURCE")" \
      --cg refc -o "$OUTPUT_NAME" "$SOURCE"; } \
    2> "$ARTIFACTS/compile-seconds.txt"
)
set -x

GENERATED_BINARY="$COMPILER_WORK/build/exec/$OUTPUT_NAME"
if [ ! -x "$GENERATED_BINARY" ]; then
  find "$COMPILER_WORK" -maxdepth 4 -printf '%y\t%p\n' \
    > "$ARTIFACTS/compiler-work-tree.txt"
  printf 'expected RefC executable missing: %s\n' "$GENERATED_BINARY" \
    > "$ARTIFACTS/output-path-error.txt"
  exit 1
fi
printf '%s\n' "$GENERATED_BINARY" > "$ARTIFACTS/generated-binary-path.txt"
cp "$GENERATED_BINARY" "$BINARY"

test -x "$BINARY"
file "$BINARY" | tee "$ARTIFACTS/file.txt"
file "$BINARY" | grep -q 'ELF'

"$BINARY" > "$ARTIFACTS/result-1.txt"
"$BINARY" > "$ARTIFACTS/result-2.txt"
cp "$EXPECTED" "$ARTIFACTS/expected-output.txt"
cmp "$ARTIFACTS/expected-output.txt" "$ARTIFACTS/result-1.txt"
cmp "$ARTIFACTS/result-1.txt" "$ARTIFACTS/result-2.txt"
sha256sum "$ARTIFACTS/result-1.txt" > "$ARTIFACTS/result.sha256"

# Retain startup-inclusive evidence only. This is deliberately not called the
# common-kernel timing because the historical row does not yet have an
# equivalent repeated in-process timing boundary.
printf '%s\n' \
  "three separate executions of $BINARY; each performs 200000 focus/swap steps" \
  > "$ARTIFACTS/run-command.txt"
TIMEFORMAT='wall=%3R user=%3U system=%3S'
set +x
{ time bash -c 'for i in 1 2 3; do "$1" >/dev/null; done' _ "$BINARY"; } \
  2> "$ARTIFACTS/run-time-3x.txt"
set -x

stat --printf='%s\n' "$BINARY" | tee "$ARTIFACTS/file-bytes.txt"
sha256sum "$BINARY" > "$ARTIFACTS/binary.sha256"
size "$BINARY" > "$ARTIFACTS/size.txt"
readelf -hW "$BINARY" > "$ARTIFACTS/readelf-header.txt"
readelf -SW "$BINARY" > "$ARTIFACTS/readelf-sections.txt"
readelf -lW "$BINARY" > "$ARTIFACTS/readelf-program-headers.txt"
readelf -dW "$BINARY" > "$ARTIFACTS/readelf-dynamic.txt"
readelf -sW "$BINARY" > "$ARTIFACTS/readelf-symbols.txt"
readelf -rW "$BINARY" > "$ARTIFACTS/readelf-relocations.txt"
nm -S --size-sort "$BINARY" > "$ARTIFACTS/nm-size-sort.txt"

cp "$BINARY" "$ARTIFACTS/$OUTPUT_NAME-stripped"
strip --strip-all "$ARTIFACTS/$OUTPUT_NAME-stripped"
stat --printf='%s\n' "$ARTIFACTS/$OUTPUT_NAME-stripped" \
  | tee "$ARTIFACTS/stripped-file-bytes.txt"
sha256sum "$ARTIFACTS/$OUTPUT_NAME-stripped" \
  > "$ARTIFACTS/stripped-binary.sha256"
size "$ARTIFACTS/$OUTPUT_NAME-stripped" > "$ARTIFACTS/stripped-size.txt"
strip --version > "$ARTIFACTS/strip-version.txt"

# Deployment footprint is a separate measurement: executable bytes above,
# resolved external runtime/library files here. RefC's own support archive is
# statically linked, so it is charged to the executable rather than duplicated
# in this external-library total.
ldd --version > "$ARTIFACTS/runtime-ldd-version.txt" 2>&1 || true
ldd "$BINARY" | tee "$ARTIFACTS/runtime-ldd.txt"
: > "$ARTIFACTS/runtime-library-files.txt"
runtime_library_total=0
while read -r library; do
  resolved="$(readlink -f "$library")"
  bytes="$(stat --printf='%s' "$resolved")"
  digest="$(sha256sum "$resolved" | awk '{print $1}')"
  printf '%s\t%s\t%s\n' "$bytes" "$digest" "$resolved" \
    >> "$ARTIFACTS/runtime-library-files.txt"
  runtime_library_total=$((runtime_library_total + bytes))
done < <(awk '$2 == "=>" && $3 ~ /^\// {print $3} $1 ~ /^\// {print $1}' \
  "$ARTIFACTS/runtime-ldd.txt" | sort -u)
printf '%s\n' "$runtime_library_total" \
  > "$ARTIFACTS/runtime-library-file-bytes.txt"

cat > "$ARTIFACTS/numeric-semantics.txt" <<'EOF'
window identifiers: Int
step counter: Int
historical layout spelling: Float
current Idriç layout spelling: Double
Idris 1 renamed the floating primitive from Float to Double after the historical release; this row does not intentionally widen or narrow the arithmetic representation
fixture values: 0, 8, 240, 1080, 1920 and their layout sums are exactly representable in binary floating point
EOF

cat > "$ARTIFACTS/comparison-status.txt" <<'EOF'
semantic-oracle=supported-and-required
idric-source-extension=.idric
backend=RefC native Linux ELF
exercised-iridium-lens-path=preserved
cyclic-single-column-layout=preserved
common-kernel-speed-ratio=unsupported-pending-symmetric-in-process-harness
whole-process-startup-inclusive-timing=evidence-only
optimization-policy-equivalence=not-yet-established-against-historical-generated-C-flags
direct-historical-Idris1-module-import=unsupported-by-version-boundary; this row ports the exercised display-free kernel instead
cocoa-effects-event-loop=outside-display-free-contract-and-not-ported
native-ARM-phone-result=not-part-of-this-x86_64-CI-row
deployment-footprint=measured-separately-as-executable-bytes-plus-resolved-external-library-bytes
EOF
