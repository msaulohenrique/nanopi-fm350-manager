# NanoPi NEO3 Plus · FriendlyWrt + Fibocom FM350-GL

[English](../README.md) · [Español](README.es.md) · [简体中文](README.zh-CN.md) · [Français](README.fr.md) · [Índice da documentação](README.md)

Firmware FriendlyWrt reproduzível para o NanoPi NEO3 Plus com modem 5G Fibocom FM350-GL. O perfil móvel padrão usa a APN brasileira `surf.br`, e cada fonte do build fica fixada por commit em `source-lock.json`.

O NanoPi funciona propositalmente como um **gateway celular independente**: o FM350 é a WAN de Internet e a única RJ45 fornece uma rede roteada DHCP/NAT para manutenção e para o roteador/encoder conectado. Bonding de múltiplos links, como RatoNet/SRTLA, continua no equipamento downstream.

## O que já vem configurado

- Modos USB `0e8d:7126` e `0e8d:7127` do FM350-GL, com autodetecção da porta AT.
- `xmm-modem` e `luci-proto-xmm` do modemfeed.
- Conexão celular IPv4 pela APN `surf.br`, métrica 10.
- FM350 como WAN com mascaramento IPv4.
- RJ45 como LAN/manutenção DHCP em `192.168.77.1/24`.
- LuCI, DNS e encaminhamento celular pela mesma RJ45.
- Painel **Rede → FM350 Manager** com APN/SIM, SMS, bandas, tráfego e rádio.
- Telemetria LTE/NR explícita: RSSI, RSRP, RSRQ e SINR NR quando disponível, além de TAC, Cell ID, RAT, operadora e bandas.
- API JSON de telemetria protegida por token para RatoNet e outros sistemas.
- `sys_led` como heartbeat e `user_led` para link/tráfego do FM350.
- Primeiro boot sem uma senha administrativa pública compartilhada.

## Primeiro boot seguro

As imagens públicas automáticas **não** recebem uma mesma senha root nem uma chave SSH pessoal. Quando nenhuma senha é injetada em um build privado confiável, o processo remove a senha padrão herdada do FriendlyWrt e segue o fluxo inicial normal do OpenWrt.

1. Conecte a RJ45 apenas a um computador ou roteador confiável.
2. Abra `https://192.168.77.1/`.
3. No primeiro acesso, entre como `root` deixando a senha vazia.
4. Defina imediatamente uma senha forte e exclusiva em **Sistema → Administração**.
5. Login SSH por senha permanece desativado por padrão. Prefira chave SSH via `AUTHORIZED_KEYS`.

Não exponha um equipamento ainda não configurado a um segmento Ethernet não confiável. Consulte [SECURITY.md](../SECURITY.md).

## Releases: candidata x validada em hardware

Existem duas classes de release:

- **Stable / hardware-verified** — testada fisicamente no NanoPi NEO3 Plus para boot, RJ45, registro do FM350, Internet celular e reinicialização. É a recomendada para uso permanente.
- **Candidate** — tag iniciada por `candidate-`; compilada e verificada estruturalmente pelo CI, mas ainda sem comprovação de boot no hardware físico.

Releases automáticas anteriores a essa política e tags legadas duplicadas ficam documentadas no [histórico de releases](RELEASE_HISTORY.md), em vez de permanecerem na lista ativa de Releases/Tags.

Para instalar:

1. Baixe `.img.gz`, `SHA256SUMS` e `source-lock.json`.
2. Confira o SHA-256 antes de gravar.
3. Grave o `.img.gz` diretamente com Raspberry Pi Imager ou balenaEtcher.
4. Insira o microSD, conecte o adaptador do FM350 com alimentação adequada e ligue o NanoPi.

Releases estáveis também trazem `HARDWARE_VALIDATION.md` e `HARDWARE_VALIDATION_SHA256`. Veja a [política de validação em hardware](HARDWARE_VALIDATION.md).

## Conectar o roteador

| Conexão | Configuração | Endereço do NanoPi | Comportamento |
| --- | --- | --- | --- |
| WAN do roteador | DHCP/automático | `192.168.77.1` | Recebe `192.168.77.100–149`, DNS e Internet celular |
| Computador direto | DHCP/automático ou `192.168.77.2/24` | `192.168.77.1` | LuCI e Internet celular |

A LAN do roteador downstream deve usar outra sub-rede, por exemplo `192.168.1.0/24`.

Esse desenho adiciona uma camada de NAT. É intencional: o projeto prioriza estabilidade no caminho FM350 T700/RNDIS/XMM em vez de bridge transparente frágil. Em redes móveis ainda pode existir CGNAT da operadora.

