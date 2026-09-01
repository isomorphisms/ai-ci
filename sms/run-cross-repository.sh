#!/bin/sh

set -eu

idric_net=${1:?usage: run-cross-repository.sh IDRIC_NET GREASE IDRIC_COMPILER}
grease=${2:?usage: run-cross-repository.sh IDRIC_NET GREASE IDRIC_COMPILER}
compiler=${3:?usage: run-cross-repository.sh IDRIC_NET GREASE IDRIC_COMPILER}
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

make -C "$idric_net" clean sms-request IDRIC="$compiler"
parser=$(CDPATH= cd -- "$idric_net" && pwd)/build/exec/idric-sms-request
service=$(CDPATH= cd -- "$grease" && pwd)/services/sms/idric_sms_service.sh

[ -x "$parser" ] || { printf 'FAIL\tcompiled_parser\tmissing %s\n' "$parser" >&2; exit 1; }
IDRIC_SMS_REQUEST="$parser" make -C "$grease" test
SMS_SERVICE="$service" IDRIC_SMS_REQUEST="$parser" sh "$here/probe.sh"

hostile_service="$here/fixtures/hostile-service.sh"
for fixture in \
  missing_authorization:authorization_provenance \
  early_send:not_early \
  cancelled_delivery:cancelled_stays_cancelled \
  collapsed_same_time:same_time_distinct
do
  case_name=${fixture%%:*}
  expected=${fixture#*:}
  log=$(mktemp)
  if REAL_SMS_SERVICE="$service" SMS_HOSTILE_CASE="$case_name" \
      SMS_SERVICE="$hostile_service" IDRIC_SMS_REQUEST="$parser" \
      sh "$here/probe.sh" >"$log" 2>&1; then
    printf 'FAIL\thostile_%s\tbroken service passed\n' "$case_name" >&2
    rm -f -- "$log"
    exit 1
  fi
  expected_line=$(printf 'FAIL\t%s\t' "$expected")
  if ! grep -F "$expected_line" "$log" >/dev/null; then
    sed -n '1,120p' "$log" >&2
    printf 'FAIL\thostile_%s\tdid not fail at %s\n' "$case_name" "$expected" >&2
    rm -f -- "$log"
    exit 1
  fi
  rm -f -- "$log"
  printf 'PASS\thostile_%s\ttargeted broken service was rejected\n' "$case_name"
done
