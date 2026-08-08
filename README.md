# NanoPi NEO3 Plus · FriendlyWrt + Fibocom FM350-GL

[Português (Brasil)](docs/README.pt-BR.md) · [Español](docs/README.es.md) · [简体中文](docs/README.zh-CN.md) · [Français](docs/README.fr.md)

[![Validate](https://github.com/msaulohenrique/nanopi-fm350-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/msaulohenrique/nanopi-fm350-manager/actions/workflows/ci.yml)
[![Build and release](https://github.com/msaulohenrique/nanopi-fm350-manager/actions/workflows/release.yml/badge.svg)](https://github.com/msaulohenrique/nanopi-fm350-manager/actions/workflows/release.yml)

Ready-to-flash, reproducible FriendlyWrt images for the NanoPi NEO3 Plus and Fibocom FM350-GL 5G modem. The default mobile profile uses the Brazilian APN `surf.br`. Every upstream source is resolved to an exact commit and recorded beside the image.

## What is preconfigured

- FM350-GL USB modes `0e8d:7126` and `0e8d:7127`, with automatic AT-port discovery.
- `xmm-modem` and `luci-proto-xmm` from [modemfeed](https://github.com/koshev-msk/modemfeed).
- IPv4 cellular connection through `surf.br`, metric 10 (preferred route).
- The only RJ45 as DHCP WAN, metric 20 (fallback route).
- The same RJ45 as a DHCP-free maintenance interface at `192.168.77.1/24`.
- LuCI, SSH, DNS and cellular forwarding restricted to the maintenance client `192.168.77.2`.
- SSH password authentication disabled.

## Download and flash

1. Download the latest `.img.gz` and `SHA256SUMS` from [Releases](https://github.com/msaulohenrique/nanopi-fm350-manager/releases).
2. Verify the checksum.
3. Write the compressed image directly with [Raspberry Pi Imager](https://www.raspberrypi.com/software/) or balenaEtcher.
4. Insert the microSD, connect the FM350-GL and power on the NanoPi. The first boot may take several minutes while partitions are prepared.

The SIM must be active and must not require a PIN. If it does, set the PIN in LuCI before bringing up the cellular interface.

## One RJ45, two purposes

| Purpose | Client configuration | NanoPi address | Behavior |
| --- | --- | --- | --- |
| Normal WAN | DHCP | Assigned by the upstream router | Internet fallback, metric 20 |
| Direct maintenance | Static `192.168.77.2/24`; gateway/DNS `192.168.77.1` | `192.168.77.1` | LuCI and routed cellular access; no DHCP server |

For maintenance, open `https://192.168.77.1/`. The certificate is locally generated, so the browser may show a warning on first access.

Unless the repository owner configures `ROOT_PASSWORD_HASH`, the image keeps FriendlyWrt's upstream initial LuCI credentials (`root` / `password`). Change the password immediately. SSH works only when the release was built with the `AUTHORIZED_KEYS` Actions secret.

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
