#!/bin/sh
set -eu

self_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$self_dir/lib.sh"

repositories=${RELEASE_SHELF_REPOSITORIES:?RELEASE_SHELF_REPOSITORIES is required}
dex_archive_repositories=${RELEASE_SHELF_DEX_ARCHIVE_REPOSITORIES:-}
output_root=${RELEASE_SHELF_OUTPUT_ROOT:?RELEASE_SHELF_OUTPUT_ROOT is required}
phone_dir=${RELEASE_SHELF_PHONE_DIR:-miro-a1}
tablet_dir=${RELEASE_SHELF_TABLET_DIR:-tab-p10-row}
dex_dir=${RELEASE_SHELF_DEX_DIR:-dex}

for command_name in curl jq unzip tar sha256sum od awk sort sed grep tr wc cp rm mkdir mktemp; do
    command -v "$command_name" >/dev/null 2>&1 || {
        printf '%s\n' "missing required command: $command_name" >&2
        exit 1
    }
done

[ -f "$repositories" ] || {
    printf '%s\n' "repository list not found: $repositories" >&2
    exit 1
}
if [ -n "$dex_archive_repositories" ] && [ ! -f "$dex_archive_repositories" ]; then
    printf '%s\n' "DEX archive repository list not found: $dex_archive_repositories" >&2
    exit 1
fi

tmp_root=$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/aici-release-shelf.XXXXXX")
cleanup() {
    rm -rf "$tmp_root"
}
trap cleanup 0 1 2 15

normalized_repositories="$tmp_root/repositories"
normalized_dex_repositories="$tmp_root/dex-repositories"

awk '
    /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
    {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
        print $0
    }
' "$repositories" | sort -u > "$normalized_repositories"

if [ -n "$dex_archive_repositories" ]; then
    awk '
        /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
        {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
            print $0
        }
    ' "$dex_archive_repositories" | sort -u > "$normalized_dex_repositories"
else
    : > "$normalized_dex_repositories"
fi

