# Security policy

## Supported versions

Only the latest published image is supported. Upstream FriendlyWrt, kernel and package changes are tracked automatically, but a successful build does not replace device-specific security testing.

## Safe deployment

- Change the initial LuCI password immediately after first boot.
- Do not expose `192.168.77.0/24` to an untrusted Ethernet segment.
- SSH password authentication is disabled. Use the `AUTHORIZED_KEYS` build secret when SSH is required.
- Never commit private keys, personal public keys, password hashes, SIM PINs, APN credentials or flash logs containing identifiers.
- Verify `SHA256SUMS` before flashing and retain `source-lock.json` for incident analysis.
- Back up settings before moving between major FriendlyWrt versions.

Public image assets can be inspected offline. Treat any password hash embedded through `ROOT_PASSWORD_HASH` as exposed to offline guessing and use a strong, unique value.

## Reporting a vulnerability

Do not open a public issue for an unpatched vulnerability or exposed credential. Use GitHub's private vulnerability reporting feature for this repository. Include the affected release tag, source fingerprint, impact and a minimal reproduction. Do not include SIM secrets or private keys.
