#!/bin/sh
# Independent exact-head Flower + Subpixel source acceptance. Never compile
# the producer's tests; do not use host GCC for consumer compilation.
set -eu
root=$(CDPATH= cd "$(dirname "$0")" && pwd)
: "${ICK_CC:?ICK compiler must be explicit}"
: "${ICK_SOURCE_DIR:?ICK source pin required}"
: "${FLOWER_ROOT:?Flower source pin required}"
: "${LEAF_ROOT:?Subpixel source pin required}"
: "${HOST_LINKER:?system CRT/link driver required}"
ick_pin=c61e448251744a2f40ad743ebef1a027bdcd2f9d
gcc_pin=6294f1d9e7536e5ffcde09d1528c918d63abfef5
flower_pin=f404096058cf4b6ac35b59d6b67cb72587b297d8
leaf_pin=efff5fbe71d8722d713282c478dbdb52fa280f9b
test "$(git -C "$ICK_SOURCE_DIR" rev-parse HEAD)" = "$ick_pin"
test "$(git -C "$ICK_SOURCE_DIR/gcc" rev-parse HEAD)" = "$gcc_pin"
test "$(git -C "$FLOWER_ROOT" rev-parse HEAD)" = "$flower_pin"
test "$(git -C "$LEAF_ROOT" rev-parse HEAD)" = "$leaf_pin"
test "$ICK_CC" = "$ICK_SOURCE_DIR/stage/bin/x86_64-linux-gnu-gcc"
test -x "$ICK_CC"
test -x "$HOST_LINKER"
test "$("$ICK_CC" -dumpmachine)" = x86_64-linux-gnu
cc1=$("$ICK_CC" -print-prog-name=cc1)
case "$cc1" in
  "$ICK_SOURCE_DIR"/stage/libexec/gcc/x86_64-linux-gnu/*/cc1) test -x "$cc1" ;;
  *) echo 'AICI FLOWER BLOCKED: frontend not owned' >&2; exit 2 ;;
esac
test -s "$FLOWER_ROOT/src/flower_construction.c"
test -s "$FLOWER_ROOT/src/flower_subpixel.c"
test -s "$LEAF_ROOT/subpixel/include/subpixel/curve_patch.h"
test -s "$LEAF_ROOT/src/subpixel_framebuffer.c"
out="$root/build"
mkdir -p "$out"
flags="-std=c11 -O2 -Wall -Wextra -Werror -pedantic -fPIC -ffp-contract=off -fno-fast-math"
includes="-I$LEAF_ROOT/subpixel/include -I$LEAF_ROOT/src -I$FLOWER_ROOT/src"

# All product sources, independent verifier and receipt-checker use ICK.
"$ICK_CC" $flags $includes -c "$LEAF_ROOT/subpixel/src/curve_patch.c" -o "$out/3.o"
"$ICK_CC" $flags $includes -c "$LEAF_ROOT/subpixel/src/curve_patch_5x5.c" -o "$out/5.o"
"$ICK_CC" $flags $includes -c "$LEAF_ROOT/subpixel/src/coverage_plane.c" -o "$out/plane.o"
"$ICK_CC" $flags $includes -c "$LEAF_ROOT/src/subpixel_framebuffer.c" -o "$out/blend.o"
"$ICK_CC" $flags $includes -c "$FLOWER_ROOT/src/flower.c" -o "$out/flower.o"
"$ICK_CC" $flags $includes -c "$FLOWER_ROOT/src/flower_mesh.c" -o "$out/mesh.o"
"$ICK_CC" $flags $includes -c "$FLOWER_ROOT/src/flower_construction.c" -o "$out/construction.o"
"$ICK_CC" $flags $includes -c "$FLOWER_ROOT/src/flower_subpixel.c" -o "$out/adapter.o"
"$ICK_CC" $flags $includes -c "$root/verify.c" -o "$out/oracle.o"
"$ICK_CC" $flags -c "$root/../subpixel/receipt_check.c" -o "$out/receipt.o"
"$HOST_LINKER" "$out/receipt.o" -o "$out/receipt-check"
for obj in 3 5 plane blend flower mesh construction adapter oracle receipt; do
    readelf -h "$out/$obj.o" | grep -q 'Machine:.*Advanced Micro Devices X86-64'
done

run_verify() {
    target=$1
    object3=$2
    object_plane=$3
    object_blend=$4
    "$HOST_LINKER" "$object3" "$out/5.o" "$object_plane" "$object_blend" \
        "$out/flower.o" "$out/mesh.o" "$out/construction.o" \
        "$out/adapter.o" "$out/oracle.o" -lm -o "$target"
}
run_verify "$out/verify" "$out/3.o" "$out/plane.o" "$out/blend.o"
"$out/verify"

# Real compiled source mutants, each linked successfully and rejected by
# the unchanged independent oracle. Merely failing compilation is NOT a pass.
mutate() {
    source=$1 before=$2 after=$3 destination=$4
    awk -v before="$before" -v after="$after" \
      '{if($0==before) {print after; count++} else print} END{if(count!=1) exit 13}' \
      "$source" > "$destination"
}
expect_reject() {
    mutant=$1 category=$2
    if "$out/$mutant" > "$out/$mutant.log" 2>&1; then
        echo "FALSE ACCEPT: $mutant" >&2
        exit 1
    fi
    grep -Fq "AICI_FLOWER_SUBPIXEL_REJECT $category" "$out/$mutant.log" || {
        cat "$out/$mutant.log" >&2
        echo "MUTANT did not reach expected independent oracle: $mutant" >&2
        exit 1
    }
    echo "compiled mutant rejected by $category: $mutant"
}
mutate "$LEAF_ROOT/subpixel/src/curve_patch.c" \
    '                pixel_y + ((double)sample_y + 0.5) / CP_SUBPIXEL_SIDE - 0.5' \
    '                pixel_y + ((double)sample_x + 0.5) / CP_SUBPIXEL_SIDE - 0.5' \
    "$out/mutant-diagonal.c"
"$ICK_CC" $flags $includes -c "$out/mutant-diagonal.c" -o "$out/mutant-diagonal.o"
run_verify "$out/mutant-diagonal" "$out/mutant-diagonal.o" "$out/plane.o" "$out/blend.o"
expect_reject mutant-diagonal diagonal-oracle

mutate "$LEAF_ROOT/subpixel/src/coverage_plane.c" \
    '    plane->occupied[(size_t)row * plane->stride_words + (size_t)column] |= mask;' \
    '    plane->occupied[(size_t)row * plane->width + (size_t)column] |= mask;' \
    "$out/mutant-stride.c"
"$ICK_CC" $flags $includes -c "$out/mutant-stride.c" -o "$out/mutant-stride.o"
run_verify "$out/mutant-stride" "$out/3.o" "$out/mutant-stride.o" "$out/blend.o"
expect_reject mutant-stride stride-oracle

mutate "$LEAF_ROOT/subpixel/src/coverage_plane.c" \
    '    plane->occupied[(size_t)row * plane->stride_words + (size_t)column] |= mask;' \
    '    plane->occupied[(size_t)row * plane->stride_words + (size_t)column] = mask;' \
    "$out/mutant-union.c"
"$ICK_CC" $flags $includes -c "$out/mutant-union.c" -o "$out/mutant-union.o"
run_verify "$out/mutant-union" "$out/3.o" "$out/mutant-union.o" "$out/blend.o"
expect_reject mutant-union mask-union-oracle

mutate "$LEAF_ROOT/src/subpixel_framebuffer.c" \
    '            double source_alpha = source_base_alpha * occupied_samples(mask) / 64.0;' \
    '            double source_alpha = source_base_alpha * occupied_samples(mask) / 32.0;' \
    "$out/mutant-alpha.c"
"$ICK_CC" $flags $includes -c "$out/mutant-alpha.c" -o "$out/mutant-alpha.o"
run_verify "$out/mutant-alpha" "$out/3.o" "$out/plane.o" "$out/mutant-alpha.o"
expect_reject mutant-alpha alpha-oracle

printf 'aici_flower_commit\t%s\n' "$flower_pin"
printf 'aici_subpixel_commit\t%s\n' "$leaf_pin"
printf 'aici_ick_commit\t%s\n' "$ick_pin"
printf 'aici_frontend\t%s\n' "$cc1"
sha256sum "$ICK_CC" "$cc1" "$out/oracle.o" "$out/verify" \
    "$out/mutant-diagonal.o" "$out/mutant-stride.o" \
    "$out/mutant-union.o" "$out/mutant-alpha.o"
echo 'AICI_FLOWER_SUBPIXEL_ACCEPT 3x3/5x5 Flower material masks + four compiled source mutants: PASS'
