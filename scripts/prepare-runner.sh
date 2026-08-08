#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
# shellcheck disable=SC1091
source "$REPO_ROOT/config/build.env"

if [[ "${GITHUB_ACTIONS:-false}" == "true" ]]; then
	# These are preinstalled SDKs on an ephemeral GitHub-hosted runner. They are
	# unrelated to FriendlyWrt and are the same paths removed by FriendlyELEC's
	# official Actions build.
	sudo swapoff -a || true
	for directory in \
		/usr/share/dotnet \
		/usr/local/lib/android/sdk \
		/usr/local/share/boost \
		/opt/ghc; do
		[[ -e "$directory" ]] && sudo rm -rf -- "$directory"
	done
fi

df -h /
free_gb=$(df --output=avail -BG / | tail -n1 | tr -dc '0-9')
if ((free_gb < MIN_FREE_DISK_GB)); then
	echo "At least ${MIN_FREE_DISK_GB} GB free are required; found ${free_gb} GB" >&2
	exit 1
fi
