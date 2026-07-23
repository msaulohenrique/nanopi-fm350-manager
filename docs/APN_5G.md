# Configuração de APN 5G - NanoPi FM350 Manager

## Introdução

Este guia explica como configurar o APN para conexão 5G/LTE no modem Fibocom FM350-GL.

## Operadoras e MVNOs Brasileiras

| Operadora / MVNO     | APN                     | Tipo PDN   | Autenticação | Observações                  |
|----------------------|-------------------------|------------|--------------|------------------------------|
| **Vivo**             | `zap.vivo.com.br`       | IPv4v6     | None         | Melhor para 5G              |
| **Claro**            | `claro.br`              | IPv4v6     | None         | Boa cobertura               |
| **TIM**              | `tim.br`                | IPv4v6     | None         | Rápida em áreas urbanas     |
| **Hypecon**          | `hypecon.br` ou `internet` | IPv4v6  | None         | MVNO - Verificar no app/site |
| **Surf MVNO**        | `surf.br` ou `internet` | IPv4v6     | None         | Depende da credenciada      |

## DNS Recomendados

| Provedor              | DNS Primário          | DNS Secundário        | Recomendado para          |
|-----------------------|-----------------------|-----------------------|---------------------------|
| **Google**            | `8.8.8.8`             | `8.8.4.4`             | Geral / Velocidade        |
| **Cloudflare**        | `1.1.1.1`             | `1.0.0.1`             | Privacidade + Velocidade  |
| **Quad9**             | `9.9.9.9`             | `149.112.112.112`     | Segurança (bloqueio malware) |
| **OpenDNS**           | `208.67.222.222`      | `208.67.220.220`      | Controle parental         |
| **Vivo**              | `177.11.0.0`          | `177.11.0.1`          | Operadora oficial         |
| **Claro**             | `200.149.0.0`         | `200.149.0.1`         | Operadora oficial         |

> **Dica**: Use Cloudflare (`1.1.1.1`) para melhor performance e privacidade na maioria dos casos.

### Links Importantes

- **Hypecon**: [https://hypecon.gg/](https://hypecon.gg/)
- **Surf MVNO - Credenciadas**: [https://www.surf.com.br/site/credenciadas/](https://www.surf.com.br/site/credenciadas/)

> **Nota**: Para MVNOs como Hypecon e Surf, o APN pode variar conforme a operadora credenciada (Vivo, Claro, TIM). Consulte o app ou suporte da MVNO para o APN exato.
## Como Configurar (Interface Web)

1. Acesse o painel → **Configuração de APN**
2. Escolha a operadora ou selecione "Perfil Personalizado"
3. Preencha os campos:
   - **APN**: (ex: `zap.vivo.com.br`)
   - **Tipo PDN**: IPv4v6 (recomendado)
   - **Autenticação**: None (geralmente)
   - **Usuário/Senha**: Deixe em branco na maioria dos casos
   - **MTU**: 1500 (padrão)
4. Clique em **Salvar e Aplicar**
5. Aguarde a reconexão automática

## Dicas Avançadas

- **Roaming**: Ative apenas se estiver fora da rede principal
- **5G SA / NSA**: Selecione na página de Modos de Rede
- **Teste de Conexão**: Use a página de Diagnósticos → Speedtest
- Se não conectar, tente APN genérico `internet` com Tipo PDN `IPv4v6`.

## Via Terminal (Avançado)

```bash
mmcli -m 0 --create-bearer='apn=zap.vivo.com.br'
```

**Problemas comuns**:
- APN errado → Sem conexão de dados
- Tipo PDN incorreto → IPv6 falhando

Consulte o [Troubleshooting](TROUBLESHOOTING.md) se persistir.
