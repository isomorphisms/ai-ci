#!/usr/bin/env bash
set -euxo pipefail

# Keep the historical Idris installation under /work so the workflow can cache
# it across runs without changing the pinned package universe.
export HOME=/work/.cache/iridium-2014-home
export PATH="$HOME/.cabal/bin:$PATH"
CACHE="$HOME/.cabal/packages/hackage.haskell.org"
mkdir -p "$HOME/.cabal" "$CACHE" artifacts

cat > "$HOME/.cabal/config" <<EOF
repository hackage.haskell.org
  url: https://hackage.haskell.org/
  secure: False
remote-repo-cache: $HOME/.cabal/packages
world-file: $HOME/.cabal/world
extra-prog-path: $HOME/.cabal/bin
remote-build-reporting: none
jobs: 2
EOF

# The workflow reconstructs a 00-index from the append-only modern 01-index,
# retaining only the effective .cabal revision that existed by 2014-10-16.
# Do not run `cabal update` here: that would replace the historical universe
# with today's package metadata.
cp hackage-2014/00-index.tar.gz "$CACHE/00-index.tar.gz"
gzip -dc "$CACHE/00-index.tar.gz" > "$CACHE/00-index.tar"

ghc --version | tee artifacts/ghc-version.txt
cabal --version | tee artifacts/cabal-version.txt
sha256sum "$CACHE/00-index.tar.gz" | tee artifacts/hackage-2014-index.sha256

if ! command -v idris >/dev/null 2>&1 || [ "$(idris --version 2>/dev/null || true)" != "0.9.14.3" ]; then
  cabal v1-install --user --jobs=2 idris-0.9.14.3
fi
idris --version | tee artifacts/idris-version.txt

TIMEFORMAT='%3R'
{ time idris -i upstream-iridium/src -p effects -o artifacts/iridium-core \
    benchmarks/iridium-2014/IridiumBench.idr; } \
  2> artifacts/compile-seconds.txt

artifacts/iridium-core > artifacts/result-1.txt
artifacts/iridium-core > artifacts/result-2.txt
cmp artifacts/result-1.txt artifacts/result-2.txt
sha256sum artifacts/result-1.txt > artifacts/result.sha256

TIMEFORMAT='wall=%3R user=%3U system=%3S'
{ time bash -c 'for i in 1 2 3; do artifacts/iridium-core >/dev/null; done'; } \
  2> artifacts/run-time-3x.txt

# The full upstream application crosses into 2014 macOS/Cocoa APIs.  Keep its
# code-generation result as separate evidence: failure here must not erase the
# already-valid portable ELF benchmark.
cd upstream-iridium
TIMEFORMAT='%3R'
set +e
{ time idris -S -i src -p effects \
    -o /work/artifacts/iridium-quartz-generated.c src/Quartz.idr \
    2> /work/artifacts/quartz-codegen-stderr.txt; } \
  2> /work/artifacts/quartz-codegen-seconds.txt
quartz_status=$?
set -e
printf '%s\n' "$quartz_status" > /work/artifacts/quartz-codegen-exit.txt
cd /work

chmod -R a+rwx artifacts
