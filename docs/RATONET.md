# RatoNet integration

The NanoPi NEO3 Plus + FM350-GL remains an independent 5G gateway. To an encoder running RatoNet it is physically connected through Ethernet, so RatoNet's current interface-name classifier correctly sees the link as `ethernet`. That is a transport detail; the upstream connection is still cellular.

## Topology

```text
FM350-GL 4G/5G
      |
      | USB/RNDIS + AT
      v
NanoPi NEO3 Plus
FriendlyWrt + FM350 Manager
      |
      | RJ45 / NAT
      v
RatoNet field encoder
```

For SRTLA bonding with multiple NanoPi gateways, each unit is still a separate network link and therefore needs its own Ethernet path into the encoder (for example, one USB-Ethernet adapter per gateway) and appropriate power. This project does not move SRTLA bonding into the NanoPi; the RatoNet encoder remains responsible for bonding.

## Telemetry API

The gateway exposes modem-aware telemetry that RatoNet or another monitoring system can query instead of inferring cellular state from the Ethernet interface name.

For security, external telemetry is **disabled by default**. On first boot:

1. open LuCI at `https://192.168.77.1/` on the trusted maintenance network;
2. set a unique root password in **System → Administration**;
3. open **Network → FM350 Manager → Telemetry API**;
4. enable the API and copy the per-device token.

The token is generated independently on first boot. Enabling or rotating it is refused until administrator onboarding is complete.

Endpoint:

```text
https://192.168.77.1/cgi-bin/fm350-telemetry
```

Authentication header:

```text
X-API-Key: <per-device-token>
```

Example:

```bash
curl -k \
  -H 'X-API-Key: YOUR_DEVICE_TOKEN' \
  'https://192.168.77.1/cgi-bin/fm350-telemetry'
```

Representative response:

```json
{
  "schema_version": 1,
  "gateway_model": "NanoPi NEO3 Plus",
  "modem_model": "Fibocom FM350-GL",
  "upstream_type": "cellular",
  "physical_transport": "ethernet",
  "ratonet_type": "4g",
  "connection": {
    "state": "connected",
    "up": true,
    "operator": "operator",
    "technology": "5G NSA (LTE-NR EN-DC)"
  },
  "signal": {
    "generation": "nr",
    "rssi_dbm": "-65",
    "rsrp_dbm": "-89",
    "rsrq_db": "-10.0",
    "sinr_db": "22.0"
  },
  "radio": {
    "tac": "...",
    "cell_id": "...",
    "bands_in_use": "n78 (...); B3 (...)"
  },
  "network": {
    "interface": "eth1",
    "ipv4": "...",
    "gateway": "...",
    "uptime_seconds": "...",
    "rx_bytes": "...",
    "tx_bytes": "..."
  }
}
```

`ratonet_type` is provided as `4g` for compatibility with RatoNet's current mobile-link label even when the active RAT is 5G. Consumers should prefer `connection.technology` and the explicit LTE/NR signal fields for the real radio state.

## Recommended RatoNet-side integration

RatoNet can keep the Ethernet interface for routing, RTT, jitter, packet loss, bandwidth and SRTLA bonding while optionally enriching that link with this API:

1. Detect/configure a NanoPi gateway address for the Ethernet link.
2. Query the telemetry endpoint with the per-device API key.
3. Preserve `interface=eth*` as the actual transport used for packet binding.
4. Add `upstream_type=cellular`, operator, RAT, RSRP, RSRQ, SINR, bands, TAC and Cell ID to the RatoNet telemetry object.
5. Do not reclassify the Linux interface itself as WWAN; instead distinguish **physical transport** from **upstream access type**.

This avoids breaking SRTLA interface binding while making the dashboard modem-aware.

## NAT

The gateway performs IPv4 NAT before traffic reaches the RatoNet encoder. That extra routing hop is intentional. For IRL streaming the main trade-off is an additional NAT layer rather than a meaningful CPU-routing delay; mobile carriers frequently add CGNAT upstream as well. The project therefore prioritizes stable gateway behavior instead of attempting transparent bridging on the FM350 T700/RNDIS path.
