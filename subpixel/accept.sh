#!/bin/sh
# Independent numeric acceptance for exact pinned Subpixel sources.
# Invoked only by pinned Ike. All C source and AICI verifier compile with ICK.
# The system driver is permitted only to link ICK-produced objects.
set -eu
root=$(CDPATH= cd "$(dirname "$0")" && pwd)
: "${ICK_CC:?ICK_CC is required}"
: "${ICK_SOURCE_DIR:?ICK_SOURCE_DIR is required}"
: "${LEAF_ROOT:?LEAF_ROOT is required}"
: "${HOST_LINKER:?HOST_LINKER is required}"
for item in "$ICK_CC" "$ICK_SOURCE_DIR" "$LEAF_ROOT" "$HOST_LINKER"; do
    case "$item" in /*) ;; *) echo "AICI BLOCKED: absolute tool paths required" >&2; exit 2 ;; esac
done

ick_pin=c61e448251744a2f40ad743ebef1a027bdcd2f9d
gcc_pin=6294f1d9e7536e5ffcde09d1528c918d63abfef5
leaf_pin=efff5fbe71d8722d713282c478dbdb52fa280f9b
test "$(git -C "$ICK_SOURCE_DIR" rev-parse HEAD)" = "$ick_pin"
test "$(git -C "$ICK_SOURCE_DIR/gcc" rev-parse HEAD)" = "$gcc_pin"
test "$(git -C "$LEAF_ROOT" rev-parse HEAD)" = "$leaf_pin"
# Independent migration gate: a pinned new API must not retain a second old one.
legacy=sub
legacy="${legacy}lixel"
if git -C "$LEAF_ROOT" ls-files | grep -i "$legacy"; then
    echo 'AICI BLOCKED: obsolete producer path' >&2
    exit 2
fi
if git -C "$LEAF_ROOT" grep -I -n -i "$legacy" -- .; then
    echo 'AICI BLOCKED: obsolete producer source or public API' >&2
    exit 2
fi
test "$ICK_CC" = "$ICK_SOURCE_DIR/stage/bin/x86_64-linux-gnu-gcc" || {
    echo 'AICI BLOCKED: source-unbound compiler path' >&2; exit 2;
}
test -x "$ICK_CC"
test -x "$HOST_LINKER"
test "$("$ICK_CC" -dumpmachine)" = x86_64-linux-gnu
cc1=$("$ICK_CC" -print-prog-name=cc1)
case "$cc1" in
  "$ICK_SOURCE_DIR"/stage/libexec/gcc/x86_64-linux-gnu/*/cc1)
      test -x "$cc1" ;;
  *) echo 'AICI BLOCKED: unowned C frontend' >&2; exit 2 ;;
esac

source3="$LEAF_ROOT/subpixel/src/curve_patch.c"
source5="$LEAF_ROOT/subpixel/src/curve_patch_5x5.c"
header="$LEAF_ROOT/subpixel/include/subpixel/curve_patch.h"
test -s "$source3" && test -s "$source5" && test -s "$header"
out="$root/build"
mkdir -p "$out"
flags="-std=c11 -O2 -Wall -Wextra -Werror -pedantic -fPIC -ffp-contract=off -fno-fast-math"
includes="-I$LEAF_ROOT/subpixel/include -I$LEAF_ROOT/src"

# Do not use the candidate producer's build script or its test program.
"$ICK_CC" $flags $includes -c "$source3" -o "$out/3.o"
"$ICK_CC" $flags $includes -c "$source5" -o "$out/5.o"
"$ICK_CC" $flags $includes -c "$LEAF_ROOT/subpixel/src/coverage_plane.c" -o "$out/plane.o"
"$ICK_CC" $flags $includes -c "$LEAF_ROOT/src/subpixel_framebuffer.c" -o "$out/framebuffer.o"
"$ICK_CC" $flags $includes -c "$root/verify.c" -o "$out/independent.o"
"$ICK_CC" $flags -c "$root/receipt_check.c" -o "$out/receipt_check.o"
"$HOST_LINKER" "$out/receipt_check.o" -o "$out/receipt-check"
for object in "$out/3.o" "$out/5.o" "$out/independent.o"; do
    readelf -h "$object" | grep -q 'Class:.*ELF64'
    readelf -h "$object" | grep -q 'Machine:.*Advanced Micro Devices X86-64'
done
"$HOST_LINKER" "$out/3.o" "$out/5.o" "$out/plane.o" "$out/framebuffer.o" "$out/independent.o" \
    -lm -o "$out/independent-verify"
"$out/independent-verify"

# Targeted genuine-source mutants: change the code being linked, not a
# verifier flag or an oracle's expected answer. Each altered library must
# successfully compile/link yet be rejected by the same independent oracle.
original3='    double graph = (patch->a2 * u) * u;'
changed3='    double graph = -((patch->a2 * u) * u);'
test "$(grep -Fxc "$original3" "$source3")" -eq 1
awk -v before="$original3" -v after="$changed3" \
    '{if ($0 == before) {print after; count++} else print} END {if (count != 1) exit 11}' \
    "$source3" > "$out/mutant-3.c"
