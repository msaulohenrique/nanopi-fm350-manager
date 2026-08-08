#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
cd "$REPO_ROOT"

required=(
	.github/workflows/ci.yml
	.github/workflows/release.yml
	config/07-fm350
	config/build.env
	overlay/install.sh
	overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350
	overlay/rootfs/usr/sbin/fm350-find-port
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
grep -q "set network.wan.device='eth0'" \
	overlay/rootfs/etc/uci-defaults/99-nanopi-neo3-plus-fm350

python3 -m compileall -q scripts
"$REPO_ROOT/tests/test-fm350-find-port.sh"
echo "Repository validation passed"
