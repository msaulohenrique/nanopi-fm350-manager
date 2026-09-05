#!/bin/sh

# The current FM350 send path uses AT+CSCS="GSM" in text mode. Until a
# hardware-validated UCS-2/PDU implementation exists, accept only the printable
# ASCII subset whose byte values map identically to the GSM 7-bit default
# alphabet. Reject extension-table characters too because they consume escape
# septets and would make the simple 160-character limit inaccurate.
fm350_sms_text_is_basic() {
	text=$1
	[ -n "$text" ] || return 1
	[ "${#text}" -le 160 ] || return 1

	# grep operates line-by-line and therefore cannot match the newline separator
	# itself. Remove CR/LF and compare first so multiline input is rejected.
	single_line=$(printf '%s' "$text" | tr -d '\r\n')
	[ "$single_line" = "$text" ] || return 1

	# Reject remaining control bytes, UTF-8/non-ASCII and non-printable input.
	if LC_ALL=C printf '%s' "$text" | grep -q '[^ -~]'; then
		return 1
	fi

	# Printable ASCII bytes whose GSM default-alphabet positions encode another
	# glyph, plus extension-table characters that require an ESC septet.
	case "$text" in
		*'@'*|*'$'*|*'_'*) return 1 ;;
		*'['*|*']'*|*'^'*|*'`'*|*'{'*|*'|'*|*'}'*|*'~'*) return 1 ;;
		*\\*) return 1 ;;
	esac

	return 0
}
