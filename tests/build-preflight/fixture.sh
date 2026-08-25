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
printf 'verified source\n' > "$seed/source.txt"
git -C "$seed" add source.txt
git -C "$seed" commit -q -m 'controlled source'
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

case "$case_name" in
    bad-order)
        : > "$work/heavyweight-mutation"
        printf 'heavyweight-mutation\tpass\t-\t-\tpkg install clang make\n' >> "$output"
        record_failed_preflight
        ;;
    bad-source)
        record_failed_preflight
        ;;
    good|bad-revision)
        init_fetch_repo "$preflight"
        fetch_ref "$preflight" refs/tags/verified
        preflight_revision=$(git -C "$preflight" rev-parse FETCH_HEAD)
        printf 'source-preflight\tpass\trefs/tags/verified\t%s\tgit fetch --depth=1 origin refs/tags/verified\n' "$preflight_revision" >> "$output"

        : > "$work/heavyweight-mutation"
        printf 'heavyweight-mutation\tpass\t-\t-\tpkg install clang make\n' >> "$output"

        if [ "$case_name" = bad-revision ]; then
            printf 'changed source\n' >> "$seed/source.txt"
            git -C "$seed" add source.txt
            GIT_AUTHOR_DATE=2026-08-25T12:01:00Z \
            GIT_COMMITTER_DATE=2026-08-25T12:01:00Z \
                git -C "$seed" commit -q -m 'move controlled source'
            git -C "$seed" tag -f verified >/dev/null
            git -C "$seed" push -q --force "$remote" refs/tags/verified:refs/tags/verified
        fi

        init_fetch_repo "$acquire"
        fetch_ref "$acquire" refs/tags/verified
        acquired_revision=$(git -C "$acquire" rev-parse FETCH_HEAD)
        printf 'source-acquire\tpass\trefs/tags/verified\t%s\tgit fetch --depth=1 origin refs/tags/verified\n' "$acquired_revision" >> "$output"
        printf 'build\tpass\trefs/tags/verified\t%s\tmake -C source\n' "$acquired_revision" >> "$output"
        ;;
    *)
        echo "unknown build-preflight fixture: $case_name" >&2
        exit 2
        ;;
esac
