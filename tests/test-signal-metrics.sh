#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
# shellcheck disable=SC1091
. "$REPO_ROOT/overlay/rootfs/usr/lib/fm350/signal.sh"

assert_eq() {
	expected=$1
	actual=$2
	label=$3
	if [[ "$actual" != "$expected" ]]; then
		echo "$label: expected '$expected', got '$actual'" >&2
		exit 1
	fi
}

assert_eq -113 "$(fm350_csq_rssi 0)" 'CSQ minimum'
assert_eq -51 "$(fm350_csq_rssi 31)" 'CSQ maximum'
assert_eq '' "$(fm350_csq_rssi 99)" 'CSQ unknown'
assert_eq -19.5 "$(fm350_lte_rsrq 0)" 'LTE RSRQ minimum'
assert_eq -2.5 "$(fm350_lte_rsrq 34)" 'LTE RSRQ maximum'
assert_eq -140 "$(fm350_lte_rsrp 0)" 'LTE RSRP minimum'
assert_eq -43 "$(fm350_lte_rsrp 97)" 'LTE RSRP maximum'
assert_eq -43.0 "$(fm350_nr_rsrq 0)" 'NR RSRQ minimum'
assert_eq -156 "$(fm350_nr_rsrp 0)" 'NR RSRP minimum'
assert_eq -23.0 "$(fm350_nr_sinr 0)" 'NR SINR minimum'
assert_eq 0.0 "$(fm350_nr_sinr 46)" 'NR SINR zero point'
assert_eq '' "$(fm350_nr_sinr 255)" 'NR SINR unknown'

echo 'FM350 signal metric tests passed'
