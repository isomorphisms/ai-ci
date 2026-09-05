#!/bin/sh
set -eu

mode=${1:-all}
catfood_repo=${CATFOOD_REPO:-https://github.com/isomorphisms/catfood.git}
catfood_ref=${CATFOOD_REF:-main}
catfood_checkout=${CATFOOD_CHECKOUT:-/tmp/catfood}
catfood_root=${CATFOOD_ROOT:-/opt}
catfood_prefix=${CATFOOD_PREFIX:-/usr/local}
catfood_cache=${CATFOOD_CACHE:-/var/cache/catfood}

case $mode in
    base|catfood|all) ;;
    *)
        printf 'usage: %s [base|catfood|all]\n' "$0" >&2
        exit 64
        ;;
esac

printf '%s\n' '=== Debian receipt ==='
cat /etc/os-release
uname -a
dpkg --print-architecture
id

if [ "$(id -u)" -ne 0 ]; then
    printf '%s\n' 'Hetzner Debian probe expects the fresh root-console path' >&2
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update

# Do not pin an OpenJDK major version here. Current Debian images expose the
# supported JDK through default-jdk-headless; this is the contract Catfood uses.
apt-cache show default-jdk-headless >/dev/null
apt-get install -y ca-certificates git default-jdk-headless

git --version
java -version
command -v java

if [ "$mode" = base ]; then
    printf '%s\n' 'PASS debian-base'
    exit 0
fi

rm -rf "$catfood_checkout"
git clone --depth 1 --branch "$catfood_ref" "$catfood_repo" "$catfood_checkout"

CATFOOD_ROOT=$catfood_root \
CATFOOD_PREFIX=$catfood_prefix \
CATFOOD_CACHE=$catfood_cache \
CATFOOD_DEPTH=${CATFOOD_DEPTH:-1} \
CATFOOD_NO_PROFILE=${CATFOOD_NO_PROFILE:-1} \
    sh "$catfood_checkout/provision.sh"

PATH=$catfood_prefix/bin:$catfood_root/bin:$PATH
export PATH

printf '%s\n' '=== Catfood command receipt ==='
command -v catfood-doctor
command -v java
java -version

test -x "$catfood_root/bin/catfood-doctor"
catfood-doctor

printf '%s\n' 'PASS debian-catfood'
