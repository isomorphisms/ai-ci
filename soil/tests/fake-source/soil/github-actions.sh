#!/bin/sh
set -eu

test "${1:-}" = run-job
job=${2:-}
test -n "$job"

mkdir -p _tmp/soil/logs _soil-jobs
git rev-parse HEAD > _tmp/soil/commit-hash.txt
printf '%s\n' "$job" > _tmp/soil/job-name.txt
printf '0\t0.001000\tfixture-task\tsoil/fake-task.sh\trun\t-\n' > _tmp/soil/INDEX.tsv
printf 'fixture task passed\n' > _tmp/soil/logs/fixture-task.txt
printf '0 fixture-job-id\n' > "_soil-jobs/$job.status.txt"
