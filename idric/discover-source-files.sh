#!/bin/sh
set -eu

owners_file=${1:-idric/source-owners-v1.tsv}
output=${2:-idric/discovered-sources.tsv}
api=${GITHUB_API_URL:-https://api.github.com}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

[ -f "$owners_file" ] || die "source owner list not found: $owners_file"

expected_header=$(printf 'kind\towner')
actual_header=$(sed -n '1p' "$owners_file")
[ "$actual_header" = "$expected_header" ] ||
  die "invalid source owner list header"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

api_get() {
  url=$1
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    curl --fail --silent --show-error --location \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "$url"
  else
    curl --fail --silent --show-error --location \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "$url"
  fi
}

owners_rows="$tmp_dir/owners.tsv"
repos="$tmp_dir/repos.tsv"
discovered_rows="$tmp_dir/discovered.tsv"

sed '1d' "$owners_file" > "$owners_rows"
: > "$repos"
: > "$discovered_rows"

while IFS="$(printf '\t')" read -r kind owner; do
  [ -n "$kind" ] || continue
  [ -n "$owner" ] || die "source owner row has an empty owner"

  case "$kind" in
    user) base="$api/users/$owner/repos?type=owner&sort=full_name&per_page=100" ;;
    org)  base="$api/orgs/$owner/repos?type=all&sort=full_name&per_page=100" ;;
    *) die "unknown source owner kind: $kind" ;;
  esac

  page=1
  while :; do
    body="$tmp_dir/repos-$owner-$page.json"
    api_get "$base&page=$page" > "$body"

    jq -e 'type == "array"' "$body" >/dev/null ||
      die "repository listing was not an array for $owner page $page"

    count=$(jq 'length' "$body")
    [ "$count" -gt 0 ] || break

    jq -r '
      .[]
      | select(.size > 0)
      | [.full_name, .default_branch]
      | @tsv
    ' "$body" >> "$repos"

    [ "$count" -lt 100 ] && break
    page=$((page + 1))
  done
done < "$owners_rows"

LC_ALL=C sort -u "$repos" -o "$repos"

while IFS="$(printf '\t')" read -r repository ref; do
  [ -n "$repository" ] || continue
  [ -n "$ref" ] || die "repository has no default branch: $repository"

  encoded_ref=$(printf '%s' "$ref" | jq -sRr @uri)
  owner=$(printf '%s' "$repository" | cut -d/ -f1)
  name=$(printf '%s' "$repository" | cut -d/ -f2-)
  tree="$tmp_dir/tree-$(printf '%s' "$repository" | tr '/' '_').json"

  api_get "$api/repos/$owner/$name/git/trees/$encoded_ref?recursive=1" > "$tree"

  jq -e 'has("tree")' "$tree" >/dev/null ||
    die "tree response missing tree for $repository@$ref"
  if [ "$(jq -r '.truncated // false' "$tree")" = true ]; then
    die "recursive tree was truncated for $repository@$ref"
  fi

  jq -r --arg repository "$repository" --arg ref "$ref" '
    .tree[]
    | select(.type == "blob")
    | select(.path | endswith(".idric"))
    | [$repository, $ref, .path]
    | @tsv
  ' "$tree" >> "$discovered_rows"
done < "$repos"

{
  printf 'repository\tref\tpath\n'
  LC_ALL=C sort -t "$(printf '\t')" -k1,1 -k2,2 -k3,3 -u "$discovered_rows"
} > "$output"

printf 'discovered %s Idriç source files across %s repositories\n' \
  "$(( $(wc -l < "$output") - 1 ))" \
  "$(wc -l < "$repos")"
