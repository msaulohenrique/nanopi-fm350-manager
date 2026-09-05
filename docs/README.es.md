# NanoPi NEO3 Plus · FriendlyWrt + Fibocom FM350-GL

[English](../README.md) · [Português (Brasil)](README.pt-BR.md) · [简体中文](README.zh-CN.md) · [Français](README.fr.md) · [Documentation index](README.md)

Firmware FriendlyWrt reproducible para NanoPi NEO3 Plus con módem 5G Fibocom FM350-GL. El perfil móvil predeterminado usa `surf.br` y cada fuente del build queda fijada por commit en `source-lock.json`.

## Arquitectura

El FM350 es la WAN celular y la única RJ45 del NanoPi es una LAN de mantenimiento/downstream con DHCP/NAT en `192.168.77.1/24`. El bonding SRTLA/RatoNet sigue perteneciendo al encoder o router conectado; el NanoPi permanece como gateway celular independiente.

## Primer arranque seguro

Las imágenes públicas no incluyen una contraseña de administrador compartida ni claves SSH personales. Si un build privado no inyecta `ROOT_PASSWORD_HASH`, se elimina la contraseña heredada del proveedor y se usa el flujo inicial normal de OpenWrt.

1. Conecte el equipo únicamente a una red de mantenimiento confiable.
2. Abra `https://192.168.77.1/`.
3. Entre como `root` dejando la contraseña vacía solo en el primer acceso.
4. Configure inmediatamente una contraseña fuerte y única en **System → Administration**.
5. La autenticación SSH por contraseña permanece deshabilitada por defecto; se recomienda `AUTHORIZED_KEYS`.

Consulte [SECURITY.md](../SECURITY.md).

## Telemetría

El panel muestra RSSI, RSRP, RSRQ y SINR NR cuando el módem los reporta, además de RAT, operador, TAC, Cell ID, bandas, IP y tráfico.

La API protegida por token está disponible en:

```text
https://192.168.77.1/cgi-bin/fm350-telemetry
```

Use el token individual mostrado en **Network → FM350 Manager → Telemetry API**:

```bash
curl -k -H 'X-API-Key: TOKEN' 'https://192.168.77.1/cgi-bin/fm350-telemetry'
```

La respuesta distingue `physical_transport: ethernet` de `upstream_type: cellular`, permitiendo que RatoNet conserve la interfaz Ethernet real para SRTLA y añada datos móviles como RSRP/RSRQ/SINR. Consulte [RATONET.md](RATONET.md).

## Releases

- **Hardware-verified stable:** validada físicamente en NanoPi NEO3 Plus para boot, RJ45, FM350, Internet y reinicio.
- **Candidate:** tag `candidate-*`; compilada y validada estructuralmente por CI, pero todavía sin prueba física de boot.

Las releases automáticas anteriores a esta política y las tags heredadas duplicadas quedan archivadas en [RELEASE_HISTORY.md](RELEASE_HISTORY.md) en lugar de mantenerse en las listas activas de Releases/Tags.

El workflow automático genera y verifica SHA-256, integridad gzip y estructura básica de la imagen, publica la candidate como prerelease y vuelve a descargar los assets para verificar sus checksums. Un segundo workflow manual solo promueve a stable cuando se confirma la lista completa de pruebas físicas y agrega `HARDWARE_VALIDATION.md`.

Consulte [HARDWARE_VALIDATION.md](HARDWARE_VALIDATION.md), [BUILD.md](BUILD.md) y el [índice de documentación](README.md).

## Instalación

1. Descargue `.img.gz`, `SHA256SUMS` y `source-lock.json`.
2. Verifique SHA-256.
3. Grabe la imagen con Raspberry Pi Imager o balenaEtcher.
4. Conecte el FM350 con alimentación adecuada y arranque el NanoPi.

La RJ45 entrega DHCP `192.168.77.100–149`, DNS e Internet celular. La LAN del router conectado debe usar otra subred.

El salto NAT adicional es intencional para priorizar estabilidad del camino FM350 T700/RNDIS/XMM.

Proyecto comunitario sin afiliación oficial con FriendlyELEC, FriendlyARM, Fibocom, RatoNet ni operadores móviles.
