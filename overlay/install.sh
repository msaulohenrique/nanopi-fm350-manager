#!/bin/bash
set -euo pipefail

ROOTFS_DIR=${1:?Usage: install.sh ROOTFS_DIR}
CURRPATH=$PWD

rsync -a --no-o --no-g "$CURRPATH/rootfs/" "$ROOTFS_DIR/"

xmm_proto="$ROOTFS_DIR/lib/netifd/proto/xmm.sh"
xmm_patched=$(mktemp)
awk -f "$CURRPATH/patch-xmm-proto.awk" "$xmm_proto" >"$xmm_patched"
install -m 0755 "$xmm_patched" "$xmm_proto"
rm -f "$xmm_patched"

# Credentials are injected only on the Actions runner or during a local build.
# If no password hash is supplied, FriendlyWrt's upstream root password remains.
if [[ -s "$CURRPATH/root-password.hash" ]]; then
	root_hash=$(<"$CURRPATH/root-password.hash")
	case "$root_hash" in
		\$5\$*|\$6\$*|\$y\$*) ;;
		*)
			echo "Unsupported ROOT_PASSWORD_HASH format" >&2
			exit 1
			;;
	esac
	sed -i "s|^root:[^:]*:|root:${root_hash}:|" "$ROOTFS_DIR/etc/shadow"
fi

if [[ -s "$CURRPATH/authorized_keys" ]]; then
	install -d -m 0700 "$ROOTFS_DIR/etc/dropbear"
	install -m 0600 "$CURRPATH/authorized_keys" "$ROOTFS_DIR/etc/dropbear/authorized_keys"
fi

chmod 0755 "$ROOTFS_DIR/etc/init.d/fm350-autoconfig"
chmod 0755 "$ROOTFS_DIR/etc/uci-defaults/99-nanopi-neo3-plus-fm350"
chmod 0755 "$ROOTFS_DIR/etc/hotplug.d/usb/95-fm350-autoconfig"
chmod 0755 "$ROOTFS_DIR/etc/rc.button/BTN_1"
chmod 0755 "$ROOTFS_DIR/usr/sbin/fm350-autoconfig"
chmod 0755 "$ROOTFS_DIR/usr/sbin/fm350-find-port"
chmod 0755 "$ROOTFS_DIR/usr/sbin/fm350-control"
chmod 0755 "$ROOTFS_DIR/usr/sbin/fm350-radio"
chmod 0755 "$ROOTFS_DIR/usr/sbin/fm350-sms"
chmod 0755 "$ROOTFS_DIR/usr/sbin/fm350-status"
