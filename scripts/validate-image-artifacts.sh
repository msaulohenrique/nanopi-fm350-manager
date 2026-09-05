#!/bin/bash
set -euo pipefail

raw=${1:?Usage: validate-image-artifacts.sh RAW_IMAGE GZIP_IMAGE SHA256SUMS}
gzip_image=${2:?Usage: validate-image-artifacts.sh RAW_IMAGE GZIP_IMAGE SHA256SUMS}
sums=${3:?Usage: validate-image-artifacts.sh RAW_IMAGE GZIP_IMAGE SHA256SUMS}

[[ -f "$raw" ]] || { echo "Raw image missing: $raw" >&2; exit 1; }
[[ -f "$gzip_image" ]] || { echo "Compressed image missing: $gzip_image" >&2; exit 1; }
[[ -f "$sums" ]] || { echo "Checksum file missing: $sums" >&2; exit 1; }

raw_size=$(stat -c %s "$raw")
gzip_size=$(stat -c %s "$gzip_image")
(( raw_size > 1000 * 1024 * 1024 )) || {
	echo "Raw image is unexpectedly small: $raw_size bytes" >&2
	exit 1
}
(( gzip_size > 50 * 1024 * 1024 )) || {
	echo "Compressed image is unexpectedly small: $gzip_size bytes" >&2
	exit 1
}

gzip -t "$gzip_image"

fdisk_output=$(fdisk -l "$raw")
printf '%s\n' "$fdisk_output"
partition_count=$(printf '%s\n' "$fdisk_output" | awk -v image="$raw" '$1 ~ ("^" image "[0-9]+$") { count++ } END { print count + 0 }')
(( partition_count >= 2 )) || {
	echo "Expected at least two partitions in the SD image; found $partition_count" >&2
	exit 1
}

first_meg_hash=$(dd if="$raw" bs=1M count=1 status=none | sha256sum | awk '{print $1}')
zero_meg_hash=$(dd if=/dev/zero bs=1M count=1 status=none | sha256sum | awk '{print $1}')
[[ "$first_meg_hash" != "$zero_meg_hash" ]] || {
	echo "The first MiB of the image is entirely zero" >&2
	exit 1
}

(
	cd "$(dirname "$sums")"
	sha256sum -c "$(basename "$sums")"
)

echo "Image artifact validation passed: raw=$raw_size bytes, compressed=$gzip_size bytes, partitions=$partition_count"
