#!/bin/sh
# Independent oracle for the actual installed NHTSA VIN executable.
set -eu
if [ "$#" -ne 3 ]; then
  printf '%s\n' 'usage: vin-cli-acceptance.sh ABSOLUTE_PROGRAM ABSOLUTE_CLI_ROOT EXPECTED_HEAD' >&2
  exit 2
fi
program=$1
repo=$2
head=$3
case "$program:$repo" in
  /*:/*) ;;
  *) printf '%s\n' 'program and checkout must be absolute paths' >&2; exit 2 ;;
esac
test -x "$program"
test -d "$repo/.git"
test "$(git -C "$repo" rev-parse HEAD)" = "$head"
test -x "$repo/build/exec/nhtsa-vin"
cmp "$program" "$repo/build/exec/nhtsa-vin"
test -s "$(dirname -- "$program")/nhtsa-vin_app/libicu_transport.so"
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT HUP INT TERM
vin=1HGCM82633A004352
cat > "$temporary/response.json" <<'EOF'
{
  "Count": 1,
  "Message": "independently authored synthetic oracle",
  "Results": [{
    "VIN": "1HGCM82633A004352",
    "ModelYear": "2003",
    "Make": "HONDA",
    "Model": "Accord",
    "Trim": "",
    "Series": null,
    "BodyClass": "Coupe",
    "ErrorCode": "1",
    "ErrorText": "Synthetic check digit warning; not a real NHTSA decoding result"
  }]
}
EOF
# Assert typed-state distinctions and provider warnings rather than trusting a
# self-test report or interpreting exit=0 as a clean VIN check digit.
"$program" fixture "$vin" "$temporary/response.json" --tsv > "$temporary/actual"
grep -Fx "$(printf 'VIN\tpresent\t%s' "$vin")" "$temporary/actual"
grep -Fx "$(printf 'ModelYear\tpresent\t2003')" "$temporary/actual"
grep -Fx "$(printf 'Make\tpresent\tHONDA')" "$temporary/actual"
grep -Fx "$(printf 'Trim\tpresent\t')" "$temporary/actual"
grep -Fx "$(printf 'Series\tmissing\t')" "$temporary/actual"
grep -Fx "$(printf 'ErrorCode\tpresent\t1')" "$temporary/actual"
grep -Fx "$(printf 'Evidence\tpresent\tsupplied-fixture; not live provider evidence')" "$temporary/actual"
grep -Fx "$(printf 'URL\tpresent\thttps://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues/%s?format=json' "$vin")" "$temporary/actual"

cat > "$temporary/wrong-vin.json" <<'EOF'
{"Results":[{"VIN":"1HGCM82633A004353","ErrorCode":"0"}]}
EOF
cat > "$temporary/non-string.json" <<'EOF'
{"Results":[{"VIN":"1HGCM82633A004352","ModelYear":2003,"ErrorCode":"0"}]}
EOF
cat > "$temporary/ambiguous.json" <<'EOF'
{"Results":[{"VIN":"1HGCM82633A004352","ErrorCode":"0"},{"VIN":"1HGCM82633A004352","ErrorCode":"0"}]}
EOF
cat > "$temporary/missing-error.json" <<'EOF'
{"Results":[{"VIN":"1HGCM82633A004352","Make":"HONDA"}]}
EOF
reject() {
  expected=$1
  shift
  observed=0
  "$program" "$@" > "$temporary/rejected-output" 2> "$temporary/rejected-error" || observed=$?
  if [ "$observed" -ne "$expected" ] || [ -s "$temporary/rejected-output" ]; then
    printf 'FAIL: wanted rejection %s got %s or unexpected data\n' "$expected" "$observed" >&2
    exit 1
  fi
}
reject 6 fixture "$vin" "$temporary/wrong-vin.json"
reject 6 fixture "$vin" "$temporary/non-string.json"
reject 6 fixture "$vin" "$temporary/ambiguous.json"
reject 6 fixture "$vin" "$temporary/missing-error.json"
reject 2 url "1HGCM82633A00435Q"
reject 2 url "1HGCM82633A004352/../"
reject 2 decode "bad?anything"
reject 2 url "$vin" --modelyear not-a-year
printf 'PASS\tnhtsa-vin independent installed-program oracle (synthetic only)\n'
