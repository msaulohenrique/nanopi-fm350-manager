# 🌐 NanoPi FM350 Manager

**Gateway 5G/4G profissional open-source para NanoPi NEO3 Plus + Fibocom FM350-GL**

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-0.1.0-orange.svg)
![Platform](https://img.shields.io/badge/platform-ARM64%20%7C%20NanoPi-success.svg)
![5G](https://img.shields.io/badge/5G-Ready-brightgreen.svg)

## Instalação Rápida (Recomendado)

```bash
# 1. Baixe o projeto
wget https://github.com/msaulohenrique/nanopi-fm350-manager/archive/refs/heads/main.zip -O nanopi-fm350-manager.zip

# 2. Descompacte
unzip nanopi-fm350-manager.zip
cd nanopi-fm350-manager-main

# 3. Instale
sudo bash install.sh
```

**Após a instalação, acesse o painel:**
- `http://nanopi-5g.local`  
- ou `http://192.168.8.1`

**Usuário inicial**: `admin`  
**Senha inicial**: `admin123` (troque imediatamente)

## Documentação

- [📖 Instalação Completa](docs/INSTALACAO_E_USO.md)
- [❓ FAQ](docs/FAQ.md)
- [🔧 Troubleshooting](docs/TROUBLESHOOTING.md)
- [📶 Configuração APN 5G](docs/APN_5G.md)

## Recursos Principais

- Interface web responsiva em Português
- Gerenciamento completo do modem Fibocom FM350-GL
- Configuração avançada de APN 5G (Vivo, Claro, TIM...)
- Watchdog com auto-recuperação
- Firewall, NAT, DHCP e Port Forwarding
- SMS, GNSS, Logs e Diagnósticos
- Validação segura de formulários

## Hardware Suportado

- NanoPi NEO3 Plus
- Fibocom FM350-GL + Waveshare 5G Board

## Licença

MIT License © 2026

---

**Feito para entusiastas de redes móveis e projetos embarcados.**
```
