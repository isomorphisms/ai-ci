#!/usr/bin/env bash
set -euo pipefail

header='kind\tname\tstatus\tsource_revision\tfdroiddata_revision\tfdroidserver_revision\timage_digest\tpackage\tversion_name\tversion_code\tabis\twitness\tsha256'

fail() {
    printf 'AICI-FDROID-PRODUCER: %s\n' "$*" >&2
    exit 1
}

need() {
    command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

require_clean_repo() {
    local repo="$1" dirty
    dirty="$(git -C "$repo" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"
    test -z "$dirty" || fail "repository worktree is not clean: $repo"
}

one_contract_row() {
    local contract="$1" kind="$2"
    awk -F '\t' -v kind="$kind" '
        $0 !~ /^[[:space:]]*#/ && $1 == kind { print; count++ }
        END { if (count != 1) exit 2 }
    ' "$contract" || fail "contract must contain exactly one $kind row"
}

contract_profile() {
    one_contract_row "$1" profile | awk -F '\t' '{print $2}'
}

release_field() {
    local row
    row="$(one_contract_row "$1" release)"
    printf '%s\n' "$row" | awk -F '\t' -v n="$2" '{print $n}'
}

toolchain_field() {
    local row
    row="$(one_contract_row "$1" toolchain)"
    printf '%s\n' "$row" | awk -F '\t' -v n="$2" '{print $n}'
}

artifact_row() {
    local contract="$1" name="$2"
    awk -F '\t' -v name="$name" '
        $0 !~ /^[[:space:]]*#/ && $1 == "artifact" && $3 == name { print; count++ }
        END { if (count != 1) exit 2 }
    ' "$contract" || fail "contract must contain exactly one artifact named $name"
}

contract_check() {
    local contract="$1" source data server image
    test -s "$contract" || fail "contract is missing or empty: $contract"
    test "$(contract_profile "$contract")" = candidate-v1 ||
        fail "producer only emits candidate-v1 receipts"
    source="$(release_field "$contract" 6)"
    data="$(toolchain_field "$contract" 3)"
    server="$(toolchain_field "$contract" 4)"
    image="$(toolchain_field "$contract" 5)"
    [[ "$source" =~ ^([0-9a-f]{40}|[0-9a-f]{64})$ ]] || fail "source revision is not immutable"
    [[ "$data" =~ ^([0-9a-f]{40}|[0-9a-f]{64})$ ]] || fail "fdroiddata revision is not immutable"
    [[ "$server" =~ ^([0-9a-f]{40}|[0-9a-f]{64})$ ]] || fail "fdroidserver revision is not immutable"
    [[ "$image" =~ ^[^[:space:]@]+@sha256:[0-9a-f]{64}$ ]] || fail "buildserver image is not pinned by sha256 digest"
}

prepare_root() {
    local root="$1"
    mkdir -p "$root/.producer/check" "$root/.producer/artifact" \
        "$root/.producer/release" "$root/.producer/toolchain" "$root/witnesses/checks" \
        "$root/witnesses/source" "$root/witnesses/toolchain" \
        "$root/witnesses/manual" "$root/witnesses/reproducibility" \
        "$root/artifacts"
}

state_path() {
    printf '%s/.producer/%s/%s.tsv\n' "$1" "$2" "$3"
}

set_state() {
    local root="$1" class="$2" name="$3" status="$4" witness="$5"
    case "$status" in
        pass|fail|not-verified) ;;
        *) fail "invalid internal status: $status" ;;
    esac
    local digest='-'
    if test "$witness" != - && test -s "$root/$witness"; then
        digest="$(sha_file "$root/$witness")"
    fi
    printf '%s\t%s\t%s\n' "$status" "$witness" "$digest" > "$(state_path "$root" "$class" "$name")"
}

get_state() {
    local root="$1" class="$2" name="$3" path
    path="$(state_path "$root" "$class" "$name")"
    if test -s "$path"; then
        cat "$path"
    else
        printf 'not-verified\t-\t-\n'
    fi
}

