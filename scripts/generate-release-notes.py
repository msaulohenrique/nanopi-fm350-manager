#!/usr/bin/env python3
"""Generate compact multilingual notes from an exact source lock."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("lock")
    parser.add_argument("--image", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    data = json.loads(Path(args.lock).read_text(encoding="utf-8"))
    version = data["friendlywrt_version"]
    fingerprint = data["fingerprint"]
    provenance = data.get("provenance_fingerprint", "legacy")

    notes = f"""## English

Automated FriendlyWrt {version} image for NanoPi NEO3 Plus with Fibocom FM350-GL, APN `surf.br`, cellular WAN, and a DHCP/NAT RJ45 for the downstream router and maintenance at `192.168.77.1/24`.

Flash `{args.image}` directly with Raspberry Pi Imager or balenaEtcher. Verify it with `SHA256SUMS`. Exact upstream commits are in `source-lock.json`. Firmware identity: `{fingerprint}`. Build provenance: `{provenance}`.

A new candidate is created only when an effective firmware input changes: a resolved FriendlyWrt project commit, the modemfeed commit, or the local firmware recipe/customization. CI workflow, manifest-repository HEAD and host build-tool changes remain recorded as provenance but do not create a new firmware version by themselves.

## Português (Brasil)

Imagem automática do FriendlyWrt {version} para NanoPi NEO3 Plus com Fibocom FM350-GL, APN `surf.br`, WAN celular e RJ45 com DHCP/NAT para o roteador e manutenção em `192.168.77.1/24`.

Grave `{args.image}` diretamente com Raspberry Pi Imager ou balenaEtcher e confira `SHA256SUMS`. Os commits exatos estão em `source-lock.json`. Identidade do firmware: `{fingerprint}`. Proveniência do build: `{provenance}`.

Uma nova candidata só é criada quando muda um input efetivo do firmware: commit resolvido de um projeto FriendlyWrt, commit do modemfeed ou receita/customização local do firmware. Alterações no workflow de CI, no HEAD geral do repositório de manifests e nas ferramentas do host continuam registradas como proveniência, mas não criam uma nova versão do firmware sozinhas.

## Español

Imagen automática de FriendlyWrt {version} para NanoPi NEO3 Plus con Fibocom FM350-GL, APN `surf.br`, WAN celular y RJ45 con DHCP/NAT para el router y mantenimiento en `192.168.77.1/24`.

Grabe `{args.image}` directamente con Raspberry Pi Imager o balenaEtcher y verifique `SHA256SUMS`. Los commits exactos están en `source-lock.json`. Identidad del firmware: `{fingerprint}`. Procedencia del build: `{provenance}`.

## 简体中文

这是适用于 NanoPi NEO3 Plus 和 Fibocom FM350-GL 的 FriendlyWrt {version} 自动构建镜像。默认 APN 为 `surf.br`，蜂窝接口作为 WAN，RJ45 通过 DHCP/NAT 为下游路由器提供网络，并可在 `192.168.77.1/24` 维护。

请使用 Raspberry Pi Imager 或 balenaEtcher 直接写入 `{args.image}`，并用 `SHA256SUMS` 校验。精确的上游提交记录在 `source-lock.json` 中。固件标识：`{fingerprint}`。构建溯源：`{provenance}`。

## Français

Image FriendlyWrt {version} automatisée pour NanoPi NEO3 Plus avec Fibocom FM350-GL, APN `surf.br`, WAN cellulaire et RJ45 DHCP/NAT pour le routeur en aval et la maintenance sur `192.168.77.1/24`.

Flashez directement `{args.image}` avec Raspberry Pi Imager ou balenaEtcher et vérifiez `SHA256SUMS`. Les commits amont exacts figurent dans `source-lock.json`. Identité du firmware : `{fingerprint}`. Provenance du build : `{provenance}`.
"""
    Path(args.output).write_text(notes, encoding="utf-8")


if __name__ == "__main__":
    main()
