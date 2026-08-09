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
- 多语言 **网络 → FM350 Manager** 面板，提供状态、完整 APN/SIM 配置、短信、无线分析及连接控制。
- `sys_led` 显示系统心跳；`user_led` 显示 FM350 链路和 RX/TX 流量。
- 在维护接口上通过 LuCI 和 SSH 提供完整 root 管理权限。

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

如果未设置 `ROOT_PASSWORD_HASH`，镜像保留 FriendlyWrt 初始凭据：用户名 `root`、密码 `password`。从维护客户端登录 LuCI 或 SSH 后拥有完整管理权限。永久部署时必须立即修改此公开密码。`AUTHORIZED_KEYS` 可选地添加 SSH 恢复密钥。

## 调制解调器面板与 LED

登录后打开 **网络 → FM350 Manager**。面板显示 SIM、运营商、网络技术、RAT、信号、网络和 IP。分析区包含信号/流量图、当前频段/信道/PCI/带宽以及调制解调器支持的全部 3G/4G/5G 频段。完整表单管理 APN、PDP、CID、SIM PIN 和 PAP/CHAP 凭据，且不会把已保存的秘密返回浏览器。短信区可读取 ME/SM、解码 UCS-2、发送最多 160 字节的标准文本并删除短信。

常用操作、APN、信号、图表和短信始终可见；频段矩阵、CID 与凭据收纳在高级折叠区。控件会根据当前状态动态启用。

| LED | 配置 | 含义 |
| --- | --- | --- |
| `sys_led` | `heartbeat` | 操作系统正在运行。 |
| `user_led` | `eth1` 上的 `netdev`，模式 `link tx rx` | 蜂窝链路已连接，调制解调器传输数据时闪烁。 |

GitHub Actions 每天检查上游更新，也会在 `main` 中构建配方变化时运行。每个 release 包含 `.img.gz`、`SHA256SUMS` 和记录精确提交的 `source-lock.json`。详情见 [BUILD.md](BUILD.md)。

不要把维护网段连接到不可信的以太网。请阅读 [SECURITY.md](../SECURITY.md)。本社区项目与 FriendlyELEC、FriendlyARM、Fibocom 或移动运营商无官方关系。
