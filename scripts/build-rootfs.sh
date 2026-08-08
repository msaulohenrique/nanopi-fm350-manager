#!/bin/bash
set -euo pipefail

lock=${1:?Usage: build-rootfs.sh SOURCE_LOCK PROJECT ARTIFACT_DIR}
project=${2:?Usage: build-rootfs.sh SOURCE_LOCK PROJECT ARTIFACT_DIR}
artifact_dir=${3:?Usage: build-rootfs.sh SOURCE_LOCK PROJECT ARTIFACT_DIR}
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
lock=$(realpath "$lock")
project=$(realpath "$project")
mkdir -p "$artifact_dir"
artifact_dir=$(realpath "$artifact_dir")

export FRIENDLYWRT_VERSION
FRIENDLYWRT_VERSION=$(python3 "$SCRIPT_DIR/lock-query.py" "$lock" get friendlywrt_version)
"$SCRIPT_DIR/apply-customizations.sh" "$lock" "$project" rootfs

cd "$project"
DEBUG_DOT_CONFIG=1 ./build.sh friendlywrt

cd friendlywrt
make download -j"$(nproc)"
find dl -type f -size -1024c -print -delete
if ! make -j"$(nproc)"; then
	echo "Parallel build failed; retrying serially with verbose output" >&2
	make -j1 V=s
fi
cd ..

# shellcheck source=/dev/null
source .current_config.mk
rootfs_filename="rootfs-friendlywrt-${FRIENDLYWRT_VERSION}.tar.gz"
host_pm_filename="host-pm-friendlywrt-${FRIENDLYWRT_VERSION}.tar.gz"
tar -I 'pigz -6' -cf "$artifact_dir/$rootfs_filename" \
	"${FRIENDLYWRT_SRC}/${FRIENDLYWRT_ROOTFS}" \
	"${FRIENDLYWRT_SRC}/${FRIENDLYWRT_PACKAGE_DIR}"

pm_bin=
[[ -f "$FRIENDLYWRT_SRC/staging_dir/host/bin/apk" ]] && \
	pm_bin="$FRIENDLYWRT_SRC/staging_dir/host/bin/apk"
[[ -f "$FRIENDLYWRT_SRC/staging_dir/host/bin/opkg" ]] && \
	pm_bin="$FRIENDLYWRT_SRC/staging_dir/host/bin/opkg"
[[ -n "$pm_bin" ]] || {
	echo "Neither apk nor opkg was found in the host staging directory" >&2
	exit 1
}
ldd_output=$(ldd "$pm_bin" 2>&1 || true)
if ! grep -Eq 'not a dynamic executable|statically linked' <<<"$ldd_output"; then
	if grep -q 'not found' <<<"$ldd_output" || \
		grep -E '=> /[^ ]+' <<<"$ldd_output" | \
		awk '{print $3}' | grep -Ev '^/(lib|lib64|usr/lib)/' >/dev/null; then
		echo "Host package manager has non-portable dependencies:" >&2
		echo "$ldd_output" >&2
		exit 1
	fi
fi
tar -I 'pigz -6' -cf "$artifact_dir/$host_pm_filename" "$pm_bin"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
	{
		echo "rootfs_filename=$rootfs_filename"
		echo "host_pm_filename=$host_pm_filename"
	} >>"$GITHUB_OUTPUT"
fi
