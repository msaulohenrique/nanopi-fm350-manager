# Troubleshooting

## No maintenance page

Connect a computer directly to the RJ45 and first leave IPv4 on DHCP/automatic. If it does not receive a lease, use the recovery settings:

- address: `192.168.77.2`;
- mask: `255.255.255.0`;
- gateway and DNS: `192.168.77.1`.

Then try `ping 192.168.77.1` and open `https://192.168.77.1/`. The normal DHCP range is `192.168.77.100–149`.

## FM350 is not connected

Check the SIM first: it must be active and unlocked. On the NanoPi, collect:

```sh
lsusb
/usr/sbin/fm350-find-port
uci show network.cellular
logread -e fm350
ifstatus cellular
```

Expected USB IDs are `0e8d:7126` or `0e8d:7127`. The detector accepts interface 04 for mode 40 and interface 06 for mode 41. If the modem exposes another layout, open an issue with `lsusb -t` and the `/sys/class/tty/<device>/device` path.

## Downstream router has no Internet

Connect the NanoPi RJ45 to the downstream router's WAN/Internet port and configure that port for DHCP. Confirm that it received an address from `192.168.77.100–149`, gateway/DNS `192.168.77.1`, and that `ifstatus cellular` is up. The downstream LAN cannot also use `192.168.77.0/24`; change it to a different subnet such as `192.168.1.0/24`.

## Automated build failed

Open the issue created by the release workflow and follow its Actions run link. Frequent causes are an upstream manifest rename, a package change incompatible with the newest FriendlyWrt line, less than 35 GB available after runner cleanup, or a stage exceeding six hours.

The workflow never publishes an image after a failed build. Incomplete draft releases are removed automatically.
