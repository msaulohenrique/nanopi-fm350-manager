# Release history

This file preserves provenance for release/tag entries created before the current two-stage release policy.

## Current policy

The active release model is intentionally small:

1. `candidate-friendlywrt-*` is created automatically after reproducible build and structural validation.
2. `friendlywrt-*` is created only by the hardware-verification promotion workflow from the exact candidate assets that were physically tested.

A successful automated build is not considered a stable/hardware-verified release by itself.

## Legacy generation archived on 5 September 2026

The following pre-policy tags were removed from the active GitHub Tags/Releases listings during repository cleanup:

- `friendlywrt-25.12-00c8dea9afeb`
- `friendlywrt-25.12-0d59ca68ecb0`
- `friendlywrt-25.12-245bfd723eea`
- `friendlywrt-25.12-326f13781cb0`
- `friendlywrt-25.12-b33f44cbbb72`
- `friendlywrt-25.12-b37a164896ae`
- `friendlywrt-25.12-b794b6a1cdd1`
- `friendlywrt-25.12-ba32f08b5120`
- `friendlywrt-25.12-c808c9c34ce2`

All nine Git tags pointed to repository commit:

`c502365091b92ba0768acbfdcb90a89ec665140a`

They represented changing upstream/build fingerprints while the repository commit itself remained the same. Keeping all of them in the active tag list made the project look as though it had nine distinct maintained code releases when it did not.

### `ba32f08b5120`

This was the first successful automated-release lineage recorded by the project. Its original binary assets had previously been deleted; a later GitHub Release entry existed only as a historical metadata record with no assets. That metadata is now preserved here instead of occupying the active Releases page.

### `c808c9c34ce2`

This legacy automated release still had an image and checksum/source-lock assets and was published as a normal non-prerelease under the old workflow. It predates the current rule that a stable release must carry explicit physical validation. It was therefore retired from the active supported release list rather than being presented as a current hardware-verified stable build.

The compressed image asset that GitHub recorded for that legacy release had digest:

`sha256:96f6f4ff9d25c0ad4166fd7568eca5613a5a48011f40118cd097c0644533aa79`

This digest is retained only for historical audit purposes; the legacy binary is not a supported current release.

## Why the old tags were removed

The cleanup does not rewrite Git commit history. It removes obsolete release/tag pointers whose naming semantics conflict with the current release policy and preserves the relevant audit trail in version-controlled documentation.

From this migration forward, the Releases page should communicate only actionable firmware choices: current automated candidates and physically validated stable releases.
