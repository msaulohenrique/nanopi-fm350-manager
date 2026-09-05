# Security policy

## Supported versions

Only the latest **hardware-verified stable release** is supported for permanent deployments. Automated candidate images track upstream FriendlyWrt, kernel and package changes, but a successful build is not proof that a candidate boots correctly on a physical NanoPi NEO3 Plus.

## Safe first boot

Public images intentionally do **not** ship with a shared administrator password. When no trusted local `ROOT_PASSWORD_HASH` is injected during a private build, the build clears any vendor default root password and follows the normal OpenWrt first-login model.

1. Connect only through the trusted maintenance network at `192.168.77.0/24`.
2. Open LuCI at `https://192.168.77.1/`.
3. Sign in as `root` with an empty password on first boot.
4. Immediately set a strong, unique root password in **System → Administration**.
5. SSH password authentication stays disabled by default. Prefer an `AUTHORIZED_KEYS` build or explicitly enable SSH password authentication only if you understand the risk.

Never expose a device that has not completed first-boot password setup to an untrusted Ethernet segment.

## Telemetry API

The FM350 telemetry API is available only on the maintenance listener and requires a unique per-device `X-API-Key` token generated from `/dev/urandom` on first boot.

- Manage the token in **Network → FM350 Manager → Telemetry API**.
- Rotate the token after sharing it with an integration that is no longer trusted.
- Disable the API when it is not required.
- Do not publish the token in screenshots, logs, issues or configuration examples.
- The telemetry response intentionally excludes SIM PINs, APN usernames and APN passwords.

## Supply-chain and image verification

- Download stable images from the hardware-verified release when possible.
- Treat releases whose tag starts with `candidate-` as test images, not stable firmware.
- Verify `SHA256SUMS` before flashing.
- Stable releases also include `HARDWARE_VALIDATION.md` and `HARDWARE_VALIDATION_SHA256` describing who confirmed physical boot, Ethernet, modem registration, cellular Internet and reboot.
- Retain `source-lock.json` for incident analysis; it records the exact upstream commits used by the build.
- Public automated builds do not inject repository secrets as shared root passwords or personal SSH keys.

## Sensitive data

The modem panel intentionally never returns stored SIM PINs, APN usernames or APN passwords to the browser status API. SMS contents are visible to authenticated root administrators, so treat LuCI sessions and backups as sensitive.

Never commit private keys, personal public keys, password hashes, SIM PINs, APN credentials, telemetry API tokens or flash logs containing identifiers. A password hash embedded through `ROOT_PASSWORD_HASH` in a private/custom build can be extracted from the image and attacked offline; use a strong, unique value.

## Reporting a vulnerability

Do not open a public issue for an unpatched vulnerability or exposed credential. Use GitHub's private vulnerability reporting feature for this repository. Include the affected release tag, source fingerprint, impact and a minimal reproduction. Do not include SIM secrets, API tokens or private keys.
