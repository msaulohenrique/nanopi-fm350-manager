#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
# shellcheck disable=SC1091
source "$REPO_ROOT/overlay/rootfs/usr/lib/fm350/sms.sh"

expect_ok() {
	fm350_sms_text_is_basic "$1" || {
		echo "Expected SMS text to be accepted: $1" >&2
		exit 1
	}
}

expect_fail() {
	if fm350_sms_text_is_basic "$1"; then
		echo "Expected SMS text to be rejected: $1" >&2
		exit 1
	fi
}

expect_ok 'Teste SMS 123 @ _ OK!'
expect_ok "$(printf '%160s' '' | tr ' ' A)"
expect_fail "$(printf '%161s' '' | tr ' ' A)"
expect_fail 'ação com acento'
expect_fail 'emoji 🚀'
expect_fail 'extension [brackets]'
expect_fail 'backslash \'
expect_fail 'caret ^'
expect_fail 'tilde ~'
expect_fail $'line\nbreak'

echo 'SMS validation tests passed'
