# NanoPi NEO3 Plus · FriendlyWrt + Fibocom FM350-GL

[English](../README.md) · [Español](README.es.md) · [简体中文](README.zh-CN.md) · [Français](README.fr.md)

Imagens reproduzíveis e prontas para gravar do FriendlyWrt para o NanoPi NEO3 Plus com modem 5G Fibocom FM350-GL. O perfil móvel padrão usa a APN brasileira `surf.br`, e cada fonte do build fica fixada por commit em `source-lock.json`.

## O que já vem configurado

- Modos USB `0e8d:7126` e `0e8d:7127` do FM350-GL, com detecção automática da porta AT.
- Pacotes `xmm-modem` e `luci-proto-xmm` do [modemfeed](https://github.com/koshev-msk/modemfeed).
- Conexão celular IPv4 pela APN `surf.br`, métrica 10 e prioridade principal.
- A única RJ45 como WAN DHCP, métrica 20 e rota de contingência.
- A mesma RJ45 como manutenção sem DHCP, no endereço `192.168.77.1/24`.
- LuCI, SSH, DNS e saída celular liberados somente para o cliente de manutenção `192.168.77.2`.
- Painel multilíngue **Rede → FM350 Manager** com status, APN/SIM completo, SMS, análises de rádio e controles da conexão.
- `sys_led` como heartbeat; `user_led` indicando link e tráfego RX/TX do FM350.
- Acesso administrativo completo de root pelo LuCI e SSH na interface de manutenção.

## Baixar e gravar

1. Baixe a versão mais nova de `.img.gz` e `SHA256SUMS` em [Releases](https://github.com/msaulohenrique/nanopi-fm350-manager/releases).
2. Confira o checksum.
3. Grave o arquivo compactado diretamente com o [Raspberry Pi Imager](https://www.raspberrypi.com/software/) ou balenaEtcher.
4. Coloque o microSD, conecte o FM350-GL e ligue o NanoPi. O primeiro boot pode levar alguns minutos para preparar as partições.

O SIM deve estar ativo e sem solicitação de PIN. Se houver PIN, configure-o no LuCI antes de ativar a interface celular.

## Uma RJ45, duas funções

| Uso | Configuração do computador/roteador | Endereço do NanoPi | Comportamento |
| --- | --- | --- | --- |
| WAN normal | DHCP | Recebido do roteador principal | Contingência de internet, métrica 20 |
| Manutenção direta | IP fixo `192.168.77.2/24`; gateway/DNS `192.168.77.1` | `192.168.77.1` | LuCI e internet celular; sem servidor DHCP |

Na manutenção, abra `https://192.168.77.1/`. O certificado é gerado localmente, então o navegador pode avisar na primeira abertura.

Sem o segredo `ROOT_PASSWORD_HASH`, a imagem mantém a credencial inicial do FriendlyWrt: usuário `root`, senha `password`. Ela permite administração completa pelo LuCI e SSH a partir do cliente de manutenção. Troque essa senha pública imediatamente em instalações permanentes. `AUTHORIZED_KEYS` adiciona opcionalmente uma chave SSH de recuperação.

## Painel do modem e LEDs

Depois de entrar, abra **Rede → FM350 Manager**. O painel mostra SIM, operadora, tecnologia, RAT, registro, sinal, interfaces AT/dados, IP, gateway, DNS e tempo conectado. A área analítica traz gráficos de sinal e tráfego, bandas/canais/PCI/largura em uso, bandas habilitadas e todas as bandas 3G/4G/5G suportadas. Como o driver T700 mantém o RX de `eth1` zerado, o gráfico de download usa automaticamente os bytes celulares encaminhados pela RJ45.

O formulário celular completo gerencia APN, tipo PDP, CID/perfil, PIN do SIM, PAP/CHAP, usuário e senha. PIN e senha salvos nunca voltam ao navegador: campos secretos vazios preservam os valores e uma caixa separada remove explicitamente o PIN. A área SMS lista a memória do modem ou do SIM, decodifica mensagens UCS-2, envia textos padrão de até 160 bytes e apaga a mensagem selecionada.

A interface é progressiva: ações comuns, APN, qualidade do sinal, gráficos e SMS ficam visíveis; matriz de bandas, CID e credenciais ficam recolhidos nas áreas avançadas. Botões e campos são habilitados dinamicamente apenas quando fazem sentido no estado atual.

| LED | Configuração | Significado |
| --- | --- | --- |
| `sys_led` | `heartbeat` | O sistema operacional está ativo. |
| `user_led` | `netdev` em `eth1`, modos `link tx rx` | Link celular ativo e piscadas durante tráfego do modem. |

## Releases automáticas

O GitHub Actions verifica novidades diariamente e também quando a receita muda na branch `main`. Ele acompanha o manifesto `master-v*` mais novo, resolve os commits exatos de FriendlyWrt, kernel, U-Boot, toolchain, modemfeed e ferramentas de build, e não recompila quando essa impressão completa já possui release.

Cada release traz a imagem `.img.gz`, os checksums da imagem compactada e bruta e o arquivo `source-lock.json`. Veja os [detalhes de compilação](BUILD.md).

O primeiro build local validado usou FriendlyWrt 25.12 em 08/08/2026. SHA-256 da imagem bruta: `7ee7a8cb836fd61eaf71fa34795067f63bc0a99289cceade07ddf9c04ad1ca18`.

Não exponha a rede de manutenção a uma Ethernet não confiável. Consulte [SECURITY.md](../SECURITY.md). Este é um projeto comunitário, sem vínculo oficial com FriendlyELEC, FriendlyARM, Fibocom ou a operadora.
