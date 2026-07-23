# NanoPi FM350 Manager - Instalação e Uso

## 1. Introdução
Projeto completo para transformar o **NanoPi NEO3 Plus + Fibocom FM350-GL** em um gateway 5G profissional com interface web.

## 2. Pré-requisitos
- NanoPi NEO3 Plus
- Fibocom FM350-GL + Waveshare 5G M.2 to Gigabit Ethernet
- Cartão microSD (≥ 8GB)
- Antenas externas 4G/5G
- Sistema: Armbian, Debian ARM64 ou FriendlyCore

## 3. Instalação

### Passo a Passo

1. **Transfira o arquivo** `nanopi-fm350-manager.zip` para o NanoPi.

2. Descompacte:
   ```bash
   unzip nanopi-fm350-manager.zip
   cd nanopi-fm350-manager
   ```

3. **Execute o instalador**:
   ```bash
   sudo bash install.sh
   ```

   **Opções úteis**:
   - `--offline`: Instalação sem internet
   - `--demo`: Modo demonstração (sem hardware)
   - `--repair`: Modo reparo

4. Aguarde a conclusão. O sistema configurará:
   - ModemManager
   - NetworkManager + NAT (LAN: 192.168.8.1/24)
   - Nginx + Backend FastAPI
   - Firewall básico

## 4. Primeiro Acesso

- URL: `http://nanopi-5g.local` ou `http://192.168.8.1`
- **Usuário**: `admin`
- **Senha inicial**: `admin123` → **Troque imediatamente**

## 5. Funcionalidades Principais

### Dashboard
- Status da conexão 5G/LTE
- Sinal, tráfego, temperatura

### Páginas Disponíveis
- **Logs do Sistema** (`/system-logs`)
- **Backup e Restauração** (`/backup-restore`)
- **Diagnósticos de Rede** (`/network-diagnostics`)
- **Atualizações** (`/system-updates`)
- **Firewall** (`/firewall-rules`)
- **Dispositivos Conectados** (`/connected-devices`)
- **Monitoramento de Tráfego** (`/traffic-analytics`)
- **Roteamento** (`/routing-settings`)
- **Informações do Sistema** (`/system-info`)
- **Gerenciamento de SIM** (`/sim-management`)
- **Alertas de Uso** (`/usage-alerts`)
- **Histórico de Conexão** (`/connection-history`)

### Validação de Formulários
Todas as páginas com formulários possuem validação em tempo real (IP, portas, PIN, limites, etc.).

## 6. Comandos Úteis

```bash
# Diagnóstico
sudo bash scripts/detector.sh

# Backup manual
sudo bash backup.sh

# Reiniciar serviços
sudo systemctl restart nanopi-fm350-api.service

# Logs
journalctl -u nanopi-fm350-api.service -f
```

## 7. Recuperação e Manutenção

- **Reset de senha**: `sudo bash reset-admin-password.sh`
- **Desinstalar**: `sudo bash uninstall.sh`
- **Atualizar**: `sudo bash update.sh`

## 8. Problemas Comuns

Consulte o **Guia Completo de Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

- **Modem não detectado**: Verifique USB e rode `lsusb`
- **Sem internet**: Verifique APN nas configurações de SIM
- **Painel inacessível**: Verifique IP e firewall

---

**Documentação completa em `docs/`**.  
Projeto desenvolvido para uso profissional.  
Qualquer dúvida, consulte os logs ou o diagnóstico. 

**Versão**: 0.1.0 | Data: Julho 2026
