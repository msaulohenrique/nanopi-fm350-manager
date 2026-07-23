# FAQ - NanoPi FM350 Manager

## Perguntas Frequentes

### 1. O projeto suporta 5G SA?
**Sim**, quando o firmware do FM350-GL e a operadora suportarem. Use a página de Modos de Rede para selecionar "5G SA".

### 2. Posso usar com duas operadoras?
Sim. O sistema suporta múltiplos perfis de APN e alternância manual/automática (preparado para failover).

### 3. Como faço backup das configurações?
Use a página **Backup e Restauração** ou execute:
```bash
sudo bash backup.sh
```

### 4. O painel funciona offline?
Sim. Todo o frontend é estático e o backend roda localmente. Apenas testes de velocidade e atualizações precisam de internet.

### 5. Qual a diferença entre MBIM e QMI?
O instalador detecta automaticamente. MBIM é preferencial no FM350-GL para estabilidade.

### 6. Como resetar a senha do admin?
```bash
sudo bash reset-admin-password.sh
```

### 7. O watchdog reinicia o NanoPi automaticamente?
Só em último caso (nível 10). Você pode configurar o nível de agressividade.

### 8. Suporta VoLTE / Chamadas?
Experimental. Depende do firmware e operadora. Áudio completo nem sempre está disponível.

### 9. Como atualizo o software?
```bash
sudo bash update.sh
```
Ou use a página **Atualizações**.

### 10. Posso usar sem Waveshare (direto no NanoPi)?
Não recomendado. A Waveshare facilita o acesso USB 3.0 ao modem.

### 11. Consome muita energia?
Em repouso: ~5-8W (NanoPi + modem). Recomenda-se fonte 5V/4A para estabilidade.

### 12. Onde vejo os logs completos?
Página **Logs do Sistema** ou via terminal:
```bash
journalctl -u nanopi-fm350-*
```

**Mais dúvidas?** Consulte `TROUBLESHOOTING.md` ou gere o pacote de diagnóstico na interface web.
