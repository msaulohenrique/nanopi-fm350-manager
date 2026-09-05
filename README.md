# NanoPi NEO3 Plus · FriendlyWrt + Fibocom FM350-GL

[Português (Brasil)](docs/README.pt-BR.md) · [Español](docs/README.es.md) · [简体中文](docs/README.zh-CN.md) · [Français](docs/README.fr.md)

[![Validate](https://github.com/msaulohenrique/nanopi-fm350-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/msaulohenrique/nanopi-fm350-manager/actions/workflows/ci.yml)
[![Build candidate](https://github.com/msaulohenrique/nanopi-fm350-manager/actions/workflows/release.yml/badge.svg)](https://github.com/msaulohenrique/nanopi-fm350-manager/actions/workflows/release.yml)

Reproducible FriendlyWrt firmware for the NanoPi NEO3 Plus and Fibocom FM350-GL 5G modem. The default mobile profile uses the Brazilian APN `surf.br`. Every upstream source is resolved to an exact commit and recorded beside the image.

The NanoPi is intentionally a **standalone cellular gateway**: the FM350 is the Internet WAN and the single RJ45 provides a routed DHCP/NAT maintenance/downstream network. Multi-link bonding such as RatoNet/SRTLA belongs on the downstream encoder/router, not inside this firmware.

## What is preconfigured

- FM350-GL USB modes `0e8d:7126` and `0e8d:7127`, with automatic AT-port discovery.
- `xmm-modem` and `luci-proto-xmm` from [modemfeed](https://github.com/koshev-msk/modemfeed).
- IPv4 cellular connection through `surf.br`, metric 10.
- FM350 as the Internet WAN with IPv4 masquerading.
- RJ45 as DHCP LAN/maintenance, gateway `192.168.77.1/24`.
- LuCI, DNS and cellular forwarding through the same RJ45.
- Multilingual **Network → FM350 Manager** panel for APN/SIM configuration, SMS, bands, traffic and radio analytics.
- Explicit LTE/NR telemetry: RSSI, RSRP, RSRQ and NR SINR when reported by the modem, plus TAC, Cell ID, RAT, operator and bands.
- Token-protected JSON telemetry API for RatoNet and other external monitoring systems.
- `sys_led` heartbeat and `user_led` FM350 link/RX/TX activity.
- First-boot security model without a shared public administrator password.

## Security-first first boot

Public automated images do **not** embed one shared root password or personal SSH key. When no password hash is injected in a trusted private build, the firmware clears the FriendlyWrt vendor password and follows OpenWrt's normal first-login model.

1. Connect the NanoPi RJ45 only to a trusted computer or downstream router.
2. Open `https://192.168.77.1/`.
3. Sign in as `root` with an empty password on the first login.
4. Immediately set a strong, unique password in **System → Administration**.
5. SSH password authentication is disabled by default. Use an injected `AUTHORIZED_KEYS` key or explicitly enable password SSH later if required.

Do not expose an unconfigured first-boot device to an untrusted Ethernet segment. See [SECURITY.md](SECURITY.md).

## Download and flash

There are two release classes:

- **Hardware-verified stable** — physically validated on a NanoPi NEO3 Plus for boot, RJ45, FM350 registration, cellular Internet and reboot. Prefer this for permanent deployments.
- **Candidate** — tag starts with `candidate-`; built and structurally checked by CI but not yet proven to boot on physical hardware.

For either class:

1. Download the `.img.gz`, `SHA256SUMS` and `source-lock.json` from Releases.
2. Verify the checksum before flashing.
3. Write the compressed image directly with Raspberry Pi Imager or balenaEtcher.
4. Insert the microSD, connect the externally powered FM350 adapter and power on the NanoPi.

Stable releases additionally contain `HARDWARE_VALIDATION.md` and `HARDWARE_VALIDATION_SHA256`. See [hardware validation policy](docs/HARDWARE_VALIDATION.md).

The SIM must be active. If it requires a PIN, configure it in LuCI before bringing up the cellular interface.

## Connect the downstream router

| Connection | Client configuration | NanoPi address | Behavior |
| --- | --- | --- | --- |
| Router WAN port | DHCP/automatic | `192.168.77.1` | Receives `192.168.77.100–149`, DNS and cellular Internet |
| Direct maintenance computer | DHCP/automatic, or static `192.168.77.2/24` | `192.168.77.1` | LuCI and cellular Internet through the same cable |

Connect the NanoPi RJ45 to the downstream router's **WAN/Internet** port and leave that port in DHCP/automatic mode. The downstream router LAN must use another subnet, for example `192.168.1.0/24`.

This routed topology adds one NAT hop. It is intentional: the project prioritizes stable FM350 RNDIS/XMM operation over fragile transparent-bridge tricks. Mobile carriers commonly add CGNAT upstream as well.

## FM350 telemetry API

Open **Network → FM350 Manager → Telemetry API** in LuCI. The page shows live radio metrics, the endpoint and the unique per-device API key. You can enable/disable the API or rotate the token.

Endpoint:

```text
https://192.168.77.1/cgi-bin/fm350-telemetry
```

Example:

```bash
curl -k \
  -H 'X-API-Key: YOUR_DEVICE_TOKEN' \
  'https://192.168.77.1/cgi-bin/fm350-telemetry'
```

The API distinguishes the Linux transport from the upstream network:

```json
{
  "upstream_type": "cellular",
  "physical_transport": "ethernet",
  "connection": {
    "technology": "5G NSA (LTE-NR EN-DC)"
  },
  "signal": {
    "rssi_dbm": "-65",
    "rsrp_dbm": "-89",
    "rsrq_db": "-10.0",
    "sinr_db": "22.0"
  }
}
```

This is important for systems such as RatoNet: the encoder should still bind traffic to its real Ethernet interface, while the API enriches that link with modem/operator/RAT/signal data. See [RatoNet integration](docs/RATONET.md).

The telemetry endpoint never returns the SIM PIN, APN username or APN password.

## LuCI modem panel and LEDs

The main **Network → FM350 Manager** page reports SIM state, operator, RAT, registration, signal, AT/data interfaces, IP, gateway, DNS and uptime. Its analytics show signal/traffic history, carrier bands/channels/PCI/bandwidth, enabled bands and supported bands.

The complete cellular form manages APN, PDP type, CID/profile, SIM PIN, PAP/CHAP mode, username and password. Stored secrets are not returned to the browser status API. SMS controls list modem/SIM storage, decode UCS-2 messages, send standard SMS and delete selected messages.

| LED | Configuration | Meaning |
| --- | --- | --- |
| `sys_led` | `heartbeat` | Operating system is alive |
| `user_led` | `netdev` on `eth1`, modes `link tx rx` | Cellular link/activity |

The physical GPIO user button (`BTN_1`) performs a safe reboot when released. The separate **MASK** button retains its original boot/recovery purpose.

## Release automation

The project deliberately separates **build success** from **hardware success**.

### Automated candidate workflow

On relevant changes, manual dispatch and the daily schedule, GitHub Actions:

1. resolves exact FriendlyWrt/manifests/kernel/U-Boot/toolchain/modemfeed/build-tool commits;
2. records them in `source-lock.json`;
3. runs repository, shell, JSON, JavaScript and unit validations;
4. compiles rootfs, U-Boot, kernel and SD image;
5. checks gzip integrity, image size, partition-table structure and non-zero boot area;
6. generates SHA-256 files;
7. publishes a `candidate-*` prerelease;
8. downloads the published assets again and re-verifies their checksums.

A green candidate workflow therefore means **built and structurally validated**, not **physical boot proven**.

### Hardware promotion workflow

Stable promotion is a separate manual workflow. It requires explicit confirmation of:

- physical NanoPi boot;
- RJ45/DHCP maintenance path;
- FM350 detection/registration;
- cellular Internet forwarding;
- clean reboot.

The exact candidate assets are re-downloaded and checksum-verified before the stable release is created. The workflow also emits a hardware validation record as a release asset.

See [build details](docs/BUILD.md) and [hardware validation](docs/HARDWARE_VALIDATION.md).

## Build customization

Trusted local/private builds may provide:

- `ROOT_PASSWORD_HASH` — SHA-256/SHA-512/yescrypt `crypt(3)` hash for a unique administrator password.
- `AUTHORIZED_KEYS` — SSH public key(s) for key-based recovery.

The public automated workflow intentionally does not inject either value into shared release images.

## Support

For a boot failure, include the exact candidate/stable tag, `.img.gz` SHA-256, microSD model, power supply, LED state, FM350 USB ID and—when available—UART/U-Boot/kernel logs. For modem failures also include the detected AT port and relevant logs.

This community project is not affiliated with FriendlyELEC, FriendlyARM, Fibocom, RatoNet or any mobile operator. Their components retain their own licenses.
