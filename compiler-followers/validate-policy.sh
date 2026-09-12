#!/bin/sh
set -eu

policy=${1:-compiler-followers/policy.tsv}

awk -F '\t' '
NR == 1 {
  expected = "target\trepository\tref\tlayer\tstage\tmode\tisa_closeness\tdevice_closeness\tscope\trule"
  if ($0 != expected) {
    print "bad follower-policy header" > "/dev/stderr"
    exit 1
  }
  next
}
NF != 10 {
  print "bad follower-policy field count on line " NR > "/dev/stderr"
  exit 1
}
$1 == "" || $2 == "" || $3 == "" || $4 == "" || $5 == "" || $6 == "" || $7 == "" || $8 == "" || $9 == "" || $10 == "" {
  print "empty follower-policy field on line " NR > "/dev/stderr"
  exit 1
}
seen[$1]++ {
  print "duplicate follower target: " $1 > "/dev/stderr"
  exit 1
}
$4 !~ /^(cpu-codegen|virtual-codegen|architecture-catalog|platform-overlay|target-profile|shader-boundary|target-blocker)$/ {
  print "unknown follower layer on line " NR ": " $4 > "/dev/stderr"
  exit 1
}
$5 !~ /^(authority-active|implementation-draft|implementation-planned|inventory-only|platform-only|reference-only|blocked)$/ {
  print "unknown follower stage on line " NR ": " $5 > "/dev/stderr"
  exit 1
}
$6 !~ /^(authority|observe-close|close-arm|boring-native|device-overlay|semantic-virtual|inventory-observe|selective|observation-only|separate-track|blocked)$/ {
  print "unknown follower mode on line " NR ": " $6 > "/dev/stderr"
  exit 1
}
$7 !~ /^(exact|high|medium|low|none)$/ || $8 !~ /^(exact|high|medium|low|none)$/ {
  print "unknown closeness value on line " NR > "/dev/stderr"
  exit 1
}
$4 == "cpu-codegen" && $5 !~ /^(authority-active|implementation-draft|implementation-planned)$/ {
  print "CPU codegen row has non-codegen stage on line " NR > "/dev/stderr"
  exit 1
}
$4 == "virtual-codegen" && $5 !~ /^(implementation-draft|implementation-planned)$/ {
  print "virtual codegen row has non-codegen stage on line " NR > "/dev/stderr"
  exit 1
}
$4 == "architecture-catalog" && $5 !~ /^(inventory-only|reference-only)$/ {
  print "architecture catalog must remain inventory/reference-only on line " NR > "/dev/stderr"
  exit 1
}
$4 == "platform-overlay" && ($5 != "platform-only" || $6 != "device-overlay") {
  print "platform overlay must be platform-only/device-overlay on line " NR > "/dev/stderr"
  exit 1
}
$4 == "target-profile" && $5 != "reference-only" {
  print "target profile must remain reference-only on line " NR > "/dev/stderr"
  exit 1
}
$4 == "shader-boundary" && ($5 != "reference-only" || $6 != "separate-track") {
  print "shader boundary must remain reference-only/separate-track on line " NR > "/dev/stderr"
  exit 1
}
($4 == "target-blocker" || $5 == "blocked" || $6 == "blocked") && !($4 == "target-blocker" && $5 == "blocked" && $6 == "blocked") {
  print "blocked target must use target-blocker/blocked/blocked together on line " NR > "/dev/stderr"
  exit 1
}
$6 == "authority" {
  authority++
  if ($1 != "arm-thumb" || $4 != "cpu-codegen" || $5 != "authority-active") {
    print "invalid authority row on line " NR > "/dev/stderr"
    exit 1
  }
}
END {
  if (NR < 2) {
    print "follower policy has no targets" > "/dev/stderr"
    exit 1
  }
  if (authority != 1) {
    print "follower policy must contain exactly one authority" > "/dev/stderr"
    exit 1
  }
}
' "$policy"
