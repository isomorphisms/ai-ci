#!/bin/sh
set -eu

[ "$#" -eq 3 ] || {
    echo 'usage: merge/collect-authority.sh CLASSIFICATION STATE OUTPUT' >&2
    exit 2
}

classification_file=$1
state_file=$2
output=$3

for file in "$classification_file" "$state_file"; do
    test -f "$file" || {
        printf 'authority collector: missing file: %s\n' "$file" >&2
        exit 1
    }
done

read_value() {
    file=$1
    key=$2
    awk -F '\t' -v wanted="$key" '
        $1==wanted {
            if (found++) exit 2
            value=$2
        }
        END {
            if (found!=1) exit 1
            print value
        }
    ' "$file"
}

require_value() {
    value=$(read_value "$1" "$2") || {
        printf 'authority collector: missing or duplicate %s in %s\n' "$2" "$1" >&2
        exit 1
    }
    printf '%s\n' "$value"
}

schema=$(require_value "$classification_file" schema)
[ "$schema" = cockswain-merge-authority-v1 ] || {
    echo 'authority collector: unsupported classification schema' >&2
    exit 1
}

state_schema=$(require_value "$state_file" schema)
[ "$state_schema" = aici-merge-state-v4 ] || {
    echo 'authority collector: unsupported merge-state schema' >&2
    exit 1
}

repository=$(require_value "$state_file" repository)
pr=$(require_value "$state_file" pr)
title=$(require_value "$state_file" title)
head_sha=$(require_value "$state_file" head_sha)
base_ref=$(require_value "$state_file" live_base_ref)
base_sha=$(require_value "$state_file" live_base_sha)
diff_sha=$(require_value "$state_file" prospective_diff_sha256)
paths_sha=$(require_value "$state_file" changed_paths_sha256)
intent_sha=$(require_value "$state_file" intent_sha256)
current_scope_sha=$(require_value "$state_file" current_scope_sha256)

classification=$(require_value "$classification_file" classification)
authorization_kind=$(require_value "$classification_file" authorization_kind)
authorized_by=$(require_value "$classification_file" authorized_by)
actor_kind=$(require_value "$classification_file" authority_actor_kind)
source_kind=$(require_value "$classification_file" authority_source_kind)
source_id=$(require_value "$classification_file" authority_source_id)
source_role=$(require_value "$classification_file" authority_source_role)
text_sha=$(require_value "$classification_file" authority_text_sha256)
context_ref=$(require_value "$classification_file" authority_context_ref)
context_sha=$(require_value "$classification_file" authority_context_sha256)
context_state=$(require_value "$classification_file" authority_context_state)
classifier_repository=$(require_value "$classification_file" classifier_repository)
classifier_revision=$(require_value "$classification_file" classifier_revision)
classifier_contract_sha=$(require_value "$classification_file" classifier_contract_sha256)
authorized_repository=$(require_value "$classification_file" authorized_repository)
authorized_pr=$(require_value "$classification_file" authorized_pr)
authorized_title=$(require_value "$classification_file" authorized_title)
authorized_scope_sha=$(require_value "$classification_file" authorized_scope_sha256)
revocation_state=$(require_value "$classification_file" revocation_state)
objections=$(require_value "$classification_file" unresolved_objections)

case $classification in
    AUTHORIZED|NOT_AUTHORIZED|UNKNOWN) ;;
    *) echo 'authority collector: invalid classification' >&2; exit 1 ;;
esac

scope_state=same
if [ "$authorized_repository" != "$repository" ] ||
   [ "$authorized_pr" != "$pr" ] ||
   [ "$authorized_title" != "$title" ] ||
   [ "$authorized_scope_sha" != "$current_scope_sha" ]; then
    scope_state=changed
fi

decision=UNKNOWN
if [ "$classification" = AUTHORIZED ] &&
   [ "$context_state" = recovered ] &&
   [ "$scope_state" = same ] &&
   [ "$revocation_state" = none ] &&
   [ "$objections" = none ]; then
    decision=MERGE
fi

cat > "$output" <<EOF
schema	aici-merge-approval-v3
repository	$repository
pr	$pr
title	$title
head_sha	$head_sha
base_ref	$base_ref
base_sha	$base_sha
prospective_diff_sha256	$diff_sha
changed_paths_sha256	$paths_sha
intent_sha256	$intent_sha
decision	$decision
authorization_kind	$authorization_kind
authorization_text_sha256	$text_sha
authorized_by	$authorized_by
authority_actor_kind	$actor_kind
authority_source_kind	$source_kind
authority_source_id	$source_id
authority_source_role	$source_role
authority_context_ref	$context_ref
authority_context_sha256	$context_sha
authority_context_state	$context_state
authority_classifier_repository	$classifier_repository
authority_classifier_revision	$classifier_revision
authority_classifier_contract_sha256	$classifier_contract_sha
authority_scope_sha256	$authorized_scope_sha
authority_scope_state	$scope_state
revocation_state	$revocation_state
unresolved_objections	$objections
EOF
