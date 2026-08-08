# Contributing

Keep changes reproducible, reviewable and safe for a router connected to hostile networks.

1. Create a branch and make the smallest focused change.
2. Run `./scripts/validate-repository.sh` on Linux.
3. Do not commit generated images, source checkouts, credentials or hardware inventory logs.
4. Explain changes to firewall zones, routes, authentication or modem commands in the pull request.
5. Preserve all language links when changing user-visible behavior; update translations in the same pull request when practical.

GitHub Actions dependencies must use a full 40-character commit SHA with a version comment. Upstream firmware sources belong in the generated lock rather than as unreviewed floating downloads inside build steps.
