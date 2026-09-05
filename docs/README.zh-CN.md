# NanoPi NEO3 Plus · FriendlyWrt + Fibocom FM350-GL

[English](../README.md) · [Português (Brasil)](README.pt-BR.md) · [Español](README.es.md) · [Français](README.fr.md)

这是面向 NanoPi NEO3 Plus 与 Fibocom FM350-GL 5G 模组的可复现 FriendlyWrt 固件。默认移动网络 APN 为 `surf.br`，所有上游源码都固定到 `source-lock.json` 中记录的精确 commit。

## 架构

FM350 作为蜂窝 WAN。NanoPi 唯一的 RJ45 作为 `192.168.77.1/24` 的 DHCP/NAT 维护与下游 LAN。SRTLA/RatoNet 多链路 bonding 仍由下游编码器或路由器处理；NanoPi 保持独立蜂窝网关角色。

## 安全的首次启动

公开自动构建不会写入所有设备共用的管理员密码，也不会写入个人 SSH key。若可信私有构建未提供 `ROOT_PASSWORD_HASH`，构建过程会清除 FriendlyWrt 继承的厂商默认密码，并采用 OpenWrt 的正常首次登录流程。

1. 首次启动时只连接可信维护网络。
2. 打开 `https://192.168.77.1/`。
3. 第一次登录使用用户 `root`，密码留空。
4. 立即在 **System → Administration** 中设置强且唯一的密码。
5. SSH 密码登录默认关闭，推荐使用 `AUTHORIZED_KEYS`。

详见 [SECURITY.md](../SECURITY.md)。

## 遥测

系统可报告 RSSI、RSRP、RSRQ，以及模组可用时的 NR SINR，同时提供 RAT、运营商、TAC、Cell ID、频段、IP 与流量信息。

受 token 保护的 API：

```text
https://192.168.77.1/cgi-bin/fm350-telemetry
```

每台设备的独立 token 可在 **Network → FM350 Manager → Telemetry API** 中管理：

```bash
curl -k -H 'X-API-Key: TOKEN' 'https://192.168.77.1/cgi-bin/fm350-telemetry'
```

返回数据会区分 `physical_transport: ethernet` 与 `upstream_type: cellular`。这样 RatoNet 可以继续使用真实 Ethernet 接口进行 SRTLA 绑定，同时补充 RSRP/RSRQ/SINR 与蜂窝网络信息。参见 [RATONET.md](RATONET.md)。

## 发布类型

- **Hardware-verified stable**：已在真实 NanoPi NEO3 Plus 上确认启动、RJ45、FM350 注册、蜂窝互联网与重启。
- **Candidate**：tag 以 `candidate-` 开头；CI 已完成编译与结构检查，但尚未证明真实硬件能够启动。

自动 workflow 会验证源码锁、SHA-256、gzip 完整性和 SD 镜像基本结构，将结果发布为 prerelease candidate，并重新下载发布资产再次验证 checksum。只有独立的手动硬件验证 workflow 在全部物理测试确认后才能创建 stable，并附带 `HARDWARE_VALIDATION.md`。

参见 [HARDWARE_VALIDATION.md](HARDWARE_VALIDATION.md) 与 [BUILD.md](BUILD.md)。

## 安装

1. 下载 `.img.gz`、`SHA256SUMS` 和 `source-lock.json`。
2. 刷写前验证 SHA-256。
3. 使用 Raspberry Pi Imager 或 balenaEtcher 直接写入压缩镜像。
4. 为 FM350 适配板提供合适的独立供电，然后启动 NanoPi。

RJ45 会提供 `192.168.77.100–149` DHCP、DNS 与蜂窝互联网。下游路由器 LAN 必须使用不同子网。

额外 NAT hop 是有意设计，以优先保证 FM350 T700/RNDIS/XMM 路径稳定性。

本项目为社区项目，与 FriendlyELEC、FriendlyARM、Fibocom、RatoNet 或移动运营商均无官方隶属关系。
