#!/bin/bash
set -euo pipefail

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
wrapper="$REPO_ROOT/overlay/rootfs/usr/sbin/fm350-gcom-locked"
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

cat >"$workdir/gcom" <<'EOF'
#!/bin/sh
sleep "${FAKE_GCOM_SLEEP:-0}"
exit "${FAKE_GCOM_RC:-0}"
EOF
chmod +x "$workdir/gcom"

lock_dir="$workdir/fm350-at.lock"

PATH="$workdir:$PATH" FM350_AT_LOCK_DIR="$lock_dir" FAKE_GCOM_SLEEP=2 \
	"$wrapper" -s fake.gcom &
first_pid=$!
for _ in $(seq 1 20); do
	[[ -d "$lock_dir" ]] && break
	sleep 0.1
done
[[ -d "$lock_dir" ]] || {
	echo 'First locked gcom session did not acquire the lock' >&2
	kill "$first_pid" 2>/dev/null || true
	exit 1
}

set +e
PATH="$workdir:$PATH" FM350_AT_LOCK_DIR="$lock_dir" FM350_AT_LOCK_WAIT=1 \
	"$wrapper" -s fake.gcom >/dev/null 2>&1
second_rc=$?
set -e
[[ "$second_rc" -eq 75 ]] || {
	echo "Expected a competing session to exit 75, got $second_rc" >&2
	kill "$first_pid" 2>/dev/null || true
	exit 1
}

wait "$first_pid"
[[ ! -e "$lock_dir" ]] || {
	echo 'AT lock was not released after gcom exited' >&2
	exit 1
}

echo 'FM350 gcom lock tests passed'
