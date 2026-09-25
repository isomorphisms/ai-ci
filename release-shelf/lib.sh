#!/bin/sh

release_shelf_safe_name() {
    printf '%s' "$1" | sed 's/[^A-Za-z0-9._+-]/-/g'
}

release_shelf_apk_abis() {
    apk=$1
    unzip -tq "$apk" >/dev/null 2>&1 || return 1
    unzip -Z1 "$apk" |
        awk -F/ '$1 == "lib" && NF >= 3 { print $2 }' |
        sort -u |
        awk 'BEGIN { first=1 }
             {
                 if (!first) printf ",";
                 printf "%s", $0;
                 first=0
             }
             END {
                 if (first) printf "-"
             }'
}

release_shelf_is_dex() {
    file=$1
    magic=$(
        od -An -tx1 -N4 "$file" 2>/dev/null |
            tr -d ' \n'
    )
    [ "$magic" = "6465780a" ]
}

release_shelf_list_dex_members() {
    archive=$1
    case "$archive" in
        *.zip)
            unzip -Z1 "$archive" |
                awk 'tolower($0) ~ /\.dex$/ { print }'
            ;;
        *.tar.gz|*.tgz)
            tar -tzf "$archive" |
                awk 'tolower($0) ~ /\.dex$/ { print }'
            ;;
        *)
            return 2
            ;;
    esac
}

release_shelf_extract_dex_member() {
    archive=$1
    member=$2
    output=$3
    case "$archive" in
        *.zip)
            unzip -p "$archive" "$member" > "$output"
            ;;
        *.tar.gz|*.tgz)
            tar -xOzf "$archive" "$member" > "$output"
            ;;
        *)
            return 2
            ;;
    esac
    release_shelf_is_dex "$output"
}