relative_to_root() {
    local root="$1" path="$2"
    root="$(cd "$root" && pwd)"
    path="$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    case "$path" in
        "$root"/*) printf '%s\n' "${path#"$root"/}" ;;
        *) fail "witness must live below output root: $path" ;;
    esac
}

write_missing_witness() {
    local root="$1" name="$2" path="$root/witnesses/checks/$name.not-verified.txt"
    printf 'status\tnot-verified\nreason\tproducer stage did not run\n' > "$path"
    relative_to_root "$root" "$path"
}

sha_file() {
    sha256sum -- "$1" | awk '{print $1}'
}

quote_command() {
    local arg
    printf 'command'
    for arg in "$@"; do
        printf ' %q' "$arg"
    done
    printf '\n'
}

candidate_check() {
    case "$1" in
        source-public|license-review|dependency-review|tag-binding|version-history|\
        metadata-read|metadata-schema|metadata-rewrite|metadata-lint|update-check|\
        git-redirect|metadata-tools|fastlane|fdroid-build|gradle-audit|\
        build-input-pinning|source-scan|apk-scan|apk-identity|signing-policy|\
        install-launch|upstream-reproducible|signing-key) return 0 ;;
        *) return 1 ;;
    esac
}

manual_check() {
    case "$1" in
        license-review|dependency-review) return 0 ;;
        *) return 1 ;;
    esac
}

cmd_init() {
    test "$#" -eq 2 || fail 'usage: produce-candidate-v1.sh init CONTRACT OUTPUT_ROOT'
    contract_check "$1"
    prepare_root "$2"
    printf 'candidate-v1\n' > "$2/.producer/profile"
}

cmd_source() {
    test "$#" -eq 4 || fail 'usage: produce-candidate-v1.sh source CONTRACT OUTPUT_ROOT SOURCE_REPOSITORY PUBLIC_URL'
    local contract="$1" root="$2" repo="$3" url="$4" expected observed witness public_witness tmp status
    contract_check "$contract"
    prepare_root "$root"
    need git
    expected="$(release_field "$contract" 6)"
    witness="$root/witnesses/source/identity.log"
    tmp="$witness.tmp"
    observed="$(git -C "$repo" rev-parse HEAD 2>/dev/null || true)"
    require_clean_repo "$repo"
    {
        printf 'expected_source_revision\t%s\n' "$expected"
        printf 'observed_source_revision\t%s\n' "$observed"
        printf 'repository\t%s\n' "$(cd "$repo" 2>/dev/null && pwd || printf '%s' "$repo")"
    } > "$tmp"
    status=pass
    test "$observed" = "$expected" || status=fail
    mv "$tmp" "$witness"
    set_state "$root" release identity "$status" "$(relative_to_root "$root" "$witness")"

    public_witness="$root/witnesses/checks/source-public.log"
    tmp="$public_witness.tmp"
    {
        printf 'public_url\t%s\n' "$url"
        printf 'expected_source_revision\t%s\n' "$expected"
        if git ls-remote "$url"; then :; else exit 91; fi
    } > "$tmp" 2>&1 || {
        mv "$tmp" "$public_witness"
        set_state "$root" check source-public fail "$(relative_to_root "$root" "$public_witness")"
        fail 'public source lookup failed'
    }
    if grep -Eq "^${expected}[[:space:]]" "$tmp"; then
        status=pass
    else
        status=fail
    fi
    mv "$tmp" "$public_witness"
    set_state "$root" check source-public "$status" "$(relative_to_root "$root" "$public_witness")"
    test "$status" = pass || fail "public repository does not expose source revision $expected"
    test "$(cut -f1 "$(state_path "$root" release identity)")" = pass ||
        fail "checked-out source is not contract revision $expected"
}

cmd_toolchain_revision() {
    test "$#" -eq 4 || fail 'usage: produce-candidate-v1.sh toolchain-revision CONTRACT OUTPUT_ROOT fdroiddata|fdroidserver REPOSITORY'
    local contract="$1" root="$2" component="$3" repo="$4" expected observed witness status field
    contract_check "$contract"
    prepare_root "$root"
    need git
    case "$component" in
        fdroiddata) field=3 ;;
        fdroidserver) field=4 ;;
        *) fail 'toolchain component must be fdroiddata or fdroidserver' ;;
    esac
    expected="$(toolchain_field "$contract" "$field")"
    observed="$(git -C "$repo" rev-parse HEAD 2>/dev/null || true)"
    require_clean_repo "$repo"
    witness="$root/witnesses/toolchain/$component.log"
    {
        printf 'component\t%s\n' "$component"
        printf 'expected_revision\t%s\n' "$expected"
        printf 'observed_revision\t%s\n' "$observed"
        git -C "$repo" status --porcelain=v1 --untracked-files=no 2>&1 || true
    } > "$witness"
    status=pass
    test "$observed" = "$expected" || status=fail
    set_state "$root" toolchain "$component" "$status" "$(relative_to_root "$root" "$witness")"
    test "$status" = pass || fail "$component revision does not match contract"
}

cmd_buildserver_image() {
    test "$#" -eq 3 || fail 'usage: produce-candidate-v1.sh buildserver-image CONTRACT OUTPUT_ROOT IMAGE@sha256:DIGEST'
    local contract="$1" root="$2" image="$3" expected witness tmp status
    contract_check "$contract"
    prepare_root "$root"
    need docker
    expected="$(toolchain_field "$contract" 5)"
    witness="$root/witnesses/toolchain/buildserver-image.log"
    tmp="$witness.tmp"
    {
        printf 'expected_image\t%s\n' "$expected"
        printf 'requested_image\t%s\n' "$image"
        docker image inspect --format '{{range .RepoDigests}}{{println .}}{{end}}' "$image"
    } > "$tmp" 2>&1 || {
        mv "$tmp" "$witness"
        set_state "$root" toolchain buildserver-image fail "$(relative_to_root "$root" "$witness")"
        fail 'docker could not inspect buildserver image'
    }
    status=pass
    test "$image" = "$expected" || status=fail
    grep -Fxq "$expected" "$tmp" || status=fail
    mv "$tmp" "$witness"
    set_state "$root" toolchain buildserver-image "$status" "$(relative_to_root "$root" "$witness")"
    test "$status" = pass || fail 'buildserver image is not the exact contract digest'
}

cmd_check() {
    test "$#" -ge 5 || fail 'usage: produce-candidate-v1.sh check CONTRACT OUTPUT_ROOT NAME -- COMMAND [ARG...]'
    local contract="$1" root="$2" name="$3" witness tmp status rc
    shift 3
    test "$1" = -- || fail 'check command requires -- before COMMAND'
    shift
    test "$#" -gt 0 || fail 'check command is empty'
    contract_check "$contract"
    candidate_check "$name" || fail "unknown candidate check: $name"
    manual_check "$name" && fail "$name requires manual-policy evidence"
    test "$name" != source-public || fail 'source-public is produced by the source stage'
    test "$name" != fastlane || fail 'fastlane requires the fastlane stage'
    test "$name" != apk-identity || fail 'apk-identity requires the apk-identity stage'
    prepare_root "$root"
    witness="$root/witnesses/checks/$name.log"
    tmp="$witness.tmp"
    printf 'working_directory\t%s\n' "$(pwd)" > "$tmp"
    quote_command "$@" >> "$tmp"
    if "$@" >> "$tmp" 2>&1; then
        rc=0
        status=pass
    else
        rc=$?
        status=fail
    fi
    printf 'exit_status\t%d\n' "$rc" >> "$tmp"
    mv "$tmp" "$witness"
    set_state "$root" check "$name" "$status" "$(relative_to_root "$root" "$witness")"
    test "$status" = pass || fail "$name command failed with exit status $rc"
}

cmd_fastlane() {
    test "$#" -ge 7 || fail 'usage: produce-candidate-v1.sh fastlane CONTRACT OUTPUT_ROOT PLAY_ROOT LEGACY_FASTLANE_ROOT -- COMMAND [ARG...]'
    local contract="$1" root="$2" play="$3" legacy="$4" witness json stderr status rc required
    shift 4
    test "$1" = -- || fail 'fastlane requires -- before checker command'
    shift
    test "$#" -gt 0 || fail 'fastlane checker command is empty'
    contract_check "$contract"
    prepare_root "$root"
    need jq
    witness="$root/witnesses/checks/fastlane.log"
    json="$root/witnesses/checks/fastlane.json.tmp"
    stderr="$root/witnesses/checks/fastlane.stderr.tmp"
    status=pass
    for required in \
        listings/en-US/title.txt \
        listings/en-US/short-description.txt \
        listings/en-US/full-description.txt \
        listings/en-US/graphics/icon/icon.png \
        release-notes/en-US/default.txt; do
        test -s "$play/$required" || status=fail
    done
    find "$play/listings/en-US/graphics/phone-screenshots" -maxdepth 1 -type f -name '*.png' -print -quit 2>/dev/null | grep -q . || status=fail
    test ! -e "$legacy" || status=fail
    if "$@" > "$json" 2> "$stderr"; then rc=0; else rc=$?; status=fail; fi
    jq -e 'type == "array" and all(.[]; ((.severity // "") != "critical" and (.severity // "") != "major"))' "$json" >/dev/null 2>&1 || status=fail
    {
        printf 'working_directory\t%s\n' "$(pwd)"
        printf 'play_root\t%s\n' "$play"
        printf 'legacy_fastlane_root\t%s\n' "$legacy"
        quote_command "$@"
        printf 'exit_status\t%d\n' "$rc"
        printf '%s\n' '--- checker-json ---'
        cat "$json" 2>/dev/null || true
        printf '\n%s\n' '--- checker-stderr ---'
        cat "$stderr" 2>/dev/null || true
    } > "$witness"
    rm -f "$json" "$stderr"
    set_state "$root" check fastlane "$status" "$(relative_to_root "$root" "$witness")"
    test "$status" = pass || fail 'fastlane/Triple-T evidence did not satisfy candidate policy'
}

cmd_manual_policy() {
    test "$#" -eq 4 || fail 'usage: produce-candidate-v1.sh manual-policy CONTRACT OUTPUT_ROOT NAME REVIEW_TSV'
    local contract="$1" root="$2" name="$3" review="$4" expected line kind observed_name observed_source decision reviewer reviewed_at detail witness status extra
    contract_check "$contract"
    manual_check "$name" || fail "$name is not a manual-policy check"
    prepare_root "$root"
    test -s "$review" || fail "manual review evidence is missing: $review"
    test "$(wc -l < "$review")" -eq 1 || fail "manual review evidence must be exactly one TSV row: $review"
    expected="$(release_field "$contract" 6)"
    IFS=$'\t' read -r kind observed_name observed_source decision reviewer reviewed_at detail extra < "$review" || true
    status=pass
    test "$kind" = manual-policy-v1 || status=fail
    test "$observed_name" = "$name" || status=fail
    test "$observed_source" = "$expected" || status=fail
    case "$decision" in pass|fail|not-verified) ;; *) status=fail ;; esac
    test -n "${reviewer:-}" && test -n "${reviewed_at:-}" && test -n "${detail:-}" || status=fail
    test -z "${extra:-}" || status=fail
    if test "$status" = pass; then status="$decision"; fi
    witness="$root/witnesses/manual/$name.tsv"
    cp -- "$review" "$witness"
    set_state "$root" check "$name" "$status" "$(relative_to_root "$root" "$witness")"
    test "$status" = pass || fail "$name manual review is not a source-bound pass"
}

cmd_artifact() {
    test "$#" -eq 4 || fail 'usage: produce-candidate-v1.sh artifact CONTRACT OUTPUT_ROOT ARTIFACT_NAME APK'
    local contract="$1" root="$2" name="$3" apk="$4" row expected_abis destination witness status actual_abis
    contract_check "$contract"
    prepare_root "$root"
    need unzip
    row="$(artifact_row "$contract" "$name")"
    expected_abis="$(printf '%s\n' "$row" | awk -F '\t' '{print $8}')"
    destination="$root/artifacts/$name.apk"
    status=pass
    if test -s "$apk" && unzip -tqq "$apk" >/dev/null 2>&1; then
        cp -- "$apk" "$destination"
        unzip -Z1 "$destination" | grep -Fxq AndroidManifest.xml || status=fail
        unzip -Z1 "$destination" | sed -n 's,^lib/\([^/][^/]*\)/.*$,\1,p' | sort -u | paste -sd, - > "$root/.producer/artifact/$name.abis"
        actual_abis="$(cat "$root/.producer/artifact/$name.abis")"
        # Contract ABI order is semantic, while ZIP listing order is not.
        if test "$expected_abis" = none; then
            test -z "$actual_abis" || status=fail
        else
            printf '%s\n' "$expected_abis" | tr ',' '\n' | sort -u > "$root/.producer/artifact/$name.expected-abis"
            printf '%s\n' "$actual_abis" | tr ',' '\n' | sort -u > "$root/.producer/artifact/$name.actual-abis"
            cmp -s "$root/.producer/artifact/$name.expected-abis" "$root/.producer/artifact/$name.actual-abis" || status=fail
        fi
        witness="$(relative_to_root "$root" "$destination")"
    else
        status=fail
        destination="$root/witnesses/checks/artifact-$name.log"
        printf 'artifact\t%s\nstatus\tfail\nsource\t%s\n' "$name" "$apk" > "$destination"
        witness="$(relative_to_root "$root" "$destination")"
    fi
    set_state "$root" artifact "$name" "$status" "$witness"
    test "$status" = pass || fail "$name APK did not match its declared ABI inventory"
}

cmd_apk_identity() {
    test "$#" -eq 5 || fail 'usage: produce-candidate-v1.sh apk-identity CONTRACT OUTPUT_ROOT ARTIFACT_NAME AAPT2 APK'
    local contract="$1" root="$2" name="$3" aapt2="$4" apk="$5" package version_name version_code witness badging status abis
    contract_check "$contract"
    prepare_root "$root"
    need unzip
    package="$(release_field "$contract" 3)"
    version_name="$(release_field "$contract" 4)"
    version_code="$(release_field "$contract" 5)"
    witness="$root/witnesses/checks/apk-identity.log"
    badging="$root/witnesses/checks/apk-identity.badging.tmp"
    status=pass
    if "$aapt2" dump badging "$apk" > "$badging" 2>&1; then :; else status=fail; fi
    grep -Fq "package: name='$package'" "$badging" || status=fail
    grep -Fq "versionCode='$version_code'" "$badging" || status=fail
    grep -Fq "versionName='$version_name'" "$badging" || status=fail
    abis="$(unzip -Z1 "$apk" 2>/dev/null | sed -n 's,^lib/\([^/][^/]*\)/.*$,\1,p' | sort -u | paste -sd, - || true)"
    {
        printf 'artifact\t%s\n' "$name"
        printf 'sha256\t%s\n' "$(sha_file "$apk" 2>/dev/null || printf '-')"
        printf 'abis\t%s\n' "$abis"
        printf '%s\n' '--- aapt2 dump badging ---'
        cat "$badging"
    } > "$witness"
    rm -f "$badging"
    set_state "$root" check apk-identity "$status" "$(relative_to_root "$root" "$witness")"
    test "$status" = pass || fail 'finished APK identity does not match release contract'
}

status_rank() {
    case "$1" in
        pass) printf '0\n' ;;
        not-verified) printf '1\n' ;;
        fail) printf '2\n' ;;
        *) printf '2\n' ;;
    esac
}

combined_toolchain() {
    local root="$1" witness="$root/witnesses/toolchain/buildserver.log" component row status=pass part part_status part_witness digest rank
    : > "$witness"
    for component in fdroiddata fdroidserver buildserver-image; do
        row="$(get_state "$root" toolchain "$component")"
        IFS=$'\t' read -r part_status part_witness part_digest <<< "$row"
        if test "$part_witness" != - && test -s "$root/$part_witness"; then
            digest="$(sha_file "$root/$part_witness")"
            if test "$part_digest" != "$digest"; then part_status=fail; fi
        else
            digest='-'
            part_status=not-verified
        fi
        if test "$(status_rank "$part_status")" -gt "$(status_rank "$status")"; then status="$part_status"; fi
        printf 'component\t%s\tstatus\t%s\twitness\t%s' "$component" "$part_status" "$part_witness" >> "$witness"
        if test "$digest" != -; then
            printf '\tsha256\t%s' "$digest" >> "$witness"
        fi
        printf '\n' >> "$witness"
    done
    printf '%s\t%s\n' "$status" "$(relative_to_root "$root" "$witness")"
}

row_for_state() {
    local root="$1" class="$2" name="$3" state status witness recorded_digest observed_digest
    state="$(get_state "$root" "$class" "$name")"
    IFS=$'\t' read -r status witness recorded_digest <<< "$state"
    if test "$witness" = - || ! test -s "$root/$witness"; then
        witness="$(write_missing_witness "$root" "$class-$name")"
        status=not-verified
        observed_digest="$(sha_file "$root/$witness")"
    else
        observed_digest="$(sha_file "$root/$witness")"
        if test "$recorded_digest" != "$observed_digest"; then status=fail; fi
    fi
    printf '%s\t%s\t%s\n' "$status" "$witness" "$observed_digest"
}

emit_row() {
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$@"
}

cmd_finish() {
    test "$#" -eq 3 || fail 'usage: produce-candidate-v1.sh finish CONTRACT OUTPUT_ROOT RECEIPT'
    local contract="$1" root="$2" receipt="$3" source package version_name version_code data server image signing release_state tool_state name state status witness digest row abis code left right left_state right_state left_digest right_digest repro
    contract_check "$contract"
    prepare_root "$root"
    need sha256sum
    source="$(release_field "$contract" 6)"
    package="$(release_field "$contract" 3)"
    version_name="$(release_field "$contract" 4)"
    version_code="$(release_field "$contract" 5)"
    data="$(toolchain_field "$contract" 3)"
    server="$(toolchain_field "$contract" 4)"
    image="$(toolchain_field "$contract" 5)"
    signing="$(one_contract_row "$contract" signing | awk -F '\t' '{print $2}')"
    mkdir -p "$(dirname "$receipt")"
    {
        printf '%b\n' "$header"
        release_state="$(row_for_state "$root" release identity)"
        IFS=$'\t' read -r status witness digest <<< "$release_state"
        emit_row release identity "$status" "$source" - - - "$package" "$version_name" "$version_code" - "$witness" "$digest"

        tool_state="$(combined_toolchain "$root")"
        IFS=$'\t' read -r status witness <<< "$tool_state"
        digest="$(sha_file "$root/$witness")"
        emit_row toolchain buildserver "$status" "$source" "$data" "$server" "$image" "$package" "$version_name" "$version_code" - "$witness" "$digest"

        for name in source-public license-review dependency-review tag-binding version-history \
            metadata-read metadata-schema metadata-rewrite metadata-lint update-check git-redirect \
            metadata-tools fastlane fdroid-build gradle-audit build-input-pinning source-scan \
            apk-scan apk-identity signing-policy install-launch; do
            state="$(row_for_state "$root" check "$name")"
            IFS=$'\t' read -r status witness digest <<< "$state"
            emit_row check "$name" "$status" "$source" "$data" "$server" "$image" "$package" "$version_name" "$version_code" - "$witness" "$digest"
        done
        if test "$signing" = upstream; then
            for name in upstream-reproducible signing-key; do
                state="$(row_for_state "$root" check "$name")"
                IFS=$'\t' read -r status witness digest <<< "$state"
                emit_row check "$name" "$status" "$source" "$data" "$server" "$image" "$package" "$version_name" "$version_code" - "$witness" "$digest"
            done
        fi

        while IFS=$'\t' read -r kind code name role art_package art_version art_code abis rest; do
            test "$kind" = artifact || continue
            state="$(row_for_state "$root" artifact "$name")"
            IFS=$'\t' read -r status witness digest <<< "$state"
            emit_row artifact "$name" "$status" "$source" "$data" "$server" "$image" "$art_package" "$art_version" "$art_code" "$abis" "$witness" "$digest"
        done < "$contract"
    } > "$receipt.tmp"
    mv "$receipt.tmp" "$receipt"

    # Reproducibility evidence is the pair of finished artifact hashes required by
    # each same_artifact contract row. Keep it inspectable but do not invent an
    # extra receipt row that the v1 verifier would reject.
    while IFS=$'\t' read -r kind code left right rest; do
        test "$kind" = same_artifact || continue
        left_state="$(row_for_state "$root" artifact "$left")"
        right_state="$(row_for_state "$root" artifact "$right")"
        IFS=$'\t' read -r _ _ left_digest <<< "$left_state"
        IFS=$'\t' read -r _ _ right_digest <<< "$right_state"
        repro="$root/witnesses/reproducibility/$left--$right.tsv"
        {
            printf 'left\t%s\t%s\n' "$left" "$left_digest"
            printf 'right\t%s\t%s\n' "$right" "$right_digest"
            if test "$left_digest" = "$right_digest"; then printf 'byte_identical\tpass\n'; else printf 'byte_identical\tfail\n'; fi
        } > "$repro"
    done < "$contract"
    printf '%s\n' "$receipt"
}

case "${1:-}" in
    init) shift; cmd_init "$@" ;;
    source) shift; cmd_source "$@" ;;
    toolchain-revision) shift; cmd_toolchain_revision "$@" ;;
    buildserver-image) shift; cmd_buildserver_image "$@" ;;
    check) shift; cmd_check "$@" ;;
    fastlane) shift; cmd_fastlane "$@" ;;
    manual-policy) shift; cmd_manual_policy "$@" ;;
    artifact) shift; cmd_artifact "$@" ;;
    apk-identity) shift; cmd_apk_identity "$@" ;;
    finish) shift; cmd_finish "$@" ;;
    *)
        cat >&2 <<'USAGE'
usage: produce-candidate-v1.sh COMMAND ...
commands: init source toolchain-revision buildserver-image check fastlane manual-policy artifact apk-identity finish
USAGE
        exit 2
        ;;
esac
