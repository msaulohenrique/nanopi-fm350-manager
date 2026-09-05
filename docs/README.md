# Documentation

This directory contains the maintained documentation for the NanoPi NEO3 Plus + Fibocom FM350-GL FriendlyWrt gateway.

## User guides

- [English overview](../README.md)
- [Português (Brasil)](README.pt-BR.md)
- [Español](README.es.md)
- [简体中文](README.zh-CN.md)
- [Français](README.fr.md)
- [Troubleshooting](TROUBLESHOOTING.md)

## Build, releases and validation

- [Build and release architecture](BUILD.md)
- [Hardware validation policy](HARDWARE_VALIDATION.md)
- [Release history and legacy migration](RELEASE_HISTORY.md)

## Integrations

- [RatoNet integration](RATONET.md)

## Repository policies

- [Security policy](../SECURITY.md)
- [Contributing](../CONTRIBUTING.md)

## Release naming

Only two active release classes are used:

- `candidate-friendlywrt-*`: automated prerelease, build-validated but not yet physically validated;
- `friendlywrt-*`: stable release created only by the hardware-validation promotion workflow from an exact candidate.

Legacy pre-policy releases and tags are not kept in the active Releases/Tags listings. Their provenance is recorded in [RELEASE_HISTORY.md](RELEASE_HISTORY.md).
