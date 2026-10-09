#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
count=0
ok() { "$@" > "$work/output" 2>&1 || { cat "$work/output"; exit 1; }; count=$((count+1)); }
bad() {
    local code=$1; shift
    if "$@" > "$work/output" 2>&1; then echo "Unexpected acceptance: $*"; exit 1; fi
    grep -Fq "AICI-RELEASE-$code:" "$work/output" || { cat "$work/output"; exit 1; }
    count=$((count+1))
}
printf 'synthetic signed payload\n' > "$work/candidate.apk"
printf 'synthetic unsigned payload\n' > "$work/unsigned.apk"
source_sha=$(printf 'a%.0s' {1..40})
other_sha=$(printf 'b%.0s' {1..40})
jq -n --arg sha "$source_sha" \
  --arg signed "$(sha256sum "$work/candidate.apk"|awk '{print $1}')" \
  --arg unsigned "$(sha256sum "$work/unsigned.apk"|awk '{print $1}')" \
  '{schema:"release-context-v1",built_at:((now-120)|floor|todateiso8601),
    binding:{repository:"example/app",source_sha:$sha,fdroid_run_id:"42",fdroid_run_attempt:"1",
      package_id:"org.example.app",version_name:"0.2.0",version_code:"101",
      candidate_apk_sha256:$signed,unsigned_apk_sha256:$unsigned},required_checks:["replace_install","render"]}' > "$work/context"
jq '{schema:"physical-acceptance-v1",binding,decision:"accepted",observed_by:"synthetic fixture",
  report_reference:"synthetic test, not physical evidence",observed_at:((now-60)|floor|todateiso8601),
  device:{kind:"physical",model:"synthetic fixture",android_version:"34"},
  checks:{replace_install:{result:"PASS",detail:"synthetic result"},render:{result:"PASS",detail:"synthetic result"}}}' "$work/context" > "$work/receipt"
physical() { bash "$root/gate.sh" physical "$work/context" "$1" "$work/candidate.apk" "$work/unsigned.apk"; }
ok physical "$work/receipt"
for mutation in \
  '.decision="NOT_RUN"' '.decision="rejected"' '.device.kind="emulator"' \
  '.binding.source_sha="bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"' \
  '.binding.fdroid_run_id="43"' '.binding.fdroid_run_attempt="2"' \
  '.binding.candidate_apk_sha256="wrong"' '.binding.unsigned_apk_sha256="wrong"' \
  '.binding.version_code="102"' '.binding.package_id="org.wrong.app"' \
  '.checks.render.result="FAIL"' '.checks.render.result="NOT_RUN"' \
  'del(.checks.render)' '.checks.extra={result:"PASS",detail:"extra"}' \
  '.checks.render.detail=" "' '.observed_by=" "' 'del(.report_reference)' \
  '.device.model=""' '.observed_at="2000-01-01T00:00:00Z"' \
  '.observed_at="2999-01-01T00:00:00Z"'; do
    jq "$mutation" "$work/receipt" > "$work/bad"
    bad ACCEPTANCE physical "$work/bad"
done
bad JSON physical "$work/missing"
printf '{"decision":"rejected","decision":"accepted"}\n' > "$work/bad"
bad JSON physical "$work/bad"
# Count container nodes as well as leaves. Duplicate parents can have
# empty or disjoint children without any duplicate leaf path.
for prefix in '"device":{},' '"device":{"extra":"ignored"},' '"checks":{},'; do
    { printf '{%s' "$prefix"; tail -c +2 "$work/receipt"; } > "$work/bad"
    bad JSON physical "$work/bad"
done
jq '.required_checks=[]' "$work/context" > "$work/context-empty"
bad ARTIFACT bash "$root/gate.sh" physical "$work/context-empty" "$work/receipt" "$work/candidate.apk" "$work/unsigned.apk"
cat "$work/receipt" "$work/receipt" > "$work/bad"
bad JSON physical "$work/bad"
printf 'changed\n' >> "$work/candidate.apk"
bad ARTIFACT physical "$work/receipt"
printf 'synthetic signed payload\n' > "$work/candidate.apk"
printf 'version=1\nversion=2\n' > "$work/properties"
bad PROPERTY bash "$root/gate.sh" property "$work/properties" version
printf 'version=1\n' > "$work/properties"
ok bash "$root/gate.sh" property "$work/properties" version
jq -n --arg sha "$source_sha" '{id:42,head_sha:$sha,repository:{full_name:"example/app"},head_repository:{full_name:"example/app"},event:"push",head_branch:"main",path:".github/workflows/build.yml",status:"completed",conclusion:"success",run_attempt:1}' > "$work/run"
ok bash "$root/gate.sh" verify-run "$work/run" example/app "$source_sha" 42 .github/workflows/build.yml
for mutation in '.conclusion="failure"' '.event="pull_request"' '.head_branch="candidate"' '.head_repository.full_name="fork/app"' '.id=43' '.path="other.yml"' '.status="in_progress"'; do
    jq "$mutation" "$work/run" > "$work/bad-run"
    bad RUN bash "$root/gate.sh" verify-run "$work/bad-run" example/app "$source_sha" 42 .github/workflows/build.yml
