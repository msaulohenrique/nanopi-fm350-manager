# NanoPi NEO3 Plus · FriendlyWrt + Fibocom FM350-GL

[English](../README.md) · [Português (Brasil)](README.pt-BR.md) · [Español](README.es.md) · [Français](README.fr.md)

这是为 NanoPi NEO3 Plus 和 Fibocom FM350-GL 5G 模组准备的可复现 FriendlyWrt 镜像。默认蜂窝配置使用巴西 APN `surf.br`，每个上游源码提交都会记录在 `source-lock.json` 中。

## 已预配置

- 自动识别 FM350-GL USB 模式 `0e8d:7126`、`0e8d:7127` 及对应 AT 端口。
- 集成 [modemfeed](https://github.com/koshev-msk/modemfeed) 的 `xmm-modem` 和 `luci-proto-xmm`。
- IPv4 蜂窝连接使用 `surf.br`，路由度量值 10，优先使用。
- 唯一 RJ45 同时作为 DHCP WAN，度量值 20，用作备用网络。
- 同一 RJ45 提供无 DHCP 的维护地址 `192.168.77.1/24`。
- LuCI、SSH、DNS 和蜂窝转发仅允许维护客户端 `192.168.77.2`。
- 禁用 SSH 密码登录。

## 下载与写入

1. 从 [Releases](https://github.com/msaulohenrique/nanopi-fm350-manager/releases) 下载最新 `.img.gz` 和 `SHA256SUMS`。
2. 校验 SHA-256。
3. 使用 [Raspberry Pi Imager](https://www.raspberrypi.com/software/) 或 balenaEtcher 直接写入压缩镜像。
4. 插入 microSD、连接 FM350-GL 并启动 NanoPi。首次启动准备分区可能需要几分钟。

SIM 卡应已激活且不要求 PIN；如果需要 PIN，请先在 LuCI 中配置。

## 一个 RJ45，两种用途

| 用途 | 客户端设置 | NanoPi 地址 | 行为 |
| --- | --- | --- | --- |
| 普通 WAN | DHCP | 由上级路由器分配 | 备用互联网，度量值 20 |
| 直接维护 | 静态 `192.168.77.2/24`；网关/DNS `192.168.77.1` | `192.168.77.1` | LuCI 和蜂窝互联网；不提供 DHCP |

维护时访问 `https://192.168.77.1/`。本地证书可能触发浏览器首次警告。

如果仓库所有者未设置 `ROOT_PASSWORD_HASH`，镜像保留 FriendlyWrt 的初始 LuCI 凭据（`root` / `password`），请立即修改。只有构建时设置了 `AUTHORIZED_KEYS`，SSH 才可用。

GitHub Actions 每天检查上游更新，也会在 `main` 中构建配方变化时运行。每个 release 包含 `.img.gz`、`SHA256SUMS` 和记录精确提交的 `source-lock.json`。详情见 [BUILD.md](BUILD.md)。

不要把维护网段连接到不可信的以太网。请阅读 [SECURITY.md](../SECURITY.md)。本社区项目与 FriendlyELEC、FriendlyARM、Fibocom 或移动运营商无官方关系。
