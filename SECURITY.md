# Security policy

## Supported versions

Only the latest published image is supported. Upstream FriendlyWrt, kernel and package changes are tracked automatically, but a successful build does not replace device-specific security testing.

## Safe deployment

- Change the initial `root` / `password` credential immediately after first boot.
- Do not expose `192.168.77.0/24` to an untrusted Ethernet segment.
- Root password login is enabled only on the maintenance interface and has full administrative privileges. Use a strong unique password; `AUTHORIZED_KEYS` can add key-based recovery.
- The modem panel intentionally never returns stored SIM PINs, APN usernames or APN passwords to the browser. SMS contents are visible to every authenticated root administrator, so treat LuCI access and backups as sensitive.
- Never commit private keys, personal public keys, password hashes, SIM PINs, APN credentials or flash logs containing identifiers.
- Verify `SHA256SUMS` before flashing and retain `source-lock.json` for incident analysis.
- Back up settings before moving between major FriendlyWrt versions.

Public image assets can be inspected offline. Treat any password hash embedded through `ROOT_PASSWORD_HASH` as exposed to offline guessing and use a strong, unique value.

## Reporting a vulnerability

Do not open a public issue for an unpatched vulnerability or exposed credential. Use GitHub's private vulnerability reporting feature for this repository. Include the affected release tag, source fingerprint, impact and a minimal reproduction. Do not include SIM secrets or private keys.
