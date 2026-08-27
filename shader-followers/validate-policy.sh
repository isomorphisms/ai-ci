#!/bin/sh
set -eu

policy=${1:-shader-followers/policy.tsv}
checkpoints=${2:-shader-followers/checkpoints.tsv}

awk -F '\t' '
NR == 1 {
  expected = "target\trepository\tref\trole\tmath_ir\tlanguage\tprecision\tresources\texecution\thost_boundary\tevidence\trule"
  if ($0 != expected) {
    print "bad shader follower-policy header" > "/dev/stderr"
    exit 1
  }
  next
}
NF != 12 {
  print "bad shader follower-policy field count on line " NR > "/dev/stderr"
  exit 1
}
{
  for (i = 1; i <= 12; i++) {
    if ($i == "") {
      print "empty shader follower-policy field on line " NR > "/dev/stderr"
      exit 1
    }
  }
}
seen[$1]++ {
  print "duplicate shader follower target: " $1 > "/dev/stderr"
  exit 1
}
$4 !~ /^(phone-reference|hardware-follower|language-peer)$/ {
  print "unknown shader follower role on line " NR ": " $4 > "/dev/stderr"
  exit 1
}
$5 !~ /^(reference|inherit|peer)$/ {
  print "unknown math/IR relation on line " NR ": " $5 > "/dev/stderr"
  exit 1
}
$6 !~ /^(local|adapt|canonical)$/ {
  print "unknown language policy on line " NR ": " $6 > "/dev/stderr"
  exit 1
}
$7 !~ /^(measure|remeasure|validate)$/ {
  print "unknown precision policy on line " NR ": " $7 > "/dev/stderr"
  exit 1
}
$8 !~ /^(local|adapt|canonical)$/ {
  print "unknown resource policy on line " NR ": " $8 > "/dev/stderr"
  exit 1
}
$9 !~ /^(local|adapt|semantic)$/ {
  print "unknown execution policy on line " NR ": " $9 > "/dev/stderr"
  exit 1
}
$10 !~ /^(local|boundary)$/ {
  print "unknown host-boundary policy on line " NR ": " $10 > "/dev/stderr"
  exit 1
}
$11 !~ /^(device-driver|compiler-bytecode|validator-oracle)$/ {
  print "unknown evidence policy on line " NR ": " $11 > "/dev/stderr"
  exit 1
}
$1 == "powervr-phone" { have_phone = 1 }
$1 == "switch-tegra-x1" { have_switch = 1 }
$1 == "webgpu-wgsl" { have_webgpu = 1 }
END {
  if (NR < 2) {
    print "shader follower policy has no targets" > "/dev/stderr"
    exit 1
  }
  if (!have_phone || !have_switch || !have_webgpu) {
    print "shader follower policy must include PowerVR/phone, Switch/Tegra X1, and WebGPU/WGSL" > "/dev/stderr"
    exit 1
  }
}
' "$policy"

awk -F '\t' '
NR == 1 {
  if ($0 != "target\tcheckpoint") {
    print "bad shader checkpoint header" > "/dev/stderr"
    exit 1
  }
  next
}
NF != 2 || $1 == "" || length($2) != 40 || $2 !~ /^[0-9a-f]+$/ {
  print "bad shader checkpoint on line " NR > "/dev/stderr"
  exit 1
}
seen[$1]++ {
  print "duplicate shader checkpoint target: " $1 > "/dev/stderr"
  exit 1
}
END {
  if (NR < 2) {
    print "shader checkpoint table has no targets" > "/dev/stderr"
    exit 1
  }
}
' "$checkpoints"

for target in $(awk -F '\t' 'NR > 1 { print $1 }' "$policy"); do
  count=$(awk -F '\t' -v target="$target" 'NR > 1 && $1 == target { n++ } END { print n + 0 }' "$checkpoints")
  if [ "$count" -ne 1 ]; then
    echo "shader target $target must have exactly one checkpoint" >&2
    exit 1
  fi
done

for target in $(awk -F '\t' 'NR > 1 { print $1 }' "$checkpoints"); do
  count=$(awk -F '\t' -v target="$target" 'NR > 1 && $1 == target { n++ } END { print n + 0 }' "$policy")
  if [ "$count" -ne 1 ]; then
    echo "shader checkpoint target $target has no policy row" >&2
    exit 1
  fi
done
