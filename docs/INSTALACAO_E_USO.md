# Guia de Troubleshooting - NanoPi FM350 Manager

## Problemas Comuns e Soluções

### 1. Modem Não Detectado
**Sintomas**: ModemManager não mostra o FM350-GL.

**Soluções**:
```bash
lsusb | grep Fibocom
mmcli -L
sudo systemctl restart ModemManager
sudo bash scripts/detector.sh
```
Verifique conexão USB na Waveshare e alimentação externa.

### 2. Sem Conexão de Dados (APN)
**Soluções**:
- Verifique APN na página **Configuração de APN**
- APNs comuns:
  - Vivo: `zap.vivo.com.br`
  - Claro: `claro.br`
- Reinicie bearer: botão "Reconectar" no dashboard

### 3. Painel Web Inacessível
```bash
sudo systemctl status nginx
sudo systemctl status nanopi-fm350-api.service
ip addr show
```
Verifique firewall e IP da LAN (192.168.8.1).

### 4. Velocidade Baixa / Sinal Fraco
- Verifique antenas
- Use página **Bandas** para bloquear bandas ruins
- Consulte **Diagnósticos de Rede**

### 5. Erros de PIN/SIM
- Página **Gerenciamento de SIM**
- Use comando AT via terminal seguro: `AT+CPIN?`

### 6. Watchdog Reiniciando Constantemente
Ajuste configurações na página de **Alertas** ou desabilite níveis agressivos.

### 7. Logs Úteis
```bash
journalctl -u nanopi-fm350-api.service -n 100
mmcli -m 0
dmesg | grep -i usb
```

### 8. Reset Completo
```bash
sudo bash uninstall.sh --keep-configs
sudo bash install.sh
```

## Gerar Pacote de Diagnóstico
Na interface web → **Diagnósticos** → "Gerar Pacote Completo"

**Ainda com problema?**  
Execute `sudo bash diagnostics.sh` e envie o relatório.