## API de telemetria do FM350

Abra **Rede → FM350 Manager → Telemetry API**. A página mostra as métricas de rádio, endpoint e token exclusivo gerado no primeiro boot. É possível ativar/desativar a API ou rotacionar o token.

Endpoint:

```text
https://192.168.77.1/cgi-bin/fm350-telemetry
```

Exemplo:

```bash
curl -k \
  -H 'X-API-Key: TOKEN_DO_DISPOSITIVO' \
  'https://192.168.77.1/cgi-bin/fm350-telemetry'
```

A API diferencia o transporte Linux da origem real da Internet:

```json
{
  "upstream_type": "cellular",
  "physical_transport": "ethernet",
  "connection": {
    "technology": "5G NSA (LTE-NR EN-DC)"
  },
  "signal": {
    "rssi_dbm": "-65",
    "rsrp_dbm": "-89",
    "rsrq_db": "-10.0",
    "sinr_db": "22.0"
  }
}
```

Isso resolve a principal limitação ao integrar com sistemas como o RatoNet: o encoder continua usando a interface Ethernet real para bind, ping e bonding, enquanto a API informa que o upstream é celular e entrega operadora, RAT, RSRP, RSRQ, SINR, bandas, TAC e Cell ID. Veja [integração com RatoNet](RATONET.md).

A API nunca expõe PIN do SIM, usuário APN ou senha APN.

## Painel do modem

O painel principal mostra estado do SIM, operadora, tecnologia, RAT, registro, sinal, interfaces AT/dados, IP, gateway, DNS e uptime. A parte analítica mostra histórico de sinal/tráfego, bandas/canais/PCI/largura em uso, bandas habilitadas e suportadas.

O formulário celular gerencia APN, PDP, CID/perfil, PIN, PAP/CHAP, usuário e senha. Segredos gravados não são retornados no status do navegador. A área SMS lista memória do modem/SIM, decodifica UCS-2, envia SMS e apaga mensagens.

| LED | Configuração | Significado |
| --- | --- | --- |
| `sys_led` | `heartbeat` | Sistema operacional ativo |
| `user_led` | `netdev` em `eth1`, `link tx rx` | Link/tráfego celular |

O botão físico `BTN_1` faz reboot seguro ao ser solto. O botão **MASK** mantém sua função de boot/recuperação.

## GitHub Actions e confiança da imagem

O sistema de Actions agora separa claramente **compilou** de **funcionou no hardware**.

### Workflow automático de candidate

A cada mudança relevante, execução manual ou verificação diária:

1. resolve commits exatos de FriendlyWrt, kernel, U-Boot, toolchain, modemfeed e ferramentas;
2. grava tudo em `source-lock.json`;
3. executa validações de shell, JSON, JavaScript, segurança e testes unitários;
4. compila rootfs, U-Boot, kernel e imagem SD;
5. valida integridade gzip, tamanho da imagem, tabela de partições e área inicial não zerada;
6. gera SHA-256;
7. publica como `candidate-*` e `prerelease`;
8. baixa os assets publicados novamente e confere o SHA-256 outra vez.

Mesmo assim, candidate continua marcada explicitamente como **não validada em hardware**.

### Promoção manual para stable

Um segundo workflow só cria release estável quando o teste físico confirma obrigatoriamente:

- boot do NanoPi NEO3 Plus;
- RJ45/DHCP;
- detecção e registro do FM350;
- Internet celular passando para a RJ45;
- reinicialização limpa.

Os assets da candidate são baixados e verificados novamente, e a stable recebe um registro `HARDWARE_VALIDATION.md` com testador, data, checksums e observações.

Veja [BUILD.md](BUILD.md), [HARDWARE_VALIDATION.md](HARDWARE_VALIDATION.md) e o [índice da documentação](README.md).

## Builds privados

Builds locais/confiáveis podem fornecer:

- `ROOT_PASSWORD_HASH` — hash `crypt(3)` SHA-256/SHA-512/yescrypt de uma senha única;
- `AUTHORIZED_KEYS` — chave(s) pública(s) SSH para acesso por chave.

O workflow público não injeta esses valores nas imagens compartilhadas.

## Suporte

Em caso de travamento no boot, informe a tag exata, SHA-256 da imagem, modelo do microSD, fonte, estado dos LEDs e, quando possível, logs UART/U-Boot/kernel. Para falhas do modem, inclua também USB ID, porta AT detectada e logs relevantes.

Projeto comunitário sem vínculo oficial com FriendlyELEC, FriendlyARM, Fibocom, RatoNet ou operadoras móveis.
