#!/bin/bash
set -euo pipefail

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

cat >"$workdir/xmm.sh" <<'EOF'
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
EOF

awk -f "$REPO_ROOT/overlay/patch-xmm-proto.awk" \
	"$workdir/xmm.sh" >"$workdir/patched.sh"

grep -q $'^\tip4mask=24$' "$workdir/patched.sh"
grep -q 'Waiting for IPv4 address' "$workdir/patched.sh"
grep -q $'^\t\tvalid_ip4 "$n" && {$' "$workdir/patched.sh"
grep -q $'^\t\tvalid_ip4 "$ip4addr" && \[ "$ip4addr" != "0.0.0.0" \] && {$' \
	"$workdir/patched.sh"

if awk -f "$REPO_ROOT/overlay/patch-xmm-proto.awk" \
	"$workdir/patched.sh" >/dev/null 2>&1; then
	echo "The xmm patch unexpectedly applied twice" >&2
	exit 1
fi

echo "xmm protocol patch test passed"
