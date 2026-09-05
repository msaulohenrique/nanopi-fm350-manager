#!/bin/sh

# Fibocom FM350-GL signal conversions. The modem extends +CESQ with NR fields:
# rxlev,ber,rscp,ecno,rsrq,rsrp,ss_rsrq,ss_rsrp,ss_sinr.

fm350_is_uint() {
	case "${1:-}" in
		''|*[!0-9]*) return 1 ;;
		*) return 0 ;;
	esac
}

fm350_csq_rssi() {
	raw=${1:-}
	fm350_is_uint "$raw" || return 0
	[ "$raw" -le 31 ] || return 0
	printf '%s\n' "$((-113 + (2 * raw)))"
}

fm350_lte_rsrq() {
	raw=${1:-}
	fm350_is_uint "$raw" || return 0
	[ "$raw" -le 34 ] || return 0
	awk -v raw="$raw" 'BEGIN { printf "%.1f\n", -19.5 + (raw * 0.5) }'
}

fm350_lte_rsrp() {
	raw=${1:-}
	fm350_is_uint "$raw" || return 0
	[ "$raw" -le 97 ] || return 0
	printf '%s\n' "$((-140 + raw))"
}

fm350_nr_rsrq() {
	raw=${1:-}
	fm350_is_uint "$raw" || return 0
	[ "$raw" -lt 128 ] || return 0
	awk -v raw="$raw" 'BEGIN { printf "%.1f\n", -43 + (raw * 0.5) }'
}

fm350_nr_rsrp() {
	raw=${1:-}
	fm350_is_uint "$raw" || return 0
	[ "$raw" -lt 128 ] || return 0
	printf '%s\n' "$((-156 + raw))"
}

fm350_nr_sinr() {
	raw=${1:-}
	fm350_is_uint "$raw" || return 0
	[ "$raw" -lt 128 ] || return 0
	awk -v raw="$raw" 'BEGIN { printf "%.1f\n", -23 + (raw * 0.5) }'
}
