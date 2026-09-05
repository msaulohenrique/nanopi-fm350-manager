# Troubleshooting

## No maintenance page

Connect a computer directly to the RJ45 and first leave IPv4 on DHCP/automatic. If it does not receive a lease, use:

- address: `192.168.77.2`;
- mask: `255.255.255.0`;
- gateway and DNS: `192.168.77.1`.

Then try `ping 192.168.77.1` and open `https://192.168.77.1/`. The normal DHCP range is `192.168.77.100–149`.

On a fresh public image, sign in to LuCI as `root` with an empty password only for the first login and set a strong password immediately in **System → Administration**. SSH password login is disabled by default.

## Candidate image does not boot

A `candidate-*` release is build-validated but not automatically hardware-validated. Do not promote a candidate that hangs.

Record:

- exact candidate tag;
- `.img.gz` SHA-256 from `SHA256SUMS`;
- microSD model/capacity;
- power supply and FM350 adapter power arrangement;
- whether the FM350 was connected during boot;
- `sys_led` and `user_led` behavior;
- UART/U-Boot/kernel output when available.

First retry with a known-good microSD and the NanoPi powered correctly, with the FM350 adapter separately powered as required by the hardware. If a previously hardware-verified stable image boots on the same setup but the candidate does not, include both release tags in the issue.

See [HARDWARE_VALIDATION.md](HARDWARE_VALIDATION.md).

## FM350 is not connected

Check the SIM first: it must be active and unlocked. On the NanoPi, collect:

```sh
lsusb
/usr/sbin/fm350-find-port
uci show network.cellular
logread -e fm350
ifstatus cellular
/usr/sbin/fm350-status
```

Expected USB IDs are `0e8d:7126` or `0e8d:7127`. The detector accepts interface 04 for mode 40 and interface 06 for mode 41. If the modem exposes another layout, open an issue with `lsusb -t` and the `/sys/class/tty/<device>/device` path.

## RSRP / RSRQ / SINR are unknown

`/usr/sbin/fm350-status` parses the extended FM350 `AT+CESQ` response. LTE reports RSRP/RSRQ; NR firmware can additionally report SS-RSRP, SS-RSRQ and SS-SINR. Some firmware/RAT states return unknown sentinel values.

Check the AT response directly only during maintenance, when no other `gcom` operation is using the port. If NR SINR remains unknown while 5G is active, include modem firmware, `AT+CESQ` output and RAT details in the issue.

## Telemetry API returns 401

The API requires the per-device `X-API-Key` header. Open **Network → FM350 Manager → Telemetry API** to view or rotate the token.

Example:

```sh
curl -k -H 'X-API-Key: TOKEN' \
  'https://192.168.77.1/cgi-bin/fm350-telemetry'
```

A rotated token invalidates the previous one immediately.

## Telemetry API returns 503

The API is disabled. Re-enable it from the Telemetry API tab or locally with:

```sh
/usr/sbin/fm350-api-token enable
```

## Downstream router has no Internet

Connect the NanoPi RJ45 to the downstream router's WAN/Internet port and configure that port for DHCP. Confirm that it received an address from `192.168.77.100–149`, gateway/DNS `192.168.77.1`, and that `ifstatus cellular` is up. The downstream LAN cannot also use `192.168.77.0/24`; change it to another subnet such as `192.168.1.0/24`.

## Automated candidate build failed

Open the issue created by the candidate workflow and follow its Actions run link. Common causes include an upstream manifest rename, package incompatibility with a new FriendlyWrt line, insufficient runner disk or a stage exceeding six hours.

The workflow never publishes a finished candidate after a failed build. Incomplete draft releases are removed automatically.
