#!/usr/bin/env bash
set -euxo pipefail

# The pinned GHC/Cabal image runs as an unprivileged user but its baked
# /root/.cabal tree belongs to root. Keep this reconstruction self-contained.
export HOME=/tmp/iridium-2014-home
export PATH="$HOME/.cabal/bin:$PATH"
mkdir -p "$HOME/.cabal" artifacts

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

ghc --version | tee artifacts/ghc-version.txt
cabal --version | tee artifacts/cabal-version.txt
cabal v1-update

# With the old-style direct repository Cabal cannot honor index-state.  The
# exact Idris target remains pinned; unlimited backtracking is needed because
# the current Hackage index contains many newer dependency versions which do
# not support GHC 7.8/base-4.7.
cabal v1-install --user --jobs=2 --max-backjumps=-1 --reorder-goals idris-0.9.14.3
idris --version | tee artifacts/idris-version.txt

/usr/bin/time -f "%e" -o artifacts/compile-seconds.txt \
  idris -i upstream-iridium/src -p effects -o artifacts/iridium-core \
    benchmarks/iridium-2014/IridiumBench.idr

artifacts/iridium-core > artifacts/result-1.txt
artifacts/iridium-core > artifacts/result-2.txt
cmp artifacts/result-1.txt artifacts/result-2.txt
sha256sum artifacts/result-1.txt > artifacts/result.sha256

/usr/bin/time -f "wall=%e user=%U system=%S" -o artifacts/run-time-3x.txt \
  bash -c 'for i in 1 2 3; do artifacts/iridium-core >/dev/null; done'

cd upstream-iridium
/usr/bin/time -f "%e" -o /work/artifacts/quartz-codegen-seconds.txt \
  idris -S -i src -p effects -o /work/artifacts/iridium-quartz-generated.c src/Quartz.idr
cd /work

chmod -R a+rwx artifacts
