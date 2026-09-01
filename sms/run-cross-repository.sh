#!/usr/bin/env bash

set -Eeuo pipefail

idric_net_input=${1:?usage: run-cross-repository.sh IDRIC_NET GREASE IDRIC_REPO}
grease_input=${2:?usage: run-cross-repository.sh IDRIC_NET GREASE IDRIC_REPO}
idric_input=${3:?usage: run-cross-repository.sh IDRIC_NET GREASE IDRIC_REPO}
here=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
aici=$(CDPATH='' cd -- "$here/.." && pwd)
idric_net=$(CDPATH='' cd -- "$idric_net_input" && pwd)
grease=$(CDPATH='' cd -- "$grease_input" && pwd)
idric=$(CDPATH='' cd -- "$idric_input" && pwd)
compiler="$idric/build/exec/idris2"
idris_prefix=${IDRIS2_PREFIX:-"$idric/bootstrap-build"}
LD_LIBRARY_PATH="$idris_prefix/idris2-0.8.0/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export IDRIS2_PREFIX="$idris_prefix" LD_LIBRARY_PATH
scheme=${IDRIC_SCHEME:-scheme}
case "$scheme" in
  */*) PATH="$(dirname -- "$scheme"):$PATH"; export PATH ;;
esac
receipt=${SMS_CURRENT_HEAD_RECEIPT:-"$aici/sms/build/current-head-receipt.tsv"}
log=${SMS_CURRENT_HEAD_LOG:-"$aici/sms/build/current-head.log"}
current_stage=compiler_build
passed='repository_checkouts'

mkdir -p "$(dirname -- "$receipt")"
: > "$log"

repo_sha() { git -C "$1" rev-parse HEAD; }
repo_dirty() {
  if git -C "$1" status --porcelain | grep -q .; then printf dirty; else printf clean; fi
}

aici_sha=$(repo_sha "$aici")
idric_sha=$(repo_sha "$idric")
idric_net_sha=$(repo_sha "$idric_net")
grease_sha=$(repo_sha "$grease")
aici_dirty=$(repo_dirty "$aici")
idric_dirty=$(repo_dirty "$idric")
idric_net_dirty=$(repo_dirty "$idric_net")
grease_dirty=$(repo_dirty "$grease")

write_receipt() {
  outcome=$1
  diagnostic=${2:-none}
  {
    printf 'CURRENT_HEAD_COMPATIBILITY\t1\n'
    printf 'dependency\tisomorphisms/ai-ci\t%s\t%s\t%s\n' "${AICI_REF:-sms-cross-repository-receipt}" "$aici_sha" "$aici_dirty"
    printf 'dependency\tisomorphisms/Idric\t%s\t%s\t%s\n' "${IDRIC_REF:-Idriç}" "$idric_sha" "$idric_dirty"
    printf 'dependency\tisomorphisms/Idric-Net\t%s\t%s\t%s\n' "${IDRIC_NET_REF:-sms-server-foundation}" "$idric_net_sha" "$idric_net_dirty"
    printf 'dependency\tisomorphisms/grease\t%s\t%s\t%s\n' "${GREASE_REF:-sms-server-filesystem-foundation}" "$grease_sha" "$grease_dirty"
    for stage in repository_checkouts compiler_build parser_build grease_service_tests cross_repository_probe hostile_self_tests; do
      if [[ " $passed " == *" $stage "* ]]; then
        printf 'stage\t%s\tPASS\n' "$stage"
      elif [[ $stage == "$current_stage" ]]; then
        printf 'stage\t%s\t%s\n' "$stage" "$outcome"
      else
        printf 'stage\t%s\tSKIP\tprerequisite_not_met\n' "$stage"
      fi
    done
    if [[ $outcome == FAIL ]]; then
      printf 'first_failure\t%s\t%s\n' "$current_stage" "$diagnostic"
    else
      printf 'first_failure\tnone\n'
    fi
  } > "$receipt"
}

fail_receipt() {
  status=$?
  trap - ERR
  diagnostic=$(grep -E '(^FAIL|^Error:|^usage:|unsupported|rejected|not found|No such file)' "$log" | tail -n 1 || true)
  [[ -n $diagnostic ]] || diagnostic=$(tail -n 1 "$log" | tr '\t\r\n' '   ')
  write_receipt FAIL "${diagnostic:-exit_$status}"
  cat "$receipt" >&2
  exit "$status"
}
trap fail_receipt ERR

run_logged() {
  "$@" 2>&1 | tee -a "$log"
}

current_stage=compiler_build
if [[ ! -x "$compiler" ]]; then
  run_logged make -C "$idric" bootstrap SCHEME="$scheme"
fi
run_logged "$compiler" --version
passed="$passed compiler_build"

current_stage=parser_build
run_logged make -C "$idric_net" clean sms-request IDRIC="$compiler"
parser="$idric_net/build/exec/idric-sms-request"
service="$grease/services/sms/idric_sms_service.sh"
[ -x "$parser" ] || { printf 'compiled parser is missing: %s\n' "$parser" | tee -a "$log" >&2; false; }
passed="$passed parser_build"

current_stage=grease_service_tests
run_logged env IDRIC_SMS_REQUEST="$parser" make -C "$grease" test
passed="$passed grease_service_tests"

current_stage=cross_repository_probe
run_logged env SMS_SERVICE="$service" IDRIC_SMS_REQUEST="$parser" bash "$here/probe.sh"
passed="$passed cross_repository_probe"

current_stage=hostile_self_tests
hostile_service="$here/fixtures/hostile-service.sh"
for fixture in \
  missing_authorization:authorization_provenance \
  early_send:not_early \
  cancelled_delivery:cancelled_stays_cancelled \
  collapsed_same_time:same_time_distinct
do
  case_name=${fixture%%:*}
  expected=${fixture#*:}
  hostile_log=$(mktemp)
  if REAL_SMS_SERVICE="$service" SMS_HOSTILE_CASE="$case_name" \
      SMS_SERVICE="$hostile_service" IDRIC_SMS_REQUEST="$parser" \
      bash "$here/probe.sh" >"$hostile_log" 2>&1; then
    printf 'broken hostile service passed: %s\n' "$case_name" | tee -a "$log" >&2
    rm -f -- "$hostile_log"
    false
  fi
  expected_line=$(printf 'FAIL\t%s\t' "$expected")
  if ! grep -F "$expected_line" "$hostile_log" >/dev/null; then
    sed -n '1,120p' "$hostile_log" | tee -a "$log" >&2
    printf 'hostile %s did not fail at %s\n' "$case_name" "$expected" | tee -a "$log" >&2
    rm -f -- "$hostile_log"
    false
  fi
  rm -f -- "$hostile_log"
  printf 'PASS\thostile_%s\ttargeted broken service was rejected\n' "$case_name" | tee -a "$log"
done
passed="$passed hostile_self_tests"
current_stage=complete
write_receipt PASS none
trap - ERR
cat "$receipt"
