#!/usr/bin/env bash
# Shared release policy. Receipts are data, never executable shell.
set -euo pipefail
fail() { printf 'AICI-RELEASE-%s: %s\n' "$1" "$2" >&2; exit 1; }
sha() { sha256sum -- "$1" | awk '{print $1}'; }
json() {
    [[ -s $1 && -f $1 && ! -L $1 ]] || fail JSON 'missing regular JSON file'
    jq -e -s 'length == 1 and (.[0] | type == "object")' "$1" >/dev/null || fail JSON 'one JSON object required'
    # Terminate input explicitly: jq 1.7 stream/slurp can split its final event
    # into another result when a file has no trailing newline.
    { cat -- "$1"; printf '\n'; } | jq --stream -s -e 'map(if length == 2 then .[0] else .[0][0:-1] end) as $p | ($p|length) == ($p|unique|length)' >/dev/null || fail JSON 'duplicate JSON fields'
}
property() {
    [[ $# == 2 && -s $1 && $2 =~ ^[a-zA-Z_][a-zA-Z_0-9]*$ ]] || fail PROPERTY 'file and property required'
    awk -v key="$2" 'index($0,key "=")==1 {n++; value=substr($0,length(key)+2)} END {if(n!=1 || value=="") exit 1; print value}' "$1" || fail PROPERTY 'missing, empty or duplicate property'
}
verify_run() {
    [[ $# == 5 ]] || fail RUN 'expected run JSON, repository, source SHA, run ID and workflow path'
    json "$1"
    jq -e --arg repo "$2" --arg source "$3" --arg id "$4" --arg path "$5" '
      (.repository.full_name == $repo) and (.head_repository.full_name == $repo) and
      (.head_sha == $source) and (.id|tostring) == $id and
      (.head_sha|test("^[0-9a-f]{40}$")) and ($id|test("^[1-9][0-9]*$")) and
      .event == "push" and .head_branch == "main" and .path == $path and
      .status == "completed" and .conclusion == "success" and
      (.run_attempt|type == "number") and .run_attempt >= 1
    ' "$1" >/dev/null || fail RUN 'wrong source, repository, run, workflow, event or result'
}
physical() {
    [[ $# == 4 ]] || fail ACCEPTANCE 'expected context, observation, signed APK and unsigned APK'
    local expected=$1 receipt=$2 candidate=$3 unsigned=$4
    json "$expected"; json "$receipt"
    [[ -s $candidate && -f $candidate && ! -L $candidate && -s $unsigned && -f $unsigned && ! -L $unsigned ]] || fail ARTIFACT 'missing regular APK bytes'
    jq -e --arg signed "$(sha "$candidate")" --arg unsigned "$(sha "$unsigned")" '
      .schema == "release-context-v1" and
      (.binding|keys) == (["repository","source_sha","fdroid_run_id","fdroid_run_attempt","package_id","version_name","version_code","candidate_apk_sha256","unsigned_apk_sha256"]|sort) and
      (.binding.source_sha|test("^[0-9a-f]{40}$")) and
      (.binding.repository|test("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$")) and
      (.binding.package_id|test("^[A-Za-z][A-Za-z0-9_.]+$")) and
      (.binding.version_name|test("^[0-9]+[.][0-9]+[.][0-9]+$")) and
      (all(.binding.fdroid_run_id,.binding.fdroid_run_attempt,.binding.version_code; type == "string" and test("^[1-9][0-9]*$"))) and
      .binding.candidate_apk_sha256 == $signed and .binding.unsigned_apk_sha256 == $unsigned and $signed != $unsigned and
      (.required_checks|type == "array" and length > 0) and
      (.required_checks|length) == (.required_checks|unique|length) and
      all(.required_checks[]; type == "string" and test("^[a-z][a-z0-9_-]+$")) and
      (.built_at|fromdateiso8601) <= now
    ' "$expected" >/dev/null || fail ARTIFACT 'context or actual APK hashes do not match'
    jq -e --slurpfile expected "$expected" '
      def text: type == "string" and test("\\S");
      $expected[0] as $e |
      .schema == "physical-acceptance-v1" and .binding == $e.binding and
      .decision == "accepted" and (.observed_by|text) and (.report_reference|text) and
      .device.kind == "physical" and (.device.model|text) and (.device.android_version|text) and
      (.observed_at|fromdateiso8601) >= ($e.built_at|fromdateiso8601) and
      (.observed_at|fromdateiso8601) <= now and
      (.checks|keys) == ($e.required_checks|sort) and
      all(.checks[]; .result == "PASS" and (.detail|text))
    ' "$receipt" >/dev/null || fail ACCEPTANCE 'missing, stale, failed, emulated or mismatched physical observation'
    printf 'PASS: exact-APK physical observation; receipt_sha256=%s\n' "$(sha "$receipt")"
}
# A 404 means absent. Permission, transport, rate-limit and parse failures do not.
get_optional() {
    local endpoint=$1 output=$2
    if gh api "$endpoint" > "$output" 2> "$scratch/api-error"; then
        json "$output"
    elif grep -Eq '^gh: .*\(HTTP 404\)$' "$scratch/api-error"; then
        printf 'null\n' > "$output"
    else
        cat "$scratch/api-error" >&2
        fail API 'lookup failed; absence was not established'
    fi
}
coordinates() {
    [[ $1 =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ && $2 =~ ^[0-9a-f]{40}$ ]] || fail IDENTITY 'repository or source identity invalid'
}
tag_accepted() {
    [[ $# == 7 ]] || fail TAG 'expected repo, tag, source, context, observation and both APKs'
    local repo=$1 tag=$2 source=$3 context=$4 receipt=$5 candidate=$6 unsigned=$7
    coordinates "$repo" "$source"
    [[ $tag =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail TAG 'stable version tag required'
    physical "$context" "$receipt" "$candidate" "$unsigned"
    jq -e --arg repo "$repo" --arg source "$source" --arg tag "$tag" '.binding.repository == $repo and .binding.source_sha == $source and ("v" + .binding.version_name) == $tag' "$context" >/dev/null || fail TAG 'tag/context mismatch'
    local note object
    note=$(printf 'Accepted physical candidate\nsource=%s\nacceptance_sha256=%s\ncandidate_sha256=%s' "$source" "$(sha "$receipt")" "$(sha "$candidate")")
    get_optional "repos/$repo/git/ref/tags/$tag" "$scratch/tag.json"
    if jq -e '. != null' "$scratch/tag.json" >/dev/null; then
        [[ $(jq -r '.object.type' "$scratch/tag.json") == tag ]] || fail TAG 'existing stable tag lacks acceptance annotation'
        object=$(jq -r '.object.sha' "$scratch/tag.json")
        [[ $object =~ ^[0-9a-f]{40}$ ]] || fail TAG 'invalid existing tag object'
        gh api "repos/$repo/git/tags/$object" > "$scratch/annotation.json"
        jq -e --arg source "$source" --arg note "$note" '.object.type == "commit" and .object.sha == $source and .message == $note' "$scratch/annotation.json" >/dev/null || fail TAG 'existing tag or acceptance differs'
        echo 'PASS: identical accepted stable tag already exists'; return
    fi
    object=$(gh api --method POST "repos/$repo/git/tags" -f tag="$tag" -f message="$note" -f object="$source" -f type=commit --jq '.sha')
    [[ $object =~ ^[0-9a-f]{40}$ ]] || fail TAG 'invalid created annotation identity'
    gh api --method POST "repos/$repo/git/refs" -f ref="refs/tags/$tag" -f sha="$object" >/dev/null
    echo 'PASS: accepted immutable stable tag created'
}
publish_test() {
    [[ $# == 6 ]] || fail TEST 'expected repo, source, run ID, attempt, version and asset directory'
    local repo=$1 source=$2 run=$3 attempt=$4 version=$5 dir=$6 tag name id release_id file
    coordinates "$repo" "$source"
    [[ $run =~ ^[1-9][0-9]*$ && $attempt =~ ^[1-9][0-9]*$ && $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail TEST 'invalid test identity'
    tag="test-v$version-$source-run$run-a$attempt"
    [[ -d $dir && ! -L $dir ]] || fail TEST 'asset directory missing'
    local -a files=() missing=()
    shopt -s nullglob dotglob
    for file in "$dir"/*; do
        name=$(basename "$file")
        [[ $name =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ && -f $file && -s $file && ! -L $file ]] || fail TEST 'unsafe or empty asset'
        files+=("$file")
    done
    (( ${#files[@]} > 0 )) || fail TEST 'no assets'
    get_optional "repos/$repo/releases/tags/$tag" "$scratch/release.json"
    if jq -e '. != null' "$scratch/release.json" >/dev/null; then
        jq -e --arg tag "$tag" '.tag_name == $tag and .prerelease == true and .draft == false and (.assets|type == "array") and ([.assets[].name]|length) == ([.assets[].name]|unique|length)' "$scratch/release.json" >/dev/null || fail TEST 'refusing stable, draft or malformed existing release'
        while IFS= read -r name; do
            [[ $name =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ && -f $dir/$name ]] || fail TEST 'unexpected existing asset'
        done < <(jq -r '.assets[].name' "$scratch/release.json")
        for file in "${files[@]}"; do
            name=$(basename "$file")
            id=$(jq -r --arg name "$name" '.assets[] | select(.name == $name) | .id' "$scratch/release.json")
            if [[ -n $id ]]; then
                [[ $id =~ ^[1-9][0-9]*$ ]] || fail TEST 'invalid existing asset identity'
                gh api -H 'Accept: application/octet-stream' "repos/$repo/releases/assets/$id" > "$scratch/existing-asset"
                cmp -s "$file" "$scratch/existing-asset" || fail TEST 'existing asset bytes differ; no overwrite performed'
            else missing+=("$file"); fi
        done
    else missing=("${files[@]}"); fi
    get_optional "repos/$repo/git/ref/tags/$tag" "$scratch/tag.json"
    if jq -e '. != null' "$scratch/tag.json" >/dev/null; then
        jq -e --arg source "$source" '.object.type == "commit" and .object.sha == $source' "$scratch/tag.json" >/dev/null || fail TEST 'test tag identifies different source'
    else
        # An existing release without its expected tag is inconsistent, not repair authority.
        jq -e '. == null' "$scratch/release.json" >/dev/null || fail TEST 'existing release has no matching tag'
        gh api --method POST "repos/$repo/git/refs" -f ref="refs/tags/$tag" -f sha="$source" >/dev/null
    fi
    if jq -e '. == null' "$scratch/release.json" >/dev/null; then
        gh release create "$tag" --repo "$repo" --verify-tag --prerelease --latest=false \
          --title "Android test $version / run $run attempt $attempt" \
          --notes "Test-only APKs from source $source, run $run attempt $attempt. Not a stable release or F-Droid publication."
    fi
    if (( ${#missing[@]} > 0 )); then
        gh release upload "$tag" "${missing[@]}" --repo "$repo"
    fi
    printf 'PASS: immutable test publication %s\n' "$tag"
}
[[ $# -gt 0 ]] || fail USAGE 'property | verify-run | physical | tag-accepted | publish-test'
command=$1; shift
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
case "$command" in
    property) property "$@" ;;
    verify-run) verify_run "$@" ;;
    physical) physical "$@" ;;
    tag-accepted) tag_accepted "$@" ;;
    publish-test) publish_test "$@" ;;
    *) fail USAGE 'unknown operation' ;;
esac
