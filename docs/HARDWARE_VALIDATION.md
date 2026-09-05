# Hardware validation policy

Automated CI can prove that the source tree is internally consistent, the upstream commits are pinned, the firmware compiles, the compressed image is valid and the resulting SD image has a plausible partition structure. It cannot prove that a physical NanoPi NEO3 Plus actually boots.

For that reason this project has two release classes.

## Candidate

Tags start with `candidate-`.

Candidates are created automatically after:

- repository validation and unit tests;
- exact upstream source locking;
- U-Boot, kernel and FriendlyWrt build completion;
- gzip integrity validation;
- SHA-256 generation and re-download verification;
- raw-image minimum-size checks;
- partition-table structural checks.

A candidate is **not stable firmware** and must not be described as hardware-tested unless someone has completed the physical checklist below.

## Hardware-verified stable release

A stable release is promoted manually from one exact candidate. The promotion workflow refuses to continue unless every required physical check is confirmed.

### Required physical checklist

- [ ] The exact candidate `.img.gz` was verified with `SHA256SUMS` before flashing.
- [ ] The image was written to a known-good microSD.
- [ ] The NanoPi NEO3 Plus completed boot without hanging.
- [ ] `sys_led` heartbeat became active.
- [ ] RJ45 link came up.
- [ ] A maintenance client obtained DHCP in `192.168.77.0/24`.
- [ ] LuCI opened at `https://192.168.77.1/`.
- [ ] First-boot administrator password setup was completed.
- [ ] The FM350-GL was detected on a supported USB layout.
- [ ] The modem registered on the mobile network.
- [ ] The cellular interface received IPv4 addressing/DNS.
- [ ] Internet traffic passed from the RJ45 client through the FM350 WAN.
- [ ] FM350 telemetry returned plausible RSSI/RSRP/RSRQ and, on NR, SINR.
- [ ] At least one clean reboot completed successfully.

### Validation record

The promotion workflow creates `HARDWARE_VALIDATION.md` and its SHA-256 as release assets. The record includes the source candidate, tester, validation timestamp, image checksums and free-form notes about the hardware, power supply, microSD, modem firmware/operator and any anomalies.

If a candidate hangs during boot, do not promote it. Open an issue with the candidate tag, image SHA-256, microSD model, power supply, LED state and—when available—UART/U-Boot/kernel logs.
