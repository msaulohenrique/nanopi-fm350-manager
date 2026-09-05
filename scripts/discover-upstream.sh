#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
# shellcheck disable=SC1091
source "$REPO_ROOT/config/build.env"

output=${1:-$REPO_ROOT/source-lock.json}
requested_version=${FRIENDLYWRT_VERSION_OVERRIDE:-$FRIENDLYWRT_VERSION}
temp_dir=$(mktemp -d)
trap 'rm -rf -- "$temp_dir"' EXIT

if [[ "$requested_version" == "latest" ]]; then
	mapfile -t candidate_branches < <(
		git ls-remote --heads "$FRIENDLYWRT_MANIFEST_REPOSITORY" 'refs/heads/master-v*' |
			awk '{sub("refs/heads/", "", $2); print $2}' |
			grep -E '^master-v[0-9]+([.][0-9]+)*$' |
			sort -Vr
	)
	((${#candidate_branches[@]} > 0)) || {
		echo "No FriendlyWrt version branch was found" >&2
		exit 1
	}
else
	candidate_branches=("master-v${requested_version#master-v}")
fi

manifest_branch=
for candidate in "${candidate_branches[@]}"; do
	rm -rf -- "$temp_dir/manifests"
	git clone --quiet --depth=1 --branch "$candidate" \
		"$FRIENDLYWRT_MANIFEST_REPOSITORY" "$temp_dir/manifests"
	if [[ -f "$temp_dir/manifests/$FRIENDLYWRT_MANIFEST" ]]; then
		manifest_branch=$candidate
		break
	fi
done
[[ -n "$manifest_branch" ]] || {
	echo "$FRIENDLYWRT_MANIFEST is missing from every candidate branch" >&2
	exit 1
}
version=${manifest_branch#master-v}
manifest_file="$temp_dir/manifests/$FRIENDLYWRT_MANIFEST"
manifest_commit=$(git -C "$temp_dir/manifests" rev-parse HEAD)

# Release identity must represent effective firmware inputs, not CI metadata.
# These tracked files can change the generated rootfs/image or which source
# projects are assembled. Workflow, validator and host-runner changes are
# recorded below as provenance but deliberately do not create a new release.
customization_sha256=$(
	cd "$REPO_ROOT"
	git ls-files -s -- \
		config/07-fm350 \
		overlay \
		targets/rk3528_fm350.mk \
		scripts/apply-customizations.sh \
		scripts/build-rootfs.sh \
		scripts/build-image.sh \
		scripts/sync-sources.sh |
		sha256sum |
		awk '{print $1}'
)

# Keep a broader audit fingerprint so the exact build machinery remains
# traceable even when it does not alter the firmware release identity.
provenance_sha256=$(
	cd "$REPO_ROOT"
	git ls-files -s -- \
		.github/workflows/release.yml \
		.github/workflows/promote-hardware-verified.yml \
		config overlay scripts targets tests |
		sha256sum |
		awk '{print $1}'
)

python3 "$SCRIPT_DIR/resolve-lock.py" \
	--manifest-file "$manifest_file" \
	--manifest-url "$FRIENDLYWRT_MANIFEST_REPOSITORY" \
	--manifest-branch "$manifest_branch" \
	--manifest-commit "$manifest_commit" \
	--project-base-url "$FRIENDLYWRT_PROJECT_BASE_URL" \
	--version "$version" \
	--customization-sha256 "$customization_sha256" \
	--provenance-sha256 "$provenance_sha256" \
	--resource "modemfeed|$MODEMFEED_REPOSITORY|$MODEMFEED_REF" \
	--resource "build_env|$BUILD_ENV_REPOSITORY|$BUILD_ENV_REF" \
	--resource "repo_tool|$REPO_TOOL_REPOSITORY|$REPO_TOOL_REF" \
	--output "$output"

fingerprint=$(python3 "$SCRIPT_DIR/lock-query.py" "$output" get fingerprint)
provenance_fingerprint=$(
	python3 "$SCRIPT_DIR/lock-query.py" "$output" get provenance_fingerprint
)
tag="friendlywrt-${version}-${fingerprint:0:12}"

echo "FriendlyWrt: $version"
echo "Firmware fingerprint: $fingerprint"
echo "Build provenance fingerprint: $provenance_fingerprint"
echo "Release tag: $tag"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
	{
		echo "version=$version"
		echo "manifest_branch=$manifest_branch"
		echo "fingerprint=$fingerprint"
		echo "provenance_fingerprint=$provenance_fingerprint"
		echo "tag=$tag"
		echo "lock_b64=$(base64 -w0 "$output")"
	} >>"$GITHUB_OUTPUT"
fi