"$ICK_CC" $flags $includes -c "$out/mutant-3.c" -o "$out/mutant-3.o"
"$HOST_LINKER" "$out/mutant-3.o" "$out/5.o" "$out/plane.o" "$out/framebuffer.o" "$out/independent.o" \
    -lm -o "$out/reject-mutant-3"
if "$out/reject-mutant-3" > "$out/mutant-3.log" 2>&1; then
    echo 'AICI FALSE PASS: 3x3 inverted-curvature mutant accepted' >&2
    exit 1
fi
grep -Fq 'AICI_SUBPIXEL_REJECT 3x3 integer-rational oracle' "$out/mutant-3.log"

original5='    double value = quadratic + cubic;'
changed5='    double value = quadratic - cubic;'
test "$(grep -Fxc "$original5" "$source5")" -eq 1
awk -v before="$original5" -v after="$changed5" \
    '{if ($0 == before) {print after; count++} else print} END {if (count != 1) exit 12}' \
    "$source5" > "$out/mutant-5.c"
"$ICK_CC" $flags $includes -c "$out/mutant-5.c" -o "$out/mutant-5.o"
"$HOST_LINKER" "$out/3.o" "$out/mutant-5.o" "$out/plane.o" "$out/framebuffer.o" "$out/independent.o" \
    -lm -o "$out/reject-mutant-5"
if "$out/reject-mutant-5" > "$out/mutant-5.log" 2>&1; then
    echo 'AICI FALSE PASS: 5x5 inverted-cubic mutant accepted' >&2
    exit 1
fi
grep -Fq 'AICI_SUBPIXEL_REJECT 5x5 integer-rational oracle' "$out/mutant-5.log"


# Genuine integration mutants must compile/link successfully, then fail the
# same independent rational oracle for their actual behavioral defect.
original_plane='    plane->occupied[(size_t)row * plane->stride_words + (size_t)column] |= mask;'
changed_plane='    plane->occupied[(size_t)row * plane->stride_words + (size_t)column] = mask;'
awk -v before="$original_plane" -v after="$changed_plane" \
    '{if ($0 == before) {print after; count++} else print} END {if (count != 1) exit 13}' \
    "$LEAF_ROOT/subpixel/src/coverage_plane.c" > "$out/mutant-plane.c"
"$ICK_CC" $flags $includes -c "$out/mutant-plane.c" -o "$out/mutant-plane.o"
"$HOST_LINKER" "$out/3.o" "$out/5.o" "$out/mutant-plane.o" \
    "$out/framebuffer.o" "$out/independent.o" -lm -o "$out/reject-mutant-plane"
if "$out/reject-mutant-plane" > "$out/mutant-plane.log" 2>&1; then
    echo 'AICI FALSE PASS: overwritten coverage union accepted' >&2
    exit 1
fi
grep -Fq 'AICI_SUBPIXEL_REJECT coverage plane rational union' "$out/mutant-plane.log"

original_frame='            double source_alpha = source_base_alpha * occupied_samples(mask) / 64.0;'
changed_frame='            double source_alpha = source_base_alpha * (occupied_samples(mask) != 0);'
awk -v before="$original_frame" -v after="$changed_frame" \
    '{if ($0 == before) {print after; count++} else print} END {if (count != 1) exit 14}' \
    "$LEAF_ROOT/src/subpixel_framebuffer.c" > "$out/mutant-framebuffer.c"
"$ICK_CC" $flags $includes -c "$out/mutant-framebuffer.c" -o "$out/mutant-framebuffer.o"
"$HOST_LINKER" "$out/3.o" "$out/5.o" "$out/plane.o" \
    "$out/mutant-framebuffer.o" "$out/independent.o" -lm -o "$out/reject-mutant-framebuffer"
if "$out/reject-mutant-framebuffer" > "$out/mutant-framebuffer.log" 2>&1; then
    echo 'AICI FALSE PASS: opaque coverage stamp accepted' >&2
    exit 1
fi
grep -Fq 'AICI_SUBPIXEL_REJECT framebuffer rational alpha' "$out/mutant-framebuffer.log"

printf 'aici_leaf_commit\t%s\n' "$leaf_pin"
printf 'aici_ick_commit\t%s\n' "$ick_pin"
printf 'aici_compiler\t%s\n' "$ICK_CC"
printf 'aici_frontend\t%s\n' "$cc1"
sha256sum "$ICK_CC" "$cc1" "$source3" "$source5" "$header" \
    "$out/3.o" "$out/5.o" "$out/independent.o" "$out/independent-verify" \
    "$out/mutant-3.o" "$out/mutant-5.o" \
    "$out/receipt_check.o" "$out/receipt-check"
echo 'AICI_SUBPIXEL_ACCEPT independent 3x3/5x5 rational coverage and four source mutants: PASS'