done
mkdir "$work/bin" "$work/assets"
cp "$work/candidate.apk" "$work/assets/candidate.apk"
cat > "$work/bin/gh" <<'FAKE'
#!/usr/bin/env bash
set -euo pipefail
{ printf '%q ' "$@"; printf '\n'; } >> "$TEST_LOG"
if [[ $* == *'--method POST'* || $1 == release ]]; then
    { printf '%q ' "$@"; printf '\n'; } >> "$TEST_WRITES"
    if [[ $* == *'/git/tags '* ]]; then printf '%s\n' "$OTHER_SHA"; else echo '{}'; fi
    exit 0
fi
case "$*" in
  *'/releases/tags/'*)
    if [[ $SCENARIO == api-error ]]; then echo 'gh: Forbidden (HTTP 403)' >&2; exit 1; fi
    if [[ $SCENARIO == fresh ]]; then echo 'gh: Not Found (HTTP 404)' >&2; exit 1; fi
    jq -n --arg tag "$TEST_TAG" --arg s "$SCENARIO" '{tag_name:$tag,prerelease:($s!="stable"),draft:($s=="draft"),assets:(if $s=="missing-asset" then [] else [{id:7,name:(if $s=="unexpected" then "other.apk" else "candidate.apk" end)}] end)}' ;;
  *'/releases/assets/'*)
    if [[ $SCENARIO == different ]]; then echo changed; else cat "$TEST_APK"; fi ;;
  *'/git/ref/tags/'*)
    if [[ $SCENARIO == fresh ]]; then echo 'gh: Not Found (HTTP 404)' >&2; exit 1; fi
    jq -n --arg sha "$SOURCE_SHA" --arg other "$OTHER_SHA" --arg s "$SCENARIO" '{object:{type:(if $s=="accepted-tag" or $s=="changed-acceptance" then "tag" else "commit" end),sha:(if $s=="wrong-tag" then $other else $sha end)}}' ;;
  *'/git/tags/'*)
    jq -n --arg source "$SOURCE_SHA" --arg note "$TEST_NOTE" --arg s "$SCENARIO" '{object:{type:"commit",sha:$source},message:(if $s=="changed-acceptance" then "different" else $note end)}' ;;
  *) echo "Unexpected fake call: $*" >&2; exit 99 ;;
esac
FAKE
chmod +x "$work/bin/gh"
export PATH="$work/bin:$PATH" SOURCE_SHA="$source_sha" OTHER_SHA="$other_sha"
export TEST_LOG="$work/log" TEST_WRITES="$work/writes" TEST_APK="$work/candidate.apk"
export TEST_TAG="test-v0.2.0-$source_sha-run42-a1"
export TEST_NOTE="$(printf 'Accepted physical candidate\nsource=%s\nacceptance_sha256=%s\ncandidate_sha256=%s' "$source_sha" "$(sha256sum "$work/receipt"|awk '{print $1}')" "$(sha256sum "$work/candidate.apk"|awk '{print $1}')")"
publish() { bash "$root/gate.sh" publish-test example/app "$source_sha" 42 1 0.2.0 "$work/assets"; }
clean() { : > "$TEST_WRITES"; : > "$TEST_LOG"; export SCENARIO=$1; }
no_writes() { [[ ! -s $TEST_WRITES ]] || { cat "$TEST_WRITES"; exit 1; }; }
clean fresh
ok publish
[[ $(wc -l < "$TEST_WRITES") == 3 ]]
grep -Fq "refs/tags/$TEST_TAG" "$TEST_WRITES"
if grep -Eq -- '--clobber|release edit|--force' "$TEST_LOG"; then exit 1; fi
clean identical
ok publish
no_writes
clean missing-asset
ok publish
[[ $(wc -l < "$TEST_WRITES") == 1 ]]
for scenario in different stable draft wrong-tag unexpected; do
    clean "$scenario"; bad TEST publish; no_writes
done
clean api-error
bad API publish
no_writes
clean fresh
bad TEST bash "$root/gate.sh" publish-test example/app "$source_sha" 42 1 ../stable "$work/assets"
no_writes
accepted_tag() { bash "$root/gate.sh" tag-accepted example/app v0.2.0 "$source_sha" "$work/context" "$1" "$work/candidate.apk" "$work/unsigned.apk"; }
clean fresh
bad JSON accepted_tag "$work/missing"
no_writes
ok accepted_tag "$work/receipt"
[[ $(wc -l < "$TEST_WRITES") == 2 ]]
clean accepted-tag
ok accepted_tag "$work/receipt"
no_writes
clean changed-acceptance
bad TAG accepted_tag "$work/receipt"
no_writes
printf 'PASS: %s release-promotion cases; synthetic fixtures, no live publication or physical-device claim\n' "$count"
