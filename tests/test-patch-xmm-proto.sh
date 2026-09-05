#!/bin/bash
set -euo pipefail

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

cat >"$workdir/xmm.sh" <<'EOF'
	for p in $(seq 1 $maxfail); do
		DEVPORT=$device gcom -s /etc/gcom/probeport.gcom
		done
	PINCODE="$pincode" gcom -d "$device" -s /etc/gcom/setpin.gcom || return 1
	CID=$profile AUTH=$AUTH AUTHCMD=$AUTHCMD USER="$username" PASS="$password" gcom -d "$device" -s /etc/gcom/xmm-auth.gcom >/dev/null 2>&1
	CID=$profile APN=$apn PDP=$pdp PREFIX=$PREFIX gcom -d $device -s /etc/gcom/xmm-connect.gcom >/dev/null 2>&1
	DATA=$(CID=$profile DNSQUERY=$DNSQUERY gcom -d $device -s /etc/gcom/xmm-config.gcom)
	ip4addr=$(echo "$DATA" | awk -F [,] '/^\+CGPADDR/{gsub("\r|\"", ""); print $2}') >/dev/null 2>&1
	lladdr=$(echo "$DATA" | awk -F [,] '/^\+CGPADDR/{gsub("\r|\"", ""); print $3}') >/dev/null 2>&1
	for n in $(echo $ns); do
		$(valid_ip4 $n) && {
			echo dns
		}
	done
	[ "$pdp" = "IP" ] && {
		$(valid_ip4 $ip4addr) && [ "$ip4addr" != "0.0.0.0" ] && {
			echo address
		}
	}
	CID=$profile gcom -d $device -s /etc/gcom/xmm-disconnect.gcom >/dev/null 2>&1
EOF

awk -f "$REPO_ROOT/overlay/patch-xmm-proto.awk" \
	"$workdir/xmm.sh" >"$workdir/patched.sh"

grep -q $'^\tip4mask=24$' "$workdir/patched.sh"
grep -q 'Waiting for IPv4 address' "$workdir/patched.sh"
grep -q $'^\t\tvalid_ip4 "$n" && {$' "$workdir/patched.sh"
grep -q $'^\t\tvalid_ip4 "$ip4addr" && \[ "$ip4addr" != "0.0.0.0" \] && {$' \
	"$workdir/patched.sh"

locked_count=$(grep -Fc '/usr/sbin/fm350-gcom-locked' "$workdir/patched.sh")
[[ "$locked_count" -eq 6 ]] || {
	echo "Expected 6 locked netifd gcom calls, got $locked_count" >&2
	exit 1
}
if grep -Eq '(^|[[:space:]])gcom -' "$workdir/patched.sh"; then
	echo 'A raw netifd gcom call survived the patch' >&2
	exit 1
fi

if awk -f "$REPO_ROOT/overlay/patch-xmm-proto.awk" \
	"$workdir/patched.sh" >/dev/null 2>&1; then
	echo "The xmm patch unexpectedly applied twice" >&2
	exit 1
fi

echo "xmm protocol patch test passed"
