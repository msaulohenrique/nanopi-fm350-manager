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

    notes = f"""## English

Automated FriendlyWrt {version} image for NanoPi NEO3 Plus with Fibocom FM350-GL, APN `surf.br`, cellular priority, DHCP fallback WAN and maintenance access on the same RJ45 at `192.168.77.1/24`.

Flash `{args.image}` directly with Raspberry Pi Imager or balenaEtcher. Verify it with `SHA256SUMS`. Exact upstream commits are in `source-lock.json` (fingerprint `{fingerprint}`).

## Português (Brasil)

Imagem automática do FriendlyWrt {version} para NanoPi NEO3 Plus com Fibocom FM350-GL, APN `surf.br`, prioridade para a rede celular, WAN DHCP de contingência e manutenção na mesma RJ45 em `192.168.77.1/24`.

Grave `{args.image}` diretamente com Raspberry Pi Imager ou balenaEtcher e confira `SHA256SUMS`. Os commits exatos estão em `source-lock.json` (impressão `{fingerprint}`).

## Español

Imagen automática de FriendlyWrt {version} para NanoPi NEO3 Plus con Fibocom FM350-GL, APN `surf.br`, prioridad celular, WAN DHCP de respaldo y mantenimiento en el mismo RJ45 mediante `192.168.77.1/24`.

Grabe `{args.image}` directamente con Raspberry Pi Imager o balenaEtcher y verifique `SHA256SUMS`. Los commits exactos están en `source-lock.json` (huella `{fingerprint}`).

## 简体中文

这是适用于 NanoPi NEO3 Plus 和 Fibocom FM350-GL 的 FriendlyWrt {version} 自动构建镜像。默认 APN 为 `surf.br`，蜂窝网络优先，RJ45 提供 DHCP 备用 WAN，并可通过 `192.168.77.1/24` 维护。

请使用 Raspberry Pi Imager 或 balenaEtcher 直接写入 `{args.image}`，并用 `SHA256SUMS` 校验。所有上游提交记录在 `source-lock.json` 中（指纹 `{fingerprint}`）。
"""
    Path(args.output).write_text(notes, encoding="utf-8")


if __name__ == "__main__":
    main()
