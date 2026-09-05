#!/bin/bash
set -euo pipefail

lock=${1:?Usage: build-image.sh SOURCE_LOCK PROJECT ROOTFS_ARCHIVE HOST_PM_ARCHIVE ARTIFACT_DIR}
project=${2:?Usage: build-image.sh SOURCE_LOCK PROJECT ROOTFS_ARCHIVE HOST_PM_ARCHIVE ARTIFACT_DIR}
rootfs_archive=${3:?Usage: build-image.sh SOURCE_LOCK PROJECT ROOTFS_ARCHIVE HOST_PM_ARCHIVE ARTIFACT_DIR}
host_pm_archive=${4:?Usage: build-image.sh SOURCE_LOCK PROJECT ROOTFS_ARCHIVE HOST_PM_ARCHIVE ARTIFACT_DIR}
artifact_dir=${5:?Usage: build-image.sh SOURCE_LOCK PROJECT ROOTFS_ARCHIVE HOST_PM_ARCHIVE ARTIFACT_DIR}
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
lock=$(realpath "$lock")
project=$(realpath "$project")
rootfs_archive=$(realpath "$rootfs_archive")
host_pm_archive=$(realpath "$host_pm_archive")
mkdir -p "$artifact_dir"
artifact_dir=$(realpath "$artifact_dir")

export FRIENDLYWRT_VERSION
FRIENDLYWRT_VERSION=$(python3 "$SCRIPT_DIR/lock-query.py" "$lock" get friendlywrt_version)
"$SCRIPT_DIR/apply-customizations.sh" "$lock" "$project" image

tar -I pigz -xf "$rootfs_archive" -C "$project"
tar -I pigz -xf "$host_pm_archive" -C "$project"

cd "$project"
./build.sh uboot
./build.sh kernel
./build.sh sd-img

# shellcheck source=/dev/null
source .current_config.mk
raw_image="out/$TARGET_SD_RAW_FILENAME"
gzip_image="$raw_image.gz"
[[ -f "$raw_image" && -f "$gzip_image" ]] || {
	echo "Expected image output is missing: $raw_image(.gz)" >&2
	exit 1
}
gzip -t "$gzip_image"

cp "$gzip_image" "$artifact_dir/"
cp "$lock" "$artifact_dir/source-lock.json"
(
	cd "$artifact_dir"
	sha256sum "$(basename "$gzip_image")" source-lock.json
) >"$artifact_dir/SHA256SUMS"
sha256sum "$raw_image" | \
	awk -v name="$(basename "$raw_image")" '{print $1 "  " name}' \
	>"$artifact_dir/RAW_IMAGE_SHA256"

"$SCRIPT_DIR/validate-image-artifacts.sh" \
	"$raw_image" "$gzip_image" "$artifact_dir/SHA256SUMS"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
	{
		echo "image_filename=$(basename "$gzip_image")"
		echo "raw_filename=$(basename "$raw_image")"
	} >>"$GITHUB_OUTPUT"
fi
