# Build and release architecture

## Source model

The repository contains only customization and orchestration code. It does not vendor FriendlyWrt, the Linux kernel, U-Boot, modemfeed or generated images.

`scripts/discover-upstream.sh` selects the latest FriendlyWrt `master-v*` branch (or an explicitly requested version), reads `rk3528.xml`, resolves every project ref with `git ls-remote`, and writes `source-lock.json`. The lock also contains exact commits for:

- `koshev-msk/modemfeed`;
- `friendlyarm/build-env-on-ubuntu-bionic`;
- the official Gerrit `git-repo` mirror.

## Firmware identity versus build provenance

`source-lock.json` deliberately contains two different hashes.

### `fingerprint` — firmware release identity

This is the only hash used to decide whether a new candidate release is needed. It includes only effective inputs that can define a different firmware source/recipe:

- FriendlyWrt version;
- the exact resolved commit of every project in `rk3528.xml` that is assembled for the board;
- the exact `modemfeed` commit whose FM350 packages are copied into the build;
- a hash of the local firmware recipe/customization: `config/07-fm350`, `overlay/`, `targets/rk3528_fm350.mk`, `apply-customizations.sh`, `build-rootfs.sh`, `build-image.sh` and `sync-sources.sh`.

Changing a project commit, modemfeed commit or one of those local firmware inputs creates a different firmware fingerprint and therefore a new candidate.

### `provenance_fingerprint` — audit trail

This records broader build machinery, including the manifest repository commit, host build environment, `git-repo`, workflows, validators and other orchestration files. It makes a build auditable but **does not create a new firmware version by itself**.

This separation prevents release spam. For example, changing another file in the FriendlyWrt manifests repository can move the repository HEAD while leaving `rk3528.xml` and all resolved board-project commits unchanged. Likewise an Actions workflow or host-tool update may change how CI is operated without changing the firmware source/recipe. Those changes remain visible in provenance, but the candidate workflow sees the same firmware fingerprint and skips the multi-hour build/release.

`generated_at` is never part of either identity.

## Why build success is not boot success

GitHub Actions can compile U-Boot, kernel, rootfs and an SD image and can validate checksums and partition structure. It cannot physically power a NanoPi NEO3 Plus, observe its LEDs, verify Ethernet link or prove that the FM350 registers. The release system therefore has two explicit stages.

## Automated candidate workflow

`.github/workflows/release.yml` creates only `candidate-*` prereleases.

1. Resolve effective firmware inputs and the broader build provenance.
2. Compute the firmware fingerprint and candidate tag.
3. Skip when a candidate with the same firmware identity already exists, even if provenance changed.
4. Compile FriendlyWrt rootfs in one Ubuntu 22.04 job only when a real firmware identity change exists.
5. Keep rootfs and host package manager temporarily in a draft candidate.
6. Build U-Boot, kernel and the bootable SD image in a second job.
7. Validate gzip integrity.
8. Verify minimum raw/compressed size and partition-table structure.
9. Verify that the first MiB is not entirely zero.
10. Generate SHA-256 for the compressed image, raw image and source lock.
11. Publish as a GitHub prerelease, never as `latest`.
12. Download the published assets again and re-run checksum/gzip verification.
13. On failure, remove an incomplete draft and create/update an automated failure issue.

If a newer source/recipe state reaches `main` while an older candidate is still compiling, Actions cancels the stale candidate workflow rather than publishing a superseded build.

Public candidate builds intentionally do not inject `ROOT_PASSWORD_HASH` or `AUTHORIZED_KEYS`. The shared image therefore cannot accidentally contain one repository-wide password or a personal key.

The two compilation jobs remain split because complete FriendlyELEC builds are large and public runners have finite storage/runtime.

## Hardware-verified promotion

`.github/workflows/promote-hardware-verified.yml` is manual and works only from an exact `candidate-*` release.

The workflow requires explicit confirmation of all of the following before it runs:

- physical NanoPi NEO3 Plus boot;
- RJ45 maintenance/DHCP path;
- FM350 detection and mobile registration;
- Internet traffic through the cellular WAN;
- clean reboot.

It then:

1. verifies the source release is a prerelease;
2. downloads all candidate assets;
3. re-verifies SHA-256 and gzip integrity;
4. creates `HARDWARE_VALIDATION.md` with tester, timestamp, checksums and validation notes;
5. hashes the validation record itself;
6. creates the non-candidate stable release and marks it `latest`.

This promotion does not rebuild the firmware. Stable receives the exact `.img.gz`, `SHA256SUMS`, `RAW_IMAGE_SHA256` and `source-lock.json` that were physically tested.

See [HARDWARE_VALIDATION.md](HARDWARE_VALIDATION.md).

## Release history

Pre-policy automated releases and tags are archived in [RELEASE_HISTORY.md](RELEASE_HISTORY.md). The active Releases page is reserved for current `candidate-*` builds and hardware-verified stable promotions.

## Local build

Use a clean x86-64 Ubuntu 22.04 host with at least 50 GB free, 16 GB RAM recommended, working `sudo`, and unrestricted access to GitHub. The dependency installer changes the host by installing FriendlyELEC's build packages; a disposable VM is recommended.

```bash
git clone https://github.com/msaulohenrique/nanopi-fm350-manager.git
cd nanopi-fm350-manager

./scripts/discover-upstream.sh source-lock.json
./scripts/install-build-env.sh source-lock.json
./scripts/install-repo-tool.sh source-lock.json
export PATH="$HOME/.local/bin:$PATH"

./scripts/sync-sources.sh source-lock.json work all
./scripts/build-rootfs.sh source-lock.json work artifacts

version=$(./scripts/lock-query.py source-lock.json get friendlywrt_version)
./scripts/build-image.sh source-lock.json work \
  "artifacts/rootfs-friendlywrt-${version}.tar.gz" \
  "artifacts/host-pm-friendlywrt-${version}.tar.gz" artifacts
```

To build a particular upstream line:

```bash
FRIENDLYWRT_VERSION_OVERRIDE=25.12 \
  ./scripts/discover-upstream.sh source-lock.json
```

## Optional credentials for trusted private builds

Public automated releases do not inject credentials. Trusted local/private builds can export:

- `AUTHORIZED_KEYS`: one or more complete OpenSSH public-key lines;
- `ROOT_PASSWORD_HASH`: SHA-256 (`$5$`), SHA-512 (`$6$`) or yescrypt (`$y$`) `crypt(3)` hash.

If no root hash is supplied, the customization clears the inherited vendor password so first boot follows OpenWrt's normal empty-password onboarding in LuCI. SSH password authentication remains disabled by default.

A password hash embedded in any image can be extracted and attacked offline. Use only a strong, unique value. Never add `authorized_keys` or `root-password.hash` to Git.

## Updating behavior

- Effective upstream firmware-source changes are checked daily.
- A new candidate is built only when the firmware fingerprint changes.
- Provenance-only changes can run the lightweight prepare check but do not publish another candidate.
- Firmware recipe changes under the effective customization paths trigger a new candidate after reaching `main`.
- Dependabot can update pinned GitHub Actions without creating a firmware release when firmware inputs are unchanged.
- A manual candidate run can select a FriendlyWrt version or explicitly force another candidate.
- Stable promotion is always an explicit separate action after physical validation.

Scheduled workflows run only from the default branch. GitHub may disable schedules in public repositories after long inactivity, so check the Actions page if no daily run appears.
