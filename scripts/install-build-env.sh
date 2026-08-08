#!/bin/bash
set -euo pipefail

lock=${1:?Usage: install-build-env.sh SOURCE_LOCK}
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
url=$(python3 "$SCRIPT_DIR/lock-query.py" "$lock" resource build_env url)
commit=$(python3 "$SCRIPT_DIR/lock-query.py" "$lock" resource build_env commit)
temp_dir=$(mktemp -d)
trap 'rm -rf -- "$temp_dir"' EXIT

git clone --quiet --filter=blob:none --no-checkout "$url" "$temp_dir/build-env"
git -C "$temp_dir/build-env" fetch --quiet --depth=1 origin "$commit"
git -C "$temp_dir/build-env" checkout --quiet --detach "$commit"

installer="$temp_dir/build-env/install.sh"
sed -i -e 's/^apt-get -y install openjdk-8-jdk/# apt-get -y install openjdk-8-jdk/' "$installer"
sed -i -e 's/^\[ -d fa-toolchain \]/# [ -d fa-toolchain ]/' "$installer"
sed -i -e 's/^(cat fa-toolchain/# (cat fa-toolchain/' "$installer"
sed -i -e 's/^(tar xf fa-toolchain/# (tar xf fa-toolchain/' "$installer"

DEBIAN_FRONTEND=noninteractive sudo -E bash "$installer"
