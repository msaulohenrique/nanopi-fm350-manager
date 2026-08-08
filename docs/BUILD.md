# Build and release architecture

## Source model

The repository contains only the customization and orchestration code. It does not vendor FriendlyWrt, the Linux kernel, U-Boot, modemfeed or generated images.

`scripts/discover-upstream.sh` selects the latest FriendlyWrt `master-v*` branch (or an explicitly requested version), reads `rk3528.xml`, resolves every project ref with `git ls-remote`, and writes `source-lock.json`. The lock also contains exact commits for:

- [koshev-msk/modemfeed](https://github.com/koshev-msk/modemfeed);
- [friendlyarm/build-env-on-ubuntu-bionic](https://github.com/friendlyarm/build-env-on-ubuntu-bionic);
- [friendlyarm/repo](https://github.com/friendlyarm/repo).

The fingerprint excludes its generation timestamp and includes all build-input blobs from this repository. The same inputs therefore produce the same release tag, while any firmware customization or upstream commit creates a new tag.

## GitHub Actions flow

The release workflow is based on the build stages used by FriendlyELEC's official [Actions-FriendlyWrt](https://github.com/friendlyarm/Actions-FriendlyWrt) repository:

1. Resolve and fingerprint all upstream sources without compiling.
2. Skip if a published release already has that tag.
3. Compile FriendlyWrt rootfs in one Ubuntu 22.04 job.
4. Store rootfs and host package manager temporarily in a draft release.
5. Build U-Boot, kernel and the bootable SD image in a second job.
6. Test gzip integrity and calculate SHA-256 for raw and compressed images.
7. Replace intermediate assets with `.img.gz`, `SHA256SUMS` and `source-lock.json`, then publish the release.
8. On failure, delete an incomplete draft and report the failed workflow in an issue.

The split is intentional. A complete local build used approximately 34 GB; standard public GitHub-hosted Linux runners provide 14 GB initially and have a six-hour job limit. The workflow removes unrelated preinstalled SDKs from the ephemeral runner, checks for at least 35 GB free and keeps each compilation stage below the job limit. See GitHub's [hosted-runner reference](https://docs.github.com/en/actions/reference/runners/github-hosted-runners).

## Local build

Use a clean x86-64 Ubuntu 22.04 host with at least 50 GB free, 16 GB RAM recommended, working `sudo`, and unrestricted access to GitHub. The dependency installer changes the host by installing FriendlyELEC's build packages; use a disposable VM if possible.

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

## Optional credentials

Generic public releases deliberately do not contain a personal SSH key. The upstream FriendlyWrt LuCI password remains in place unless a crypt(3) hash is supplied. For repository-owned releases, create Actions secrets:

- `AUTHORIZED_KEYS`: one or more complete OpenSSH public-key lines;
- `ROOT_PASSWORD_HASH`: a SHA-256 (`$5$`), SHA-512 (`$6$`) or yescrypt (`$y$`) crypt hash.

The secrets are applied only in the image job and are not printed. Remember that a password hash embedded in a public image can be extracted and attacked offline; use a strong unique password and rotate it after flashing.

For a local build, export the same variables before `build-image.sh`. Never add `authorized_keys` or `root-password.hash` to Git.

## Updating behavior

- Upstream source changes are detected daily.
- Recipe changes under `config/`, `overlay/`, `scripts/`, `targets/` or the release workflow trigger a build after reaching `main`.
- Dependabot proposes pinned GitHub Action updates weekly.
- A manual run can select a version or force an additional release.

Scheduled workflows run only from the default branch. GitHub may disable schedules in public repositories after long inactivity, so check the Actions page if no daily run appears.
