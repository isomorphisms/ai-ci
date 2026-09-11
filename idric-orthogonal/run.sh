#!/bin/sh
set -eu

usage() {
  echo "usage: run.sh IDRIC_ROOT EXPECTED_REVISION OUTPUT [PREBUILT_IDRIC_ROOT]" >&2
  exit 2
}

case "$#" in
  3|4) ;;
  *) usage ;;
esac

idric_root=$1
expected_revision=$2
output=$3
prebuilt_root=${4:-}

case "$expected_revision" in
  [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]) ;;
  *) echo "Idric orthogonal gate: expected revision must be a full lowercase commit" >&2; exit 2 ;;
esac

is_worktree=$(git -C "$idric_root" rev-parse --is-inside-work-tree 2>/dev/null || true)
[ "$is_worktree" = true ] || {
  echo "Idric orthogonal gate: not an Idric checkout: $idric_root" >&2
  exit 2
}

actual_revision=$(git -C "$idric_root" rev-parse HEAD)
[ "$actual_revision" = "$expected_revision" ] || {
  echo "Idric orthogonal gate: expected $expected_revision, found $actual_revision" >&2
  exit 1
}

[ -z "$(git -C "$idric_root" status --porcelain --untracked-files=all)" ] || {
  echo "Idric orthogonal gate: checkout must be clean before observation" >&2
  exit 1
}

fixture=tests/idris2/basic/edric009
oracle=examples/unified-higher-mathematics/verify_r128.py
[ -x "$idric_root/edric" ] || { echo "Idric orthogonal gate: edric command missing" >&2; exit 1; }
[ -x "$idric_root/$fixture/run" ] || { echo "Idric orthogonal gate: compiler receipt missing" >&2; exit 1; }
[ -f "$idric_root/$oracle" ] || { echo "Idric orthogonal gate: independent oracle missing" >&2; exit 1; }

tmp_dir=$(mktemp -d)
tmp_output="$output.tmp.$$"
cleanup() {
  rm -rf "$tmp_dir"
  rm -f "$tmp_output"
}
trap cleanup EXIT HUP INT TERM

if [ -z "$prebuilt_root" ]; then
  "$idric_root/edric" bootstrap
  "$idric_root/edric" test --only idris2/basic/edric009
else
  prebuilt_revision=$(git -C "$prebuilt_root" rev-parse HEAD)
  [ "$prebuilt_revision" = "$expected_revision" ] || {
    echo "Idric orthogonal gate: prebuilt compiler is from $prebuilt_revision" >&2
    exit 1
  }
  compiler="$prebuilt_root/build/exec/idris2"
  scheme_dir="$prebuilt_root/.tools/bin"
  support_dir="$prebuilt_root/support/c"
  [ -x "$compiler" ] || { echo "Idric orthogonal gate: prebuilt compiler missing" >&2; exit 1; }
  [ -x "$scheme_dir/scheme" ] || { echo "Idric orthogonal gate: prebuilt Scheme missing" >&2; exit 1; }
  short_revision=$(printf '%.9s' "$expected_revision")
  compiler_version=$(LD_LIBRARY_PATH="$support_dir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" "$compiler" --version)
  case "$compiler_version" in
    *"$short_revision"*) ;;
    *) echo "Idric orthogonal gate: prebuilt compiler version is not revision $short_revision" >&2; exit 1 ;;
  esac
  (
    cd "$idric_root/$fixture"
    PATH="$scheme_dir:$PATH" \
      LD_LIBRARY_PATH="$support_dir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
      ./run "$compiler"
  ) >"$tmp_dir/compiler-receipt.txt"
  if ! diff -u "$idric_root/$fixture/expected" "$tmp_dir/compiler-receipt.txt"; then
    echo "Idric orthogonal gate: compiler receipt differs" >&2
    exit 1
  fi
fi

python3 "$idric_root/$oracle"

mkdir -p "$(dirname -- "$output")"
{
  printf 'IDRIC_ORTHOGONAL_CORE\t1\n'
  printf 'compiler_head\tisomorphisms/Idric\t%s\n' "$expected_revision"
  printf 'verdict\tBOUNDED_GREEN\n'
  printf 'stage\tsemantic_model\tPASS\tcompiler-owned unified higher-mathematics modules imported by edric009\n'
  printf 'stage\tcompiler_typecheck\tPASS\tedric009 ordinary --check path\n'
  printf 'stage\tnegative_typecheck\tPASS\tedric009 compiler failing declarations; no shell diagnostic substitution\n'
  printf 'stage\texact_r128_execution\tPASS\tedric009 compiled executable and exact expected output\n'
  printf 'stage\tindependent_invariant_oracle\tPASS\tIdric-owned dependency-free signed-permutation oracle\n'
  printf 'stage\tbackend_handoff\tNOT_VERIFIED\tno merged generic lowering interface at this compiler revision\n'
  printf 'stage\ttarget_execution\tNOT_VERIFIED\tno backend or hardware target belongs to this semantic receipt\n'
  printf 'scope\texact_sample_carrier\tInteger coordinates in four closed named spaces\n'
  printf 'scope\tclosed_transforms\tidentity, first-axis reflection, first-plane quarter-turn, integral unit-quaternion rotation, composition\n'
  printf 'scope\tsphere_action\tabsent; UnitSpherePoint exists but no transform action preserves its certificate\n'
  printf 'scope\tgeneral_rotation\tabsent; no arbitrary angles, matrices, Householder family, alignment synthesis, or algorithm selection\n'
  printf 'end\n'
} >"$tmp_output"
mv "$tmp_output" "$output"
trap - EXIT HUP INT TERM
