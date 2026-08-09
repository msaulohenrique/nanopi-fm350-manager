# NanoPi NEO3 Plus · FriendlyWrt + Fibocom FM350-GL

[Português (Brasil)](docs/README.pt-BR.md) · [Español](docs/README.es.md) · [简体中文](docs/README.zh-CN.md) · [Français](docs/README.fr.md)

[![Validate](https://github.com/msaulohenrique/nanopi-fm350-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/msaulohenrique/nanopi-fm350-manager/actions/workflows/ci.yml)
[![Build and release](https://github.com/msaulohenrique/nanopi-fm350-manager/actions/workflows/release.yml/badge.svg)](https://github.com/msaulohenrique/nanopi-fm350-manager/actions/workflows/release.yml)

Ready-to-flash, reproducible FriendlyWrt images for the NanoPi NEO3 Plus and Fibocom FM350-GL 5G modem. The default mobile profile uses the Brazilian APN `surf.br`. Every upstream source is resolved to an exact commit and recorded beside the image.

## What is preconfigured

- FM350-GL USB modes `0e8d:7126` and `0e8d:7127`, with automatic AT-port discovery.
- `xmm-modem` and `luci-proto-xmm` from [modemfeed](https://github.com/koshev-msk/modemfeed).
- IPv4 cellular connection through `surf.br`, metric 10 (preferred route).
- The FM350 cellular interface as the Internet WAN, with IPv4 masquerading.
- The only RJ45 as a DHCP LAN for the downstream router, gateway `192.168.77.1/24`.
- LuCI, SSH, DNS and cellular forwarding available through the same RJ45.
- Multilingual **Network → FM350 Manager** panel for live status, complete APN/SIM configuration, SMS, radio analytics and connection controls.
- System heartbeat on `sys_led`; FM350 link and RX/TX activity on `user_led`.
- Full root access through LuCI and SSH on the maintenance interface.

## Download and flash

1. Download the latest `.img.gz` and `SHA256SUMS` from [Releases](https://github.com/msaulohenrique/nanopi-fm350-manager/releases).
2. Verify the checksum.
3. Write the compressed image directly with [Raspberry Pi Imager](https://www.raspberrypi.com/software/) or balenaEtcher.
4. Insert the microSD, connect the FM350-GL and power on the NanoPi. The first boot may take several minutes while partitions are prepared.

The SIM must be active and must not require a PIN. If it does, set the PIN in LuCI before bringing up the cellular interface.

## Connect the downstream router

| Connection | Client configuration | NanoPi address | Behavior |
| --- | --- | --- | --- |
| Router WAN port | DHCP/automatic | `192.168.77.1` | Receives an address from `192.168.77.100–149`, DNS and cellular Internet |
| Direct maintenance computer | DHCP/automatic, or static `192.168.77.2/24` | `192.168.77.1` | LuCI, SSH and cellular Internet through the same cable |

Connect the NanoPi RJ45 to the downstream router's **WAN/Internet** port and leave that port in DHCP/automatic mode. For maintenance, open `https://192.168.77.1/` from the downstream LAN or connect a computer directly. The certificate is locally generated, so the browser may show a warning on first access. The downstream router's LAN must use a different subnet, such as `192.168.1.0/24`.

Unless the repository owner configures `ROOT_PASSWORD_HASH`, the image keeps FriendlyWrt's initial credentials: user `root`, password `password`. They provide full administrative access in both LuCI and SSH through the RJ45 LAN. Change this public default immediately on any permanent deployment. `AUTHORIZED_KEYS` optionally adds key-based SSH recovery.

## LuCI modem panel and LEDs

After signing in, open **Network → FM350 Manager**. The panel reports SIM state, operator, technology, RAT, registration, signal, AT/data interfaces, IP, gateway, DNS and uptime. Its analytics show signal and traffic history, current carrier bands/channels/PCI/bandwidth, enabled bands and every 3G/4G/5G band supported by the modem. On this T700 driver, inbound cellular bytes may be reported through the forwarded RJ45 counter because `eth1` RX remains at zero.

The complete cellular form manages APN, PDP type, CID/profile, SIM PIN, PAP/CHAP mode, username and password. Saved PINs and passwords are never returned to the browser: blank secret fields preserve them, and a separate checkbox explicitly removes the SIM PIN. SMS controls can list the modem or SIM-card storage, decode UCS-2 received messages, send standard text messages of up to 160 bytes, and delete a selected message.

The interface uses progressive disclosure: common actions, APN, signal quality, charts and SMS stay visible, while band matrices and credential/CID options are collapsed under advanced sections. Buttons and credential fields enable only when their current state makes the action valid.

| LED | Configuration | Meaning |
| --- | --- | --- |
| `sys_led` | `heartbeat` | The operating system is alive. |
| `user_led` | `netdev` on `eth1`, modes `link tx rx` | Cellular link is active; flashes on modem traffic. |

The physical GPIO user button (`BTN_1`) performs a safe reboot when released. The separate **MASK** button keeps its original boot/recovery purpose and must not be used for routine rebooting.

## Automatic releases

GitHub Actions checks once per day and on every relevant change to `main`. It follows the newest `master-v*` FriendlyWrt manifest, resolves all manifest projects plus modemfeed and FriendlyELEC build tools, and skips the build when that complete fingerprint already has a published release.

A release contains:

- the bootable `.img.gz`;
- `SHA256SUMS` for published files and `RAW_IMAGE_SHA256` for the decompressed image;
- `source-lock.json` with every exact upstream commit.

See [build and automation details](docs/BUILD.md). The first validated local build used FriendlyWrt 25.12 on 2026-08-08; its raw image SHA-256 was `7ee7a8cb836fd61eaf71fa34795067f63bc0a99289cceade07ddf9c04ad1ca18`.

## Security and support

Do not expose the maintenance subnet to an untrusted Ethernet segment. Read [SECURITY.md](SECURITY.md) before publishing a customized image. For failures, include the release tag, `source-lock.json`, modem USB ID, detected AT port and relevant logs in an issue.

This community project is not affiliated with FriendlyELEC, FriendlyARM, Fibocom or the mobile operator. Their components retain their own licenses.
