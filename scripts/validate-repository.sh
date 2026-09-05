#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
cd "$REPO_ROOT"

required=(
	.github/workflows/ci.yml
	.github/workflows/release.yml
	.github/workflows/promote-hardware-verified.yml
	config/07-fm350
	config/build.env
	overlay/install.sh
	overlay/patch-xmm-proto.awk
	overlay/rootfs/etc/gcom/fm350-status.gcom
	overlay/rootfs/etc/gcom/fm350-radio.gcom
	overlay/rootfs/etc/gcom/fm350-sms-delete.gcom
	overlay/rootfs/etc/gcom/fm350-sms-list.gcom
	overlay/rootfs/etc/gcom/fm350-sms-send.gcom
	overlay/rootfs/etc/gcom/xmm-config.gcom
	overlay/rootfs/etc/gcom/xmm-connect.gcom
	overlay/rootfs/etc/rc.button/BTN_1
	overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350
	overlay/rootfs/usr/lib/fm350/signal.sh
	overlay/rootfs/usr/sbin/fm350-control
	overlay/rootfs/usr/sbin/fm350-radio
	overlay/rootfs/usr/sbin/fm350-sms
	overlay/rootfs/usr/sbin/fm350-find-port
	overlay/rootfs/usr/sbin/fm350-status
	overlay/rootfs/usr/sbin/fm350-telemetry
	overlay/rootfs/usr/sbin/fm350-api-token
	overlay/rootfs/usr/share/luci/menu.d/luci-app-fm350.json
	overlay/rootfs/usr/share/rpcd/acl.d/luci-app-fm350.json
	overlay/rootfs/www/cgi-bin/fm350-telemetry
	overlay/rootfs/www/luci-static/resources/view/fm350/status.js
	overlay/rootfs/www/luci-static/resources/view/fm350/telemetry.js
	scripts/validate-image-artifacts.sh
	tests/test-signal-metrics.sh
	targets/rk3528_fm350.mk
)
for path in "${required[@]}"; do
	[[ -f "$path" ]] || {
		echo "Required file is missing: $path" >&2
		exit 1
	}
done

if git ls-files | grep -Eq '(^|/)(authorized_keys|root-password[.]hash)$|[.]img([.]gz)?$'; then
	echo "A generated image or credential file is tracked" >&2
	exit 1
fi

if git grep -nE 'ssh-(rsa|ed25519) AAAA|root:\$[0-9y]\$' -- . \
	':!scripts/validate-repository.sh'; then
	echo "A concrete SSH key or password hash appears to be committed" >&2
	exit 1
fi

if grep -R -nE '^\s*uses:\s*[^#[:space:]]+@[^#[:space:]]+' .github/workflows |
	grep -Ev '@[0-9a-f]{40}([[:space:]]*#.*)?$'; then
	echo "Every GitHub Action must be pinned to a full commit SHA" >&2
	exit 1
fi

grep -q "set network.cellular.apn='surf.br'" \
	overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350
grep -q "set network.maintenance.ipaddr='192.168.77.1'" \
	overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350
grep -q "set network.maintenance.device='eth0'" \
	overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350
grep -q "set dhcp.maintenance.ignore='0'" \
	overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350
# Assert the literal variable reference in source.
# shellcheck disable=SC2016
grep -q 'uci add_list "$wan_zone.network=cellular"' \
	overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350
grep -q "set dropbear.main.PasswordAuth='off'" \
	overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350
grep -q "set dropbear.main.RootPasswordAuth='off'" \
	overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350
grep -q "set system.cellular_led.dev='eth1'" \
	overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350
grep -q '/usr/sbin/fm350-api-token ensure' \
	overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350
grep -q "'/usr/sbin/fm350-sms'" \
	overlay/rootfs/www/luci-static/resources/view/fm350/status.js
grep -q 'handleConfigSave' \
	overlay/rootfs/www/luci-static/resources/view/fm350/status.js
grep -q 'X-API-Key' overlay/rootfs/www/cgi-bin/fm350-telemetry
grep -q 'json_add_string rsrp' overlay/rootfs/usr/sbin/fm350-status
grep -q 'json_add_string rsrq' overlay/rootfs/usr/sbin/fm350-status
grep -q 'json_add_string sinr' overlay/rootfs/usr/sbin/fm350-status
if grep -Eq 'json_add_string (pincode|password|username)' overlay/rootfs/usr/sbin/fm350-status; then
	echo "The status API must not expose stored cellular secrets" >&2
	exit 1
fi
if grep -Eq "set dropbear\..*(PasswordAuth|RootPasswordAuth)='on'" \
	overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350; then
	echo "Public images must not enable SSH password authentication" >&2
	exit 1
fi
if grep -Eq 'root[^[:alnum:]]*/?password|password[^[:alnum:]]*root' README.md SECURITY.md docs/*.md 2>/dev/null; then
	echo "Documentation must not advertise a public root/password credential" >&2
	exit 1
fi
# Assert literal build-script paths, not runtime values.
# shellcheck disable=SC2016
grep -q '"$ROOTFS_DIR/etc/dropbear/authorized_keys"' overlay/install.sh
grep -q "sed -i 's|\^root:\[\^:\]\*:\|root::|'" overlay/install.sh
# shellcheck disable=SC2016
if grep -q '"$ROOTFS_DIR/root/.ssh/authorized_keys"' overlay/install.sh; then
	echo "OpenWrt Dropbear keys must be installed in /etc/dropbear/authorized_keys" >&2
	exit 1
fi

python3 -m compileall -q scripts
python3 -m json.tool overlay/rootfs/usr/share/luci/menu.d/luci-app-fm350.json >/dev/null
python3 -m json.tool overlay/rootfs/usr/share/rpcd/acl.d/luci-app-fm350.json >/dev/null
bash -n overlay/rootfs/usr/sbin/fm350-control
bash -n overlay/rootfs/usr/sbin/fm350-radio
bash -n overlay/rootfs/usr/sbin/fm350-sms
bash -n overlay/rootfs/usr/sbin/fm350-status
bash -n overlay/rootfs/usr/sbin/fm350-telemetry
bash -n overlay/rootfs/usr/sbin/fm350-api-token
bash -n overlay/rootfs/www/cgi-bin/fm350-telemetry
bash -n scripts/validate-image-artifacts.sh
bash -n tests/test-signal-metrics.sh
bash -n overlay/rootfs/etc/rc.button/BTN_1
node -e 'new Function(require("fs").readFileSync(process.argv[1], "utf8"))' \
	overlay/rootfs/www/luci-static/resources/view/fm350/status.js
node -e 'new Function(require("fs").readFileSync(process.argv[1], "utf8"))' \
	overlay/rootfs/www/luci-static/resources/view/fm350/telemetry.js
"$REPO_ROOT/tests/test-fm350-find-port.sh"
bash "$REPO_ROOT/tests/test-patch-xmm-proto.sh"
bash "$REPO_ROOT/tests/test-signal-metrics.sh"
echo "Repository validation passed"
