#!/bin/bash
set -euo pipefail

lock=${1:?Usage: sync-sources.sh SOURCE_LOCK DESTINATION rootfs|image|all}
destination=${2:?Usage: sync-sources.sh SOURCE_LOCK DESTINATION rootfs|image|all}
group=${3:?Usage: sync-sources.sh SOURCE_LOCK DESTINATION rootfs|image|all}
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
lock=$(realpath "$lock")

case "$group" in
	rootfs)
		paths=(friendlywrt configs device/common device/friendlyelec scripts scripts/sd-fuse toolchain)
		;;
	image)
		paths=(kernel u-boot rkbin configs device/common device/friendlyelec scripts scripts/sd-fuse toolchain)
		;;
	all)
		mapfile -t paths < <(python3 "$SCRIPT_DIR/lock-query.py" "$lock" projects | cut -f1)
		;;
	*)
		echo "Unknown source group: $group" >&2
		exit 1
		;;
esac

manifest_url=$(python3 "$SCRIPT_DIR/lock-query.py" "$lock" get manifest.url)
manifest_branch=$(python3 "$SCRIPT_DIR/lock-query.py" "$lock" get manifest.branch)
manifest_file=$(python3 "$SCRIPT_DIR/lock-query.py" "$lock" get manifest.file)
repo_tool_url=$(python3 "$SCRIPT_DIR/lock-query.py" "$lock" resource repo_tool url)

mkdir -p "$destination"
destination=$(realpath "$destination")
cd "$destination"
repo init --depth=1 -u "$manifest_url" -b "$manifest_branch" \
	-m "$manifest_file" --repo-url="$repo_tool_url" --no-clone-bundle
repo sync -c --no-clone-bundle -j"$(nproc)" "${paths[@]}"

while IFS=$'\t' read -r path url _ref commit; do
	current=$(git -C "$path" rev-parse HEAD)
	if [[ "$current" != "$commit" ]]; then
		git -C "$path" fetch --quiet --depth=1 "$url" "$commit"
		git -C "$path" checkout --quiet --detach "$commit"
	fi
	actual=$(git -C "$path" rev-parse HEAD)
	[[ "$actual" == "$commit" ]] || {
		echo "Commit verification failed for $path: $actual != $commit" >&2
		exit 1
	}
done < <(python3 "$SCRIPT_DIR/lock-query.py" "$lock" projects "${paths[@]}")
