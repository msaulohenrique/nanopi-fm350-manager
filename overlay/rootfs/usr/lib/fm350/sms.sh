#!/bin/sh

# The current FM350 send path uses AT+CSCS="GSM" in text mode. Until a
# hardware-validated UCS-2/PDU implementation exists, accept only the printable
# ASCII subset that maps directly to the GSM 7-bit default alphabet. Reject the
# GSM extension-table characters too because they consume escape septets and
# would make the simple 160-character limit inaccurate.
fm350_sms_text_is_basic() {
	text=$1
	[ -n "$text" ] || return 1
	[ "${#text}" -le 160 ] || return 1

	# Reject control bytes, UTF-8/non-ASCII and other non-printable input.
	if LC_ALL=C printf '%s' "$text" | grep -q '[^ -~]'; then
		return 1
	fi

	# Printable ASCII characters not present directly in the GSM default table.
	# Some are available through the GSM extension table, but deliberately reject
	# them until septet-aware length accounting is implemented.
	case "$text" in
		*'['*|*']'*|*'\'*|*'^'*|*'`'*|*'{'*|*'|'*|*'}'*|*'~'*) return 1 ;;
	esac

	return 0
}
