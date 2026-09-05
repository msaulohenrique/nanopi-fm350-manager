#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
cd "$REPO_ROOT"

uci_defaults=overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350
hotplug=overlay/rootfs/etc/hotplug.d/usb/95-fm350-autoconfig
api_token=overlay/rootfs/usr/sbin/fm350-api-token
status=overlay/rootfs/usr/sbin/fm350-status
release=.github/workflows/release.yml

# PR #1: configure the actual Dropbear server and accept unpadded USB hotplug VID.
grep -Fq 'while uci -q delete dropbear.@dropbear[0]' "$uci_defaults"
grep -Fq "set dropbear.main=dropbear" "$uci_defaults"
grep -Fq "set dropbear.main.PasswordAuth='off'" "$uci_defaults"
grep -Fq "set dropbear.main.RootPasswordAuth='off'" "$uci_defaults"
grep -Fq 'e8d/7126/*|e8d/7127/*|0e8d/7126/*|0e8d/7127/*' "$hotplug"

# PR #4: failure tracker lookup must select an exact issue title.
exact_count=$(grep -Fc 'select(.title == "Automated FriendlyWrt candidate failed")' "$release" || true)
[[ "$exact_count" -ge 2 ]]
if grep -Fq -- "--json number --jq '.[0].number // empty'" "$release"; then
	echo 'Release workflow still uses first fuzzy issue-search result' >&2
	exit 1
fi

# PR #5: status polling shares the AT lock; outbound text is validated before gcom.
grep -Fq 'at_lock_dir=/tmp/fm350-at.lock' "$status"
grep -Fq "mkdir \"\$at_lock_dir\"" "$status"
grep -Fq '. /usr/lib/fm350/sms.sh' overlay/rootfs/usr/sbin/fm350-sms
grep -Fq "fm350_sms_text_is_basic \"\$text\"" overlay/rootfs/usr/sbin/fm350-sms

# PR #6: UCI backing file exists before fm350.api and host validator is invoked safely.
grep -Fq '[ -e /etc/config/fm350 ] || : >/etc/config/fm350 || return 1' "$api_token"
grep -Fq "bash \"\$SCRIPT_DIR/validate-image-artifacts.sh\"" scripts/build-image.sh

# The target-rootfs executables flagged during the audit are made executable at image build time.
for target in \
	usr/sbin/fm350-api-token \
	usr/sbin/fm350-telemetry \
	www/cgi-bin/fm350-telemetry; do
	grep -Fq "chmod 0755 \"\$ROOTFS_DIR/$target\"" overlay/install.sh || {
		echo "Missing runtime executable mode for $target" >&2
		exit 1
	}
done

echo 'Historical PR review regression checks passed'
