#!/bin/bash
set -euo pipefail

ROOTFS_DIR=${1:?Usage: install.sh ROOTFS_DIR}
CURRPATH=$PWD

rsync -a --no-o --no-g "$CURRPATH/rootfs/" "$ROOTFS_DIR/"

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
	install -d -m 0700 "$ROOTFS_DIR/root/.ssh"
	install -m 0600 "$CURRPATH/authorized_keys" "$ROOTFS_DIR/root/.ssh/authorized_keys"
fi

chmod 0755 "$ROOTFS_DIR/etc/init.d/fm350-autoconfig"
chmod 0755 "$ROOTFS_DIR/etc/uci-defaults/99-nanopi-neo3-plus-fm350"
chmod 0755 "$ROOTFS_DIR/etc/hotplug.d/usb/95-fm350-autoconfig"
chmod 0755 "$ROOTFS_DIR/usr/sbin/fm350-autoconfig"
chmod 0755 "$ROOTFS_DIR/usr/sbin/fm350-find-port"
