#!/bin/bash
set -euo pipefail

lock=${1:?Usage: install-repo-tool.sh SOURCE_LOCK}
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
url=$(python3 "$SCRIPT_DIR/lock-query.py" "$lock" resource repo_tool url)
commit=$(python3 "$SCRIPT_DIR/lock-query.py" "$lock" resource repo_tool commit)
temp_dir=$(mktemp -d)
trap 'rm -rf -- "$temp_dir"' EXIT

git clone --quiet --filter=blob:none --no-checkout "$url" "$temp_dir/repo-tool"
git -C "$temp_dir/repo-tool" fetch --quiet --depth=1 origin "$commit"
git -C "$temp_dir/repo-tool" checkout --quiet --detach "$commit"
install -d "$HOME/.local/bin"
install -m 0755 "$temp_dir/repo-tool/repo" "$HOME/.local/bin/repo"
