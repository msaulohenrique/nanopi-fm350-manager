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

customization_sha256=$(
	cd "$REPO_ROOT"
	git ls-files -s -- \
		.github/workflows/release.yml config overlay scripts targets |
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
	--resource "modemfeed|$MODEMFEED_REPOSITORY|$MODEMFEED_REF" \
	--resource "build_env|$BUILD_ENV_REPOSITORY|$BUILD_ENV_REF" \
	--resource "repo_tool|$REPO_TOOL_REPOSITORY|$REPO_TOOL_REF" \
	--output "$output"

fingerprint=$(python3 "$SCRIPT_DIR/lock-query.py" "$output" get fingerprint)
tag="friendlywrt-${version}-${fingerprint:0:12}"

echo "FriendlyWrt: $version"
echo "Source fingerprint: $fingerprint"
echo "Release tag: $tag"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
	{
		echo "version=$version"
		echo "manifest_branch=$manifest_branch"
		echo "fingerprint=$fingerprint"
		echo "tag=$tag"
		echo "lock_b64=$(base64 -w0 "$output")"
	} >>"$GITHUB_OUTPUT"
fi