validate_repository_list() {
    list=$1
    while IFS= read -r repository; do
        case "$repository" in
            */*) ;;
            *)
                printf '%s\n' "invalid GitHub repository name: $repository" >&2
                return 1
                ;;
        esac
        case "$repository" in
            *[!A-Za-z0-9_.+-/]*)
                printf '%s\n' "invalid characters in GitHub repository name: $repository" >&2
                return 1
                ;;
        esac
    done < "$list"
}
validate_repository_list "$normalized_repositories"
validate_repository_list "$normalized_dex_repositories"

github_api_get() {
    url=$1
    output=$2
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        curl -LfsS             -A 'ai-ci-release-shelf/1'             -H 'Accept: application/vnd.github+json'             -H "Authorization: Bearer $GITHUB_TOKEN"             "$url" -o "$output"
    else
        curl -LfsS             -A 'ai-ci-release-shelf/1'             -H 'Accept: application/vnd.github+json'             "$url" -o "$output"
    fi
}

download_public_asset() {
    url=$1
    output=$2
    curl -LfsS -A 'ai-ci-release-shelf/1' "$url" -o "$output"
}

remove_old_apk_release_files() {
    existing_dir=$1
    stage_dir=$2
    manifest="$existing_dir/manifest.tsv"
    [ -f "$manifest" ] || return 0

    header=$(sed -n '1p' "$manifest")
    tab=$(printf '\t')
    case "$header" in
        *"$tab"shelf_file"$tab"*)
            tail -n +2 "$manifest" |
                while IFS="$tab" read -r repository release_tag asset shelf_file rest; do
                    [ -n "$shelf_file" ] || continue
                    rm -f "$stage_dir/$shelf_file"
                done
            ;;
        *)
            tail -n +2 "$manifest" |
                while IFS="$tab" read -r repository release_tag asset rest; do
                    [ -n "$repository" ] || continue
                    flat_repo=$(release_shelf_safe_name "$repository")
                    rm -f "$stage_dir/$flat_repo--$asset"
                done
            ;;
    esac
}

remove_old_dex_release_files() {
    existing_dir=$1
    stage_dir=$2
    manifest="$existing_dir/manifest.tsv"
    [ -f "$manifest" ] || return 0

    tab=$(printf '\t')
    tail -n +2 "$manifest" |
        while IFS="$tab" read -r repository release_tag asset member shelf_file rest; do
            [ -n "$shelf_file" ] || continue
            rm -f "$stage_dir/$shelf_file"
        done
}

prepare_stage() {
    relative_dir=$1
    kind=$2
    stage="$tmp_root/stage/$relative_dir"
    existing="$output_root/$relative_dir"

    mkdir -p "$stage"
    if [ -d "$existing" ]; then
        cp -R "$existing/." "$stage/"
    fi

    case "$kind" in
        apk) remove_old_apk_release_files "$existing" "$stage" ;;
        dex) remove_old_dex_release_files "$existing" "$stage" ;;
    esac
    rm -f "$stage/manifest.tsv"
}

prepare_stage "$phone_dir" apk
prepare_stage "$tablet_dir" apk
prepare_stage "$dex_dir" dex

phone_stage="$tmp_root/stage/$phone_dir"
tablet_stage="$tmp_root/stage/$tablet_dir"
dex_stage="$tmp_root/stage/$dex_dir"

phone_manifest="$phone_stage/manifest.tsv"
tablet_manifest="$tablet_stage/manifest.tsv"
dex_manifest="$dex_stage/manifest.tsv"

printf 'repository\trelease_tag\tasset\tshelf_file\tsha256\tbytes\tnative_abis\turl\n' > "$phone_manifest"
printf 'repository\trelease_tag\tasset\tshelf_file\tsha256\tbytes\tnative_abis\turl\n' > "$tablet_manifest"
printf 'repository\trelease_tag\tasset\tmember\tshelf_file\tsha256\tbytes\turl\n' > "$dex_manifest"

phone_count=0
tablet_count=0
dex_count=0
failed=0

append_dex_file() {
    repository=$1
    release_tag=$2
    asset=$3
    member=$4
    source_file=$5
    source_url=$6

    if ! release_shelf_is_dex "$source_file"; then
        printf '%s\n' "invalid DEX magic: $repository $release_tag $asset $member" >&2
        failed=1
        return
    fi

    flat_repo=$(release_shelf_safe_name "$repository")
    safe_tag=$(release_shelf_safe_name "$release_tag")
    safe_asset=$(release_shelf_safe_name "$asset")
    if [ "$member" = "-" ]; then
        member_base=$safe_asset
    else
        member_base=$(basename "$member")
        member_base=$(release_shelf_safe_name "$member_base")
    fi
    shelf_file="$flat_repo--$safe_tag--$safe_asset--$member_base"
    case "$shelf_file" in
        *.dex) ;;
        *) shelf_file="$shelf_file.dex" ;;
    esac

    cp "$source_file" "$dex_stage/$shelf_file"
    sha256=$(sha256sum "$source_file" | awk '{print $1}')
    bytes=$(wc -c < "$source_file" | tr -d ' ')
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n'         "$repository" "$release_tag" "$asset" "$member" "$shelf_file" "$sha256" "$bytes" "$source_url"         >> "$dex_manifest"
    dex_count=$((dex_count + 1))
}

while IFS= read -r repository; do
    [ -n "$repository" ] || continue
    repo_key=$(release_shelf_safe_name "$repository")
    releases_json="$tmp_root/$repo_key.releases.json"

    if ! github_api_get "https://api.github.com/repos/$repository/releases?per_page=100" "$releases_json"; then
        printf '%s\n' "failed to query releases: $repository" >&2
        failed=1
        continue
    fi
    if ! jq -e 'type == "array"' "$releases_json" >/dev/null 2>&1; then
        printf '%s\n' "release API did not return an array: $repository" >&2
        failed=1
        continue
    fi

    apk_assets="$tmp_root/$repo_key.apk.tsv"
    if ! jq -r '
        [
          .[]
          | select(
              [ .assets[]? | (.name // "" | ascii_downcase | endswith(".apk")) ]
              | any
            )
        ][0] as $release
        | if $release == null then
            empty
          else
            $release.assets[]
            | select(.name // "" | ascii_downcase | endswith(".apk"))
            | [$release.tag_name, .name, .browser_download_url]
            | @tsv
          end
    ' "$releases_json" > "$apk_assets"; then
        printf '%s\n' "failed to parse APK releases: $repository" >&2
        failed=1
        continue
    fi

    tab=$(printf '\t')
    while IFS="$tab" read -r release_tag asset asset_url; do
        [ -n "$asset" ] || continue
        safe_asset=$(release_shelf_safe_name "$asset")
        downloaded="$tmp_root/$repo_key--$safe_asset"

        if ! download_public_asset "$asset_url" "$downloaded"; then
            printf '%s\n' "failed to download APK: $repository $release_tag $asset" >&2
            failed=1
            continue
        fi
        if ! native_abis=$(release_shelf_apk_abis "$downloaded"); then
            printf '%s\n' "release asset is not a readable APK ZIP: $repository $release_tag $asset" >&2
            failed=1
            continue
        fi

        shelf_file="$repo_key--$safe_asset"
        sha256=$(sha256sum "$downloaded" | awk '{print $1}')
        bytes=$(wc -c < "$downloaded" | tr -d ' ')

        phone=no
        tablet=no
        if [ "$native_abis" = "-" ]; then
            phone=yes
            tablet=yes
        else
            case ",$native_abis," in
                *,armeabi-v7a,*) phone=yes ;;
            esac
            case ",$native_abis," in
                *,arm64-v8a,*) tablet=yes ;;
            esac
        fi

        if [ "$phone" = yes ]; then
            cp "$downloaded" "$phone_stage/$shelf_file"
            printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n'                 "$repository" "$release_tag" "$asset" "$shelf_file" "$sha256" "$bytes" "$native_abis" "$asset_url"                 >> "$phone_manifest"
            phone_count=$((phone_count + 1))
        fi
        if [ "$tablet" = yes ]; then
            cp "$downloaded" "$tablet_stage/$shelf_file"
            printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n'                 "$repository" "$release_tag" "$asset" "$shelf_file" "$sha256" "$bytes" "$native_abis" "$asset_url"                 >> "$tablet_manifest"
            tablet_count=$((tablet_count + 1))
        fi
    done < "$apk_assets"

    dex_assets="$tmp_root/$repo_key.dex.tsv"
    if ! jq -r '
        [
          .[]
          | select(
              [ .assets[]? | (.name // "" | ascii_downcase | endswith(".dex")) ]
              | any
            )
        ][0] as $release
        | if $release == null then
            empty
          else
            $release.assets[]
            | select(.name // "" | ascii_downcase | endswith(".dex"))
            | [$release.tag_name, .name, .browser_download_url]
            | @tsv
          end
    ' "$releases_json" > "$dex_assets"; then
        printf '%s\n' "failed to parse DEX releases: $repository" >&2
        failed=1
        continue
    fi

    while IFS="$tab" read -r release_tag asset asset_url; do
        [ -n "$asset" ] || continue
        safe_asset=$(release_shelf_safe_name "$asset")
        downloaded="$tmp_root/$repo_key--direct--$safe_asset"
        if ! download_public_asset "$asset_url" "$downloaded"; then
            printf '%s\n' "failed to download DEX: $repository $release_tag $asset" >&2
            failed=1
            continue
        fi
        append_dex_file "$repository" "$release_tag" "$asset" "-" "$downloaded" "$asset_url"
    done < "$dex_assets"

    if grep -Fqx "$repository" "$normalized_dex_repositories"; then
        archives="$tmp_root/$repo_key.archives.tsv"
        if ! jq -r '
            .[]
            | .tag_name as $tag
            | .assets[]?
            | select(
                (.name // "" | ascii_downcase) as $name
                | ($name | endswith(".zip"))
                  or ($name | endswith(".tar.gz"))
                  or ($name | endswith(".tgz"))
              )
            | [$tag, .name, .browser_download_url]
            | @tsv
        ' "$releases_json" > "$archives"; then
            printf '%s\n' "failed to parse DEX archive releases: $repository" >&2
            failed=1
            continue
        fi

        selected_tag=
        while IFS="$tab" read -r release_tag asset asset_url; do
            [ -n "$asset" ] || continue
            if [ -n "$selected_tag" ] && [ "$release_tag" != "$selected_tag" ]; then
                break
            fi

            safe_asset=$(release_shelf_safe_name "$asset")
            archive="$tmp_root/$repo_key--archive--$safe_asset"
            if ! download_public_asset "$asset_url" "$archive"; then
                printf '%s\n' "failed to download DEX archive: $repository $release_tag $asset" >&2
                failed=1
                continue
            fi

            members="$tmp_root/$repo_key--members"
            if ! release_shelf_list_dex_members "$archive" > "$members"; then
                printf '%s\n' "failed to inspect DEX archive: $repository $release_tag $asset" >&2
                failed=1
                continue
            fi
            [ -s "$members" ] || continue

            if [ -z "$selected_tag" ]; then
                selected_tag=$release_tag
            fi
            while IFS= read -r member; do
                [ -n "$member" ] || continue
                extracted="$tmp_root/$repo_key--extracted.dex"
                if ! release_shelf_extract_dex_member "$archive" "$member" "$extracted"; then
                    printf '%s\n' "invalid embedded DEX: $repository $release_tag $asset $member" >&2
                    failed=1
                    continue
                fi
                append_dex_file "$repository" "$release_tag" "$asset" "$member" "$extracted" "$asset_url"
            done < "$members"
        done < "$archives"
    fi
done < "$normalized_repositories"

if [ "$failed" -ne 0 ]; then
    printf '%s\n' 'release shelf collection failed; consumer shelves were left unchanged' >&2
    exit 1
fi

replace_stage() {
    relative_dir=$1
    stage="$tmp_root/stage/$relative_dir"
    destination="$output_root/$relative_dir"
    parent=$(dirname "$destination")
    mkdir -p "$parent"
    rm -rf "$destination"
    mkdir -p "$destination"
    cp -R "$stage/." "$destination/"
}

replace_stage "$phone_dir"
replace_stage "$tablet_dir"
replace_stage "$dex_dir"

printf '%s\n' "phone_apks=$phone_count"
printf '%s\n' "tablet_apks=$tablet_count"
printf '%s\n' "dex_files=$dex_count"
