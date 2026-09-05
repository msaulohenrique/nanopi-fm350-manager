# Post-merge review remediation

This note records review findings that arrived after their original pull requests had already been merged.

## PR #9

Two Codex findings were submitted after merge:

1. **P1 — netifd/XMM AT concurrency.** The XMM protocol used raw `gcom` calls that did not participate in `/tmp/fm350-at.lock`, so status polling could overlap with connect/reconnect AT sessions.
2. **P2 — GSM text-mode byte mismatches.** `@`, `$` and `_` were accepted even though their ASCII byte positions do not represent the same glyphs in the GSM default alphabet selected by `AT+CSCS="GSM"`.

The remediation routes all six known XMM/netifd `gcom` calls through `/usr/sbin/fm350-gcom-locked`, retains `pidof gcom` as a defense-in-depth guard in status polling, rejects the remaining non-identity GSM bytes, and adds regression coverage.

## PR #10

A P2 review finding noted that the one-time cleanup workflow could not distinguish a confirmed HTTP 404 from an API/authentication failure when probing legacy releases/tags. The migration had already completed successfully and its result was independently verified through the GitHub API before the one-time workflow was removed in PR #11. There is no remaining cleanup workflow to patch; the historical thread is resolved as an obsolete migration implementation issue after verified completion and removal.

## Process rule

Before starting new repository work, review open and recently merged pull-request comments, submitted reviews and unresolved inline threads. Before merging, repeat the review check against the exact final head and require CI to be green.
