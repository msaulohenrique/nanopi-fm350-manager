#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
finder="$REPO_ROOT/overlay/rootfs/usr/sbin/fm350-find-port"
temp_dir=$(mktemp -d)
trap 'rm -rf -- "$temp_dir"' EXIT

make_fixture() {
	local pid=$1
	local interface=$2
	local tty=$3
	local usb="$temp_dir/devices/usb1/1-1"
	local iface="$usb/1-1:1.$interface"
	local tty_device="$iface/$tty"

	rm -rf -- "$temp_dir/class" "$temp_dir/devices"
	mkdir -p "$temp_dir/class/tty/$tty" "$tty_device"
	printf '0e8d\n' >"$usb/idVendor"
	printf '%s\n' "$pid" >"$usb/idProduct"
	printf '%s\n' "$interface" >"$iface/bInterfaceNumber"
	ln -s "$tty_device" "$temp_dir/class/tty/$tty/device"
}

make_fixture 7127 06 ttyUSB3
result=$(FM350_SYS_CLASS_TTY="$temp_dir/class/tty" "$finder")
[[ "$result" == "/dev/ttyUSB3" ]]

make_fixture 7126 04 ttyACM1
result=$(FM350_SYS_CLASS_TTY="$temp_dir/class/tty" "$finder")
[[ "$result" == "/dev/ttyACM1" ]]

make_fixture 7127 05 ttyUSB9
if FM350_SYS_CLASS_TTY="$temp_dir/class/tty" "$finder"; then
	echo "Finder accepted a non-AT FM350 interface" >&2
	exit 1
fi

echo "FM350 port detection tests passed"
