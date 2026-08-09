# NanoPi NEO3 Plus · FriendlyWrt + Fibocom FM350-GL

[English](../README.md) · [Português (Brasil)](README.pt-BR.md) · [简体中文](README.zh-CN.md) · [Français](README.fr.md)

Imágenes FriendlyWrt reproducibles y listas para grabar para NanoPi NEO3 Plus con módem 5G Fibocom FM350-GL. El perfil móvil usa el APN brasileño `surf.br`; cada fuente queda fijada por commit en `source-lock.json`.

## Configuración incluida

- Modos USB FM350-GL `0e8d:7126` y `0e8d:7127`, con detección automática del puerto AT.
- `xmm-modem` y `luci-proto-xmm` de [modemfeed](https://github.com/koshev-msk/modemfeed).
- Red celular IPv4 mediante `surf.br`, métrica 10 y ruta preferida.
- La interfaz celular FM350 como WAN de Internet, con enmascaramiento IPv4.
- El único RJ45 como LAN DHCP para el router conectado, puerta de enlace `192.168.77.1/24`.
- LuCI, SSH, DNS y salida celular disponibles por el mismo RJ45.
- Panel multilingüe **Red → FM350 Manager** con estado, APN/SIM completo, SMS, analítica de radio y controles.
- `sys_led` como latido del sistema; `user_led` para enlace y tráfico RX/TX del FM350.
- Acceso administrativo completo de root mediante LuCI y SSH en la interfaz de mantenimiento.

## Descargar y grabar

1. Descargue el `.img.gz` más reciente y `SHA256SUMS` desde [Releases](https://github.com/msaulohenrique/nanopi-fm350-manager/releases).
2. Verifique el checksum.
3. Grabe el archivo comprimido directamente con [Raspberry Pi Imager](https://www.raspberrypi.com/software/) o balenaEtcher.
4. Inserte la microSD, conecte el FM350-GL y encienda el NanoPi. El primer arranque puede tardar varios minutos.

La SIM debe estar activa y sin solicitud de PIN. Si usa PIN, configúrelo en LuCI antes de activar la interfaz celular.

## Conectar el router

| Conexión | Configuración del cliente | Dirección NanoPi | Resultado |
| --- | --- | --- | --- |
| Puerto WAN del router | DHCP/automático | `192.168.77.1` | Recibe `192.168.77.100–149`, DNS e Internet celular |
| Ordenador de mantenimiento directo | DHCP/automático, o `192.168.77.2/24` estático | `192.168.77.1` | LuCI, SSH e Internet celular por el mismo cable |

Abra `https://192.168.77.1/`. El certificado local puede producir una advertencia inicial del navegador.

Conecte el RJ45 del NanoPi al puerto **WAN/Internet** del router y deje ese puerto en DHCP. La LAN del router debe utilizar otra subred, como `192.168.1.0/24`. El botón GPIO de usuario (`BTN_1`) reinicia el sistema al soltarlo; el botón **MASK** conserva su función de recuperación.

Sin `ROOT_PASSWORD_HASH`, la imagen conserva las credenciales iniciales de FriendlyWrt: usuario `root`, contraseña `password`. Permiten administración completa mediante LuCI y SSH desde el cliente de mantenimiento. Cambie este valor público inmediatamente en instalaciones permanentes. `AUTHORIZED_KEYS` añade opcionalmente una clave SSH de recuperación.

## Panel del módem y LED

Después de iniciar sesión, abra **Red → FM350 Manager**. El panel muestra SIM, operador, tecnología, RAT, señal, red e IP. La analítica incluye gráficos de señal/tráfico, bandas/canales/PCI/ancho de banda en uso y todas las bandas 3G/4G/5G admitidas. El formulario gestiona APN, PDP, CID, PIN SIM y credenciales PAP/CHAP sin devolver secretos guardados al navegador. SMS permite leer memorias ME/SM, decodificar UCS-2, enviar textos estándar de hasta 160 bytes y eliminarlos.

La interfaz mantiene visibles las acciones comunes, APN, señal, gráficos y SMS; las bandas, CID y credenciales se despliegan como opciones avanzadas. Los controles se habilitan dinámicamente según el estado.

| LED | Configuración | Significado |
| --- | --- | --- |
| `sys_led` | `heartbeat` | El sistema está activo. |
| `user_led` | `netdev` en `eth1`, modos `link tx rx` | Enlace celular y parpadeo durante tráfico del módem. |

GitHub Actions busca cambios cada día y al modificar la receta en `main`. Sigue el manifiesto `master-v*` más reciente y registra todos los commits exactos. Cada release contiene `.img.gz`, `SHA256SUMS` y `source-lock.json`. Consulte [BUILD.md](BUILD.md).

No exponga la red de mantenimiento a un segmento Ethernet no confiable. Consulte [SECURITY.md](../SECURITY.md). Este proyecto comunitario no está afiliado con FriendlyELEC, FriendlyARM, Fibocom ni el operador móvil.
