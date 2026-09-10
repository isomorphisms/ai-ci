#!/bin/sh
set -eu

case_name=${1-}
output=${2-}
if [ -z "$case_name" ] || [ -z "$output" ]; then
    echo "usage: $0 CASE OUTPUT" >&2
    exit 2
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM
seed="$work/seed"
remote="$work/remote.git"
preflight="$work/preflight"
acquire="$work/acquire"

export GIT_AUTHOR_NAME=ai-ci
export GIT_AUTHOR_EMAIL=ai-ci@example.invalid
export GIT_AUTHOR_DATE=2026-08-25T12:00:00Z
export GIT_COMMITTER_NAME=ai-ci
export GIT_COMMITTER_EMAIL=ai-ci@example.invalid
export GIT_COMMITTER_DATE=2026-08-25T12:00:00Z

git init -q -b main "$seed"
mkdir -p "$seed/s"
printf 'armv7 source payload\n' > "$seed/s/arm7.def"
git -C "$seed" add s/arm7.def
git -C "$seed" commit -q -m 'rename references but omit source file rename'
git -C "$seed" tag broken

git -C "$seed" mv s/arm7.def s/armv7.def
GIT_AUTHOR_DATE=2026-08-25T12:01:00Z \
GIT_COMMITTER_DATE=2026-08-25T12:01:00Z \
    git -C "$seed" commit -q -m 'complete source file rename'
git -C "$seed" tag verified

git clone -q --bare "$seed" "$remote"

mkdir -p "$(dirname "$output")"
printf 'event\tstatus\tsource\trevision\tcommand\n' > "$output"

init_fetch_repo() {
    repo=$1
    git init -q -b main "$repo"
    git -C "$repo" remote add origin "$remote"
}

fetch_ref() {
    repo=$1
    source=$2
    git -C "$repo" fetch -q --depth=1 origin "$source"
}

record_failed_preflight() {
    init_fetch_repo "$preflight"
    if fetch_ref "$preflight" 45b39d5 >/dev/null 2>&1; then
        status=pass
    else
        status=fail
    fi
    printf 'source-preflight\t%s\t45b39d5\t-\tgit fetch --depth=1 origin 45b39d5\n' "$status" >> "$output"
}

record_valid_preflight() {
    source=$1
    init_fetch_repo "$preflight"
    fetch_ref "$preflight" "$source"
    preflight_revision=$(git -C "$preflight" rev-parse FETCH_HEAD)
    printf 'source-preflight\tpass\t%s\t%s\tgit fetch --depth=1 origin %s\n' \
        "$source" "$preflight_revision" "$source" >> "$output"
}

record_compatibility_probe() {
    source=$1
    revision=$2
    if git -C "$preflight" cat-file -e FETCH_HEAD:s/armv7.def >/dev/null 2>&1; then
        status=pass
    else
        status=fail
    fi
    printf 'source-compatibility\t%s\t%s\t%s\tgit cat-file -e FETCH_HEAD:s/armv7.def\n' \
        "$status" "$source" "$revision" >> "$output"
}

case "$case_name" in
    bad-order)
        : > "$work/heavyweight-mutation"
        printf 'heavyweight-mutation\tpass\t-\t-\tpkg install clang make\n' >> "$output"
        record_failed_preflight
        ;;
    bad-source)
        record_failed_preflight
        ;;
    bad-no-compatibility)
        source=refs/tags/verified
        record_valid_preflight "$source"
        : > "$work/heavyweight-mutation"
        printf 'heavyweight-mutation\tpass\t-\t-\tpkg install clang make\n' >> "$output"
        ;;
    bad-tree)
        source=refs/tags/broken
        record_valid_preflight "$source"
        record_compatibility_probe "$source" "$preflight_revision"
        ;;
    good|bad-revision)
        source=refs/tags/verified
        record_valid_preflight "$source"
        record_compatibility_probe "$source" "$preflight_revision"

        : > "$work/heavyweight-mutation"
        printf 'heavyweight-mutation\tpass\t-\t-\tpkg install clang make\n' >> "$output"

        if [ "$case_name" = bad-revision ]; then
            printf 'changed source\n' >> "$seed/s/armv7.def"
            git -C "$seed" add s/armv7.def
            GIT_AUTHOR_DATE=2026-08-25T12:02:00Z \
            GIT_COMMITTER_DATE=2026-08-25T12:02:00Z \
                git -C "$seed" commit -q -m 'move controlled source'
            git -C "$seed" tag -f verified >/dev/null
            git -C "$seed" push -q --force "$remote" refs/tags/verified:refs/tags/verified
        fi

        init_fetch_repo "$acquire"
        fetch_ref "$acquire" "$source"
        acquired_revision=$(git -C "$acquire" rev-parse FETCH_HEAD)
        printf 'source-acquire\tpass\t%s\t%s\tgit fetch --depth=1 origin %s\n' \
            "$source" "$acquired_revision" "$source" >> "$output"
        printf 'build\tpass\t%s\t%s\tmake -C source\n' \
            "$source" "$acquired_revision" >> "$output"
        ;;
    *)
        echo "unknown build-preflight fixture: $case_name" >&2
        exit 2
        ;;
esac
