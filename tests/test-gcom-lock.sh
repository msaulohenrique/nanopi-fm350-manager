#!/bin/bash
set -euo pipefail

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
wrapper="$REPO_ROOT/overlay/rootfs/usr/sbin/fm350-gcom-locked"
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

[[ -x /usr/bin/flock ]] || {
	echo '/usr/bin/flock is required for the lock regression test' >&2
	exit 1
}

cat >"$workdir/gcom" <<'EOF'
#!/bin/sh
# Model gcom as one long-lived executable process rather than a shell retaining
# a child: exec keeps the same PID and inherited flock descriptor on sleep.
exec sleep "${FAKE_GCOM_SLEEP:-0}"
EOF
chmod +x "$workdir/gcom"
lock_file="$workdir/fm350-at.lock"

# First session acquires the kernel lock and stays inside gcom.
PATH="$workdir:$PATH" FM350_AT_LOCK_FILE="$lock_file" FAKE_GCOM_SLEEP=30 \
	sh "$wrapper" -s fake.gcom &
first_pid=$!

# Prove a competing session cannot enter while the first owns the lock.
busy_rc=0
for _ in $(seq 1 30); do
	set +e
	PATH="$workdir:$PATH" FM350_AT_LOCK_FILE="$lock_file" FM350_AT_LOCK_WAIT=0 \
		sh "$wrapper" -s fake.gcom >/dev/null 2>&1
	busy_rc=$?
	set -e
	[[ "$busy_rc" -ne 0 ]] && break
	sleep 0.1
done
[[ "$busy_rc" -ne 0 ]] || {
	echo 'Competing gcom session unexpectedly acquired the lock' >&2
	kill -KILL "$first_pid" 2>/dev/null || true
	exit 1
}

# SIGKILL cannot run shell traps. Kernel-backed flock must still be released.
kill -KILL "$first_pid"
wait "$first_pid" 2>/dev/null || true

PATH="$workdir:$PATH" FM350_AT_LOCK_FILE="$lock_file" FM350_AT_LOCK_WAIT=1 \
	sh "$wrapper" -s fake.gcom >/dev/null

# The lock file may persist by design; its advisory lock must not.
[[ -f "$lock_file" ]] || {
	echo 'Expected the reusable flock file to exist after the test' >&2
	exit 1
}

echo 'FM350 kernel-backed gcom lock tests passed'
