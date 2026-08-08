#!/bin/bash
set -euo pipefail

lock=${1:?Usage: apply-customizations.sh SOURCE_LOCK PROJECT rootfs|image|all}
project=${2:?Usage: apply-customizations.sh SOURCE_LOCK PROJECT rootfs|image|all}
mode=${3:?Usage: apply-customizations.sh SOURCE_LOCK PROJECT rootfs|image|all}
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
lock=$(realpath "$lock")
project=$(realpath "$project")

[[ -d "$project" ]] || {
	echo "Project directory does not exist: $project" >&2
	exit 1
}
cp "$REPO_ROOT/targets/rk3528_fm350.mk" "$project/.current_config.mk"

if [[ "$mode" == "rootfs" || "$mode" == "all" ]]; then
	modem_url=$(python3 "$SCRIPT_DIR/lock-query.py" "$lock" resource modemfeed url)
	modem_commit=$(python3 "$SCRIPT_DIR/lock-query.py" "$lock" resource modemfeed commit)
	temp_dir=$(mktemp -d)
	trap 'rm -rf -- "$temp_dir"' EXIT
	git clone --quiet --filter=blob:none --no-checkout "$modem_url" "$temp_dir/modemfeed"
	git -C "$temp_dir/modemfeed" fetch --quiet --depth=1 origin "$modem_commit"
	git -C "$temp_dir/modemfeed" checkout --quiet --detach "$modem_commit"

	install -d "$project/friendlywrt/package/fm350/xmm-modem"
	install -d "$project/friendlywrt/package/fm350/luci-proto-xmm"
	rsync -a --delete "$temp_dir/modemfeed/packages/net/xmm-modem/" \
		"$project/friendlywrt/package/fm350/xmm-modem/"
	rsync -a --delete "$temp_dir/modemfeed/luci/protocols/luci-proto-xmm/" \
		"$project/friendlywrt/package/fm350/luci-proto-xmm/"
	cp "$REPO_ROOT/config/07-fm350" "$project/configs/rockchip/07-fm350"

	base_config="$project/configs/rockchip/01-nanopi"
	sed -i -e '/^CONFIG_MAKE_TOOLCHAIN=y$/d' "$base_config"
	sed -i -e 's/^CONFIG_IB=y$/# CONFIG_IB is not set/' "$base_config"
	sed -i -e 's/^CONFIG_SDK=y$/# CONFIG_SDK is not set/' "$base_config"
fi

if [[ "$mode" == "image" || "$mode" == "all" ]]; then
	install -d "$project/custom/nanopi-fm350"
	rsync -a --delete "$REPO_ROOT/overlay/" "$project/custom/nanopi-fm350/"

	if [[ -n "${AUTHORIZED_KEYS:-}" ]]; then
		while IFS= read -r key; do
			[[ -z "$key" || "$key" == \#* ]] && continue
			[[ "$key" =~ ^(ssh-(ed25519|rsa)|ecdsa-sha2-)\  ]] || {
				echo "AUTHORIZED_KEYS contains an unsupported line" >&2
				exit 1
			}
		done <<<"$AUTHORIZED_KEYS"
		printf '%s\n' "$AUTHORIZED_KEYS" >"$project/custom/nanopi-fm350/authorized_keys"
		chmod 0600 "$project/custom/nanopi-fm350/authorized_keys"
	fi

	if [[ -n "${ROOT_PASSWORD_HASH:-}" ]]; then
		case "$ROOT_PASSWORD_HASH" in
			\$5\$*|\$6\$*|\$y\$*) ;;
			*)
				echo "ROOT_PASSWORD_HASH must be SHA-256, SHA-512 or yescrypt crypt(3)" >&2
				exit 1
				;;
		esac
		printf '%s\n' "$ROOT_PASSWORD_HASH" >"$project/custom/nanopi-fm350/root-password.hash"
		chmod 0600 "$project/custom/nanopi-fm350/root-password.hash"
	fi
fi
