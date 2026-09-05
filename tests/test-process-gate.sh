#!/bin/bash
set -euo pipefail

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
template="$REPO_ROOT/.github/PULL_REQUEST_TEMPLATE.md"

grep -Fq 'Before implementation started' "$template"
grep -Fq 're-read immediately before merge' "$template"
grep -Fq 'checked for late review findings' "$template"
grep -Fq 'request/reaction alone is not treated as a completed review' "$template"

echo 'PR review process gate checks passed'
