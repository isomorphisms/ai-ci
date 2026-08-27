#!/bin/sh
set -eu

policy=${1:-compiler-followers/policy.tsv}

awk -F '\t' '
NR == 1 {
  expected = "target\trepository\tref\tmode\tisa_closeness\tdevice_closeness\tscope\trule"
  if ($0 != expected) {
    print "bad follower-policy header" > "/dev/stderr"
    exit 1
  }
  next
}
NF != 8 {
  print "bad follower-policy field count on line " NR > "/dev/stderr"
  exit 1
}
$1 == "" || $2 == "" || $3 == "" || $4 == "" || $5 == "" || $6 == "" || $7 == "" || $8 == "" {
  print "empty follower-policy field on line " NR > "/dev/stderr"
  exit 1
}
seen[$1]++ {
  print "duplicate follower target: " $1 > "/dev/stderr"
  exit 1
}
$4 !~ /^(authority|observe-close|close-arm|boring-native|careful-heterogeneous|semantic-virtual|separate-track|iron-out|selective|observation-only)$/ {
  print "unknown follower mode on line " NR ": " $4 > "/dev/stderr"
  exit 1
}
$5 !~ /^(exact|high|medium|low|none)$/ || $6 !~ /^(exact|high|medium|low|none)$/ {
  print "unknown closeness value on line " NR > "/dev/stderr"
  exit 1
}
END {
  if (NR < 2) {
    print "follower policy has no targets" > "/dev/stderr"
    exit 1
  }
}
' "$policy"
