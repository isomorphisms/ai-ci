#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
  echo "usage: $0 COMPILER COMPILER_REVISION" >&2
  exit 2
fi

compiler=$1
compiler_revision=$2

if [ ! -x "$compiler" ]; then
  echo "compiler is not executable: $compiler" >&2
  exit 2
fi

work=$(mktemp -d "${TMPDIR:-/tmp}/aici-tinyidris.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
cd "$work"

cat > TinyIdrisHole.idr <<'IDRIS'
module TinyIdrisHole

duplicate :
  {0 value_type : Type} →
  (1 value : value_type) →
  (value_type, value_type)
duplicate value = ?duplicate_right
IDRIS

cat > TinyIdrisDouble.idr <<'IDRIS'
module TinyIdrisDouble

duplicate_bad :
  {0 value_type : Type} →
  (1 value : value_type) →
  (value_type, value_type)
duplicate_bad value = (value, value)
IDRIS

cat > TinyIdrisPositive.idr <<'IDRIS'
module TinyIdrisPositive

%noinline
keep_once :
  {0 value_type : Type} →
  (1 value : value_type) →
  value_type
keep_once value = value

duplicate_unrestricted :
  {0 value_type : Type} →
  value_type →
  (value_type, value_type)
duplicate_unrestricted value = (value, value)

main : IO ()
main = printLn (keep_once {value_type = Int} 7)
IDRIS

if "$compiler" --check --no-color --console-width 0 TinyIdrisHole.idr > hole.log 2>&1; then
  hole_exit=0
else
  hole_exit=$?
fi

if "$compiler" --check --no-color --console-width 0 TinyIdrisDouble.idr > double.log 2>&1; then
  double_exit=0
else
  double_exit=$?
fi

if "$compiler" --no-color --console-width 0 \
    --dumpanf TinyIdrisPositive.anf \
    --output TinyIdrisPositive.bin TinyIdrisPositive.idr > positive.log 2>&1; then
  positive_exit=0
else
  positive_exit=$?
fi

first_nonempty() {
  awk 'NF { gsub(/\t/, " "); gsub(/\r/, ""); print; exit }' "$1"
}

first_matching() {
  pattern=$1
  file=$2
  awk -v pattern="$pattern" 'index($0, pattern) { gsub(/\t/, " "); gsub(/\r/, ""); print; exit }' "$file"
}

emit() {
  check=$1
  status=$2
  command=$3
  exit_status=$4
  evidence=$5
  evidence=$(printf '%s' "$evidence" | tr '\t\r\n' '   ')
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$check" "$status" "$compiler_revision" "$command" "$exit_status" "$evidence"
}

failed=0
printf 'check\tstatus\tcompiler_revision\tcommand\texit_status\tevidence\n'

hole_command="$compiler --check --no-color --console-width 0 TinyIdrisHole.idr"
if [ "$hole_exit" -ne 0 ] && \
   grep -Fq 'Unsolved holes' hole.log && \
   grep -Fq 'duplicate_right' hole.log; then
  hole_evidence=$(first_matching 'duplicate_right' hole.log)
  emit unicode_arrow_parse PASS "$hole_command" "$hole_exit" "$hole_evidence"
  emit named_hole_reported PASS "$hole_command" "$hole_exit" "$hole_evidence"
else
  hole_evidence=$(first_nonempty hole.log)
  emit unicode_arrow_parse FAIL "$hole_command" "$hole_exit" "$hole_evidence"
  emit named_hole_reported FAIL "$hole_command" "$hole_exit" "$hole_evidence"
  failed=1
fi

double_command="$compiler --check --no-color --console-width 0 TinyIdrisDouble.idr"
if [ "$double_exit" -ne 0 ] && \
   grep -Fq 'uses of linear name' double.log && \
   grep -Fq 'value' double.log && \
   grep -Fq 'must be used exactly once' double.log; then
  double_evidence=$(first_matching 'uses of linear name' double.log)
  emit linear_double_use_rejects PASS "$double_command" "$double_exit" "$double_evidence"
else
  double_evidence=$(first_nonempty double.log)
  emit linear_double_use_rejects FAIL "$double_command" "$double_exit" "$double_evidence"
  failed=1
fi

positive_command="$compiler --no-color --console-width 0 --dumpanf TinyIdrisPositive.anf --output TinyIdrisPositive.bin TinyIdrisPositive.idr"
if [ "$positive_exit" -eq 0 ]; then
  emit linear_single_use_accepts PASS "$positive_command" "$positive_exit" 'compiler accepted keep_once with one use of the linear value'
  emit unrestricted_duplicate_accepts PASS "$positive_command" "$positive_exit" 'compiler accepted duplicate_unrestricted with two uses of an unrestricted value'
else
  positive_evidence=$(first_nonempty positive.log)
  emit linear_single_use_accepts FAIL "$positive_command" "$positive_exit" "$positive_evidence"
  emit unrestricted_duplicate_accepts FAIL "$positive_command" "$positive_exit" "$positive_evidence"
  failed=1
fi

if [ "$positive_exit" -eq 0 ] && [ -s TinyIdrisPositive.anf ]; then
  erasure_evidence=$(awk 'index($0, "keep_once") && index($0, "[__]") { gsub(/\t/, " "); gsub(/\r/, ""); print; exit }' TinyIdrisPositive.anf)
  if [ -n "$erasure_evidence" ]; then
    emit type_argument_erasure_observed PASS "$positive_command" "$positive_exit" "$erasure_evidence"
  else
    probe_evidence=$(first_matching 'keep_once' TinyIdrisPositive.anf)
    if [ -n "$probe_evidence" ]; then
      emit type_argument_erasure_observed NOT_VERIFIED "$positive_command" "$positive_exit" "ANF contains keep_once but no explicit [__] erased-argument marker: $probe_evidence"
    else
      emit type_argument_erasure_observed NOT_VERIFIED "$positive_command" "$positive_exit" 'ANF dump contains no keep_once line exposing the erased type argument'
    fi
  fi
else
  erasure_evidence=$(first_nonempty positive.log)
  emit type_argument_erasure_observed NOT_VERIFIED "$positive_command" "$positive_exit" "ANF stage was not available for inspection: $erasure_evidence"
fi

exit "$failed"
