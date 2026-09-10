#!/usr/bin/env bash
set -euxo pipefail

# Keep the historical Idris installation under /work so the workflow can cache
# it across runs without changing the pinned package universe.
export HOME=/work/.cache/iridium-2014-home
export PATH="$HOME/.cabal/bin:$PATH"
CACHE="$HOME/.cabal/packages/hackage.haskell.org"
mkdir -p "$HOME/.cabal" "$CACHE" artifacts

cat > "$HOME/.cabal/config" <<EOF2
repository hackage.haskell.org
  url: https://hackage.haskell.org/
  secure: False
remote-repo-cache: $HOME/.cabal/packages
world-file: $HOME/.cabal/world
extra-prog-path: $HOME/.cabal/bin
remote-build-reporting: none
jobs: 2
EOF2

# The workflow reconstructs a 00-index from the append-only modern 01-index,
# retaining only metadata that existed by 2014-10-16. Do not run `cabal update`
# here: that would replace the historical universe with today's metadata.
cp hackage-2014/00-index.tar.gz "$CACHE/00-index.tar.gz"
gzip -dc "$CACHE/00-index.tar.gz" > "$CACHE/00-index.tar"

git -C upstream-iridium rev-parse HEAD | tee artifacts/source-commit.txt
uname -a | tee artifacts/uname.txt
uname -m | tee artifacts/host-arch.txt
cat /etc/os-release > artifacts/container-os-release.txt
ghc --version | tee artifacts/ghc-version.txt
cabal --version | tee artifacts/cabal-version.txt
cc --version > artifacts/c-compiler-version.txt 2>&1
ld --version > artifacts/linker-version.txt 2>&1
sha256sum "$CACHE/00-index.tar.gz" | tee artifacts/hackage-2014-index.sha256

if ! command -v idris >/dev/null 2>&1 || [ "$(idris --version 2>/dev/null || true)" != "0.9.14.3" ]; then
  cabal v1-install --user --jobs=2 idris-0.9.14.3
fi
idris --version | tee artifacts/idris-version.txt
ghc-pkg list --simple-output | tr ' ' '\n' | sort > artifacts/ghc-package-db.txt

printf '%s\n' \
  'idris -i upstream-iridium/src -p effects -o artifacts/iridium-core benchmarks/iridium-2014/IridiumBench.idr' \
  > artifacts/compile-command.txt
TIMEFORMAT='%3R'
set +x
{ time idris -i upstream-iridium/src -p effects -o artifacts/iridium-core \
    benchmarks/iridium-2014/IridiumBench.idr; } \
  2> artifacts/compile-seconds.txt
set -x

artifacts/iridium-core > artifacts/result-1.txt
artifacts/iridium-core > artifacts/result-2.txt
cp benchmarks/iridium-2014/expected-output.txt artifacts/expected-output.txt
cmp artifacts/expected-output.txt artifacts/result-1.txt
cmp artifacts/result-1.txt artifacts/result-2.txt
sha256sum artifacts/result-1.txt > artifacts/result.sha256

# This timing is deliberately whole-process, including process startup. It is
# useful historical evidence, but it is not yet a cross-backend speed claim.
printf '%s\n' \
  "three separate executions of artifacts/iridium-core; each performs 200000 focus/swap steps" \
  > artifacts/run-command.txt
TIMEFORMAT='wall=%3R user=%3U system=%3S'
set +x
{ time bash -c 'for i in 1 2 3; do artifacts/iridium-core >/dev/null; done'; } \
  2> artifacts/run-time-3x.txt
set -x

# Resolve the dynamic dependency surface in the exact pinned environment that
# executes the benchmark. Host-runner ldd output would describe Ubuntu 24.04
# libraries instead of the runtime files actually used for these measurements.
ldd --version > artifacts/runtime-ldd-version.txt 2>&1 || true
ldd artifacts/iridium-core | tee artifacts/runtime-ldd.txt
: > artifacts/runtime-library-files.txt
runtime_library_total=0
while read -r library; do
  resolved="$(readlink -f "$library")"
  bytes="$(stat --printf='%s' "$resolved")"
  digest="$(sha256sum "$resolved" | awk '{print $1}')"
  printf '%s\t%s\t%s\n' "$bytes" "$digest" "$resolved" \
    >> artifacts/runtime-library-files.txt
  runtime_library_total=$((runtime_library_total + bytes))
done < <(awk '$2 == "=>" && $3 ~ /^\// {print $3} $1 ~ /^\// {print $1}' \
  artifacts/runtime-ldd.txt | sort -u)
printf '%s\n' "$runtime_library_total" \
  > artifacts/runtime-library-file-bytes.txt

# Quartz.idr contains %link directives for src/quartz.o and src/ir.o. The
# original macOS package build created those objects before compiling Quartz.
# Linux cannot build the Cocoa object, but -S only needs the declared link paths
# to exist while it emits generated C. Supply valid throwaway ELF objects here;
# the macOS job rebuilds the real C/Objective-C objects and never links these.
printf 'int iridium_quartz_codegen_placeholder;\n' \
  | cc -x c -c -o upstream-iridium/src/quartz.o -
printf 'int iridium_ir_codegen_placeholder;\n' \
  | cc -x c -c -o upstream-iridium/src/ir.o -
printf '%s\n' \
  'src/quartz.o and src/ir.o are code-generation-only placeholders; never linked into Mach-O' \
  > artifacts/quartz-codegen-boundary.txt

# Keep the full upstream application's code-generation result as separate
# evidence. Failure here must not erase the already-valid portable ELF fixture.
cd upstream-iridium
TIMEFORMAT='%3R'
set +e
set +x
{ time idris -S -i src -p effects \
    -o /work/artifacts/iridium-quartz-generated.c src/Quartz.idr \
    2> /work/artifacts/quartz-codegen-stderr.txt; } \
  2> /work/artifacts/quartz-codegen-seconds.txt
quartz_status=$?
set -x
set -e
printf '%s\n' "$quartz_status" > /work/artifacts/quartz-codegen-exit.txt
cd /work

chmod -R a+rwx artifacts
