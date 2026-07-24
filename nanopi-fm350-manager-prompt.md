# MISSÃO — GERAR IMAGEM/ZIP COMPLETO PARA NANOPI NEO3 PLUS + FIBOCOM FM350-GL

Você atuará como arquiteto Linux embarcado, engenheiro de redes móveis 4G/5G, desenvolvedor full-stack, especialista em modems Fibocom, ModemManager, MBIM, NetworkManager, systemd, segurança, roteamento e interfaces web responsivas.
Seu objetivo é criar um projeto completo e instalável para transformar um:
- FriendlyElec NanoPi NEO3 Plus
- Fibocom FM350-GL
- placa Waveshare 5G M.2 to Gigabit Ethernet
- cartão microSD
- sistema Debian/Ubuntu ARM64 ou FriendlyWrt compatível
em um gateway 4G/5G profissional, totalmente administrável pelo navegador.
O resultado final deve ser entregue em um arquivo ZIP pronto para ser copiado para o microSD e instalado no NanoPi.
O usuário não deve precisar programar, editar arquivos manualmente ou conhecer comandos Linux avançados.
## 1. RESULTADO FINAL OBRIGATÓRIO

**Gerar um arquivo semelhante a:**
- nanopi-fm350-manager.zip
**O ZIP deverá conter:**
```text
nanopi-fm350-manager/
├── install.sh
├── uninstall.sh
├── update.sh
├── repair.sh
├── diagnostics.sh
├── backup.sh
├── restore.sh
├── reset-admin-password.sh
├── README.md
├── CHANGELOG.md
├── LICENSE
├── VERSION
├── config/
├── backend/
├── frontend/
├── scripts/
├── systemd/
├── nginx/
├── network/
├── firewall/
├── profiles/
├── migrations/
├── docs/
├── tests/
└── releases/
O usuário deverá conseguir:
descompactar o ZIP;
copiar a pasta para o microSD ou NanoPi;
acessar a pasta;
executar:

```bash
sudo bash install.sh
```

Ao final, o instalador deverá informar:
Instalação concluída.
Acesse o painel em:
http://IP-DO-NANOPI
ou
[http://nanopi-5g.local](http://nanopi-5g.local)
Usuário inicial: admin
Senha inicial: definida durante a instalação
```

## 2. HARDWARE DO PROJETO

**Considere a seguinte topologia:**
- Antenas 4G/5G
- │
- Fibocom FM350-GL
- │ M.2 B-Key
- Waveshare 5G M.2 to Gigabit Ethernet
- │
- ├── alimentação própria
- └── USB 3.0
- │
- FriendlyElec NanoPi NEO3 Plus
- │
- └── Ethernet Gigabit
- │
- └── porta WAN secundária do Ubiquiti Dream Router 7
A placa Waveshare será conectada por USB ao NanoPi.
**O sistema deve usar o NanoPi para:**
- acessar o FM350-GL
- configurar o modem
- controlar a conexão móvel
- criar a conexão de internet
- encaminhar a internet para a Ethernet
- fornecer DHCP, NAT e firewall
- expor o painel web
- monitorar o modem
recuperar automaticamente a conexão.
A Waveshare deverá permanecer alimentada por fonte própria adequada.
## 3. SISTEMAS OPERACIONAIS

**O projeto deve priorizar:**
- Debian ARM64
- Ubuntu Server ARM64
- FriendlyCore
- Armbian
FriendlyWrt, quando tecnicamente possível.
**O instalador deverá detectar automaticamente:**
- distribuição
- versão
- arquitetura
- kernel
- systemd
- gerenciador de pacotes
- NetworkManager
- interfaces Ethernet
- interfaces USB
- suporte MBIM
- suporte QMI
- suporte MHI
- portas seriais
ModemManager.
Caso o sistema não seja compatível, mostrar uma mensagem clara informando o motivo e os sistemas recomendados.
Nunca continuar silenciosamente após um erro crítico.
## 4. DETECÇÃO DO FM350-GL

- O instalador deverá executar uma auditoria completa do modem.
**Detectar:**
- `lsusb`
- `lsusb -t`
- `lspci`
- `ip -br link`
- `nmcli device`
- `mmcli -L`
- `dmesg`
**Procurar automaticamente:**
- /dev/ttyUSB*
- /dev/ttyACM*
- /dev/cdc-wdm*
- /dev/wwan*
- /dev/mhi*
- /dev/serial/by-id/*
**Identificar:**
- VID e PID USB
- fabricante
- modelo
- IMEI
- firmware
- porta AT principal
- porta AT secundária
- porta de diagnóstico
- porta GNSS/NMEA
- interface MBIM
- interface QMI
- interface RMNET
- interface MHI
- interface de dados
possível interface USB Audio.
O sistema não deverá assumir que /dev/ttyUSB2 sempre será a porta AT.
**Criar um detector que teste todas as portas candidatas com:**
- `AT`
- `ATI`
- `AT+CGMI`
- `AT+CGMM`
- `AT+CGMR`
- `AT+GSN`
- `AT+CPIN?`
- `AT+COPS?`
- `AT+CSQ`
A porta que responder corretamente deverá ser salva por identificador persistente de /dev/serial/by-id/, sempre que possível.
## 5. CAMADA DE COMPATIBILIDADE

Criar uma camada abstrata de modem.
O backend não deve chamar comandos específicos do FM350 diretamente em todos os arquivos.
**Criar interfaces como:**
- ModemAdapter
- NetworkAdapter
- MessagingAdapter
- VoiceAdapter
- BandAdapter
- CellAdapter
- GnssAdapter
- DiagnosticsAdapter
**Implementar pelo menos:**
- FibocomFM350Adapter
- ModemManagerAdapter
- GenericATAdapter
- MBIMAdapter
Antes de habilitar qualquer função no painel, o sistema deve verificar se ela é realmente suportada.
**Cada recurso deverá ter um estado:**
- supported
- unsupported
- experimental
- unavailable
- permission_required
- firmware_limited
- carrier_limited
Nunca apresentar uma função como garantida quando depender do firmware HP, Lenovo, Fibocom genérico ou da operadora.
## 6. TECNOLOGIAS RECOMENDADAS

- Backend
**Usar preferencialmente:**
- Python 3
- FastAPI
- Uvicorn ou Gunicorn
- Pydantic
- SQLAlchemy
- SQLite
- Alembic
- pyserial
- psutil
- asyncio
- subprocess controlado
WebSocket ou Server-Sent Events.
- Frontend
**Usar:**
- React
- TypeScript
- Vite
- interface responsiva
- PWA
- Tailwind CSS ou CSS modular
- gráficos leves
- sem dependência obrigatória de internet
todos os assets armazenados localmente.
- Serviços Linux
**Usar:**
- ModemManager
- NetworkManager
- libmbim-utils
- libqmi-utils
- usb-modeswitch
- nftables
- dnsmasq ou NetworkManager Shared Mode
- nginx
- avahi-daemon
- systemd
- chrony
logrotate.
Evitar Docker como dependência obrigatória, pois o hardware possui recursos limitados.
O projeto pode oferecer Docker opcional, mas a instalação padrão deve ser nativa.
## 7. DASHBOARD PRINCIPAL

Criar uma interface web profissional, limpa, responsiva e adaptada para:
- computador
- tablet
- celular
tela pequena.
Não criar aparência genérica de dashboard feita por IA.
Usar boa hierarquia visual, espaçamento consistente, legibilidade e componentes reutilizáveis.
**A página inicial deverá mostrar:**
- estado geral da conexão
- conectado ou desconectado
- operadora
- tecnologia atual
- 3G, LTE, LTE-A, 5G NSA ou 5G SA
- APN
- IPv4
- IPv6
- gateway
- DNS
- interface de dados
- tempo conectado
- tráfego recebido
- tráfego enviado
- consumo do dia
- consumo do mês
- velocidade atual
- latência
- perda de pacotes
- temperatura do modem
- temperatura do NanoPi
- uso de CPU
- uso de RAM
- uso do armazenamento
- uptime
- última reconexão
último erro.
**Criar indicador visual de saúde:**
- Excelente
- Bom
- Regular
- Ruim
- Crítico
- Sem conexão
## 8. MÉTRICAS DE SINAL

**Exibir quando disponíveis:**
- RSSI
- RSRP
- RSRQ
- SINR
- CQI
- BER
- banda LTE
- banda NR
- EARFCN
- NR-ARFCN
- PCI
- TAC
- Cell ID
- eNodeB
- gNodeB
- MCC
- MNC
- PLMN
- carrier aggregation
- banda primária
- bandas secundárias
- largura de banda
- modo duplex
- MIMO
NSA ou SA.
**Criar:**
- gráfico de sinal ao longo do tempo
- gráfico de latência
- gráfico de tráfego
- histórico de células
- histórico de bandas
- histórico de reconexões
histórico de operadoras.
Armazenar métricas em SQLite com política de retenção configurável.
**Exemplo:**
- dados detalhados: 7 dias
- dados agregados: 90 dias
totais diários: 1 ano.
## 9. CONFIGURAÇÃO DA OPERADORA

**Criar tela para:**
- seleção automática de operadora
- busca manual de redes
- lista de redes encontradas
- nome da operadora
- código MCC/MNC
- tecnologia disponível
- registro manual
- voltar ao modo automático
- habilitar ou desabilitar roaming
- mostrar estado de registro
- exibir erro de registro
- mostrar operadora doméstica
mostrar operadora visitada.
**Permitir criar perfis de operadora contendo:**
- nome
- APN
- usuário
- senha
- autenticação
- IPv4
- IPv6
- IPv4v6
- roaming
- MTU
- DNS automático
- DNS personalizado
- métrica da rota
- rede preferida
- bandas preferidas
**Adicionar perfis iniciais editáveis para:**
- Vivo
- Claro
- TIM
- Correios Celular
perfil genérico.
Não assumir APNs sem permitir revisão do usuário.
## 10. CONFIGURAÇÃO DO SIM

**Criar tela para:**
- estado do SIM
- SIM detectado
- SIM ausente
- SIM bloqueado
- SIM com PIN
- SIM com PUK
- desbloquear PIN
- alterar PIN
- habilitar PIN
- desabilitar PIN
- ICCID
- IMSI
- número da linha, quando disponível
- operadora do SIM
- tecnologia suportada
roaming.
Nunca armazenar PIN ou PUK em texto simples.
Caso seja necessário armazenar o PIN para reconexão automática, usar criptografia local e permissões restritas.
## 11. MODOS DE REDE

**Criar controles para:**
- automático
- 3G
- somente LTE
- LTE preferencial
- LTE + 5G
- 5G preferencial
- somente 5G
- 5G NSA
- 5G SA
- NSA + SA
restaurar configuração padrão.
Os modos deverão ser disponibilizados apenas quando o modem realmente aceitar os respectivos comandos.
**Após qualquer alteração:**
- validar entrada
- mostrar aviso
- aplicar configuração
- consultar o modem novamente
- confirmar se foi aplicada
- reverter em caso de falha
registrar no log de auditoria.
## 12. CONTROLE DE BANDAS

Criar uma interface completa para seleção de bandas.
**Separar:**
- Bandas LTE
- Bandas 5G NSA
- Bandas 5G SA
**Permitir:**
- selecionar todas
- desmarcar todas
- selecionar bandas individuais
- criar presets
- salvar perfil
- aplicar perfil
- restaurar bandas automáticas
- mostrar bandas atualmente permitidas
- mostrar bandas atualmente em uso
mostrar bandas suportadas pelo modem.
**Criar presets editáveis como:**
- Automático
- Estabilidade
- Maior cobertura
- Maior velocidade
- LTE somente
- 5G NSA
- 5G SA
- Personalizado
Não usar comandos AT destrutivos sem confirmar suporte.
**Antes de executar comandos de máscara de bandas:**
- consultar configuração atual
- salvar backup
- validar máscara
- aplicar
- ler novamente
- confirmar resultado
permitir rollback.
## 13. BLOQUEIO DE CÉLULA

Implementar como recurso experimental.
**Quando suportado, permitir:**
- bloquear EARFCN
- bloquear NR-ARFCN
- selecionar PCI
- selecionar banda
- fixar célula
- remover bloqueio
- salvar célula favorita
- testar célula por tempo determinado
voltar automaticamente caso perca conexão.
**Criar proteção obrigatória:**
Se o bloqueio causar perda de conexão por determinado período, remover automaticamente o bloqueio e restaurar o perfil anterior.
Nunca permitir que o usuário fique permanentemente sem acesso ao painel devido a uma configuração de célula.
## 14. CONEXÃO DE DADOS

**Implementar suporte preferencial a:**
- ModemManager + NetworkManager
- MBIM
- QMI
- MHI/RMNET
fallback por comandos AT.
**Criar ações:**
- conectar
- desconectar
- reconectar
- renovar IP
- reiniciar sessão
- reiniciar modem
- modo avião
- sair do modo avião
- reset lógico
- reset USB
reset físico por GPIO, quando configurado.
**Mostrar:**
- bearer
- interface
- endereço IP
- gateway
- DNS
- MTU
- rota padrão
- tempo conectado
motivo da desconexão.
## 15. ROTEAMENTO E DHCP

A Ethernet do NanoPi deverá fornecer internet para o Ubiquiti Dream Router 7.
O instalador deverá detectar a interface Ethernet física e permitir selecioná-la.
**Configuração padrão sugerida:**
**NanoPi LAN:**
- 192.168.8.1/24
**DHCP:**
- 192.168.8.100 até 192.168.8.200
**Permitir editar:**
- IP da LAN
- máscara
- faixa DHCP
- lease time
- DNS
- MTU
- hostname
- modo NAT
- modo passthrough, quando tecnicamente possível
modo bridge, quando tecnicamente possível.
**Configurar:**
- IP forwarding
- NAT
- masquerade
- firewall
- encaminhamento da interface móvel para Ethernet
bloqueio de acesso não autorizado ao painel.
O painel deverá continuar acessível pela Ethernet mesmo se a conexão 4G/5G cair.
## 16. FIREWALL

Usar nftables.
**Criar regras para:**
- permitir painel web pela LAN
- permitir SSH apenas quando habilitado
- bloquear administração vinda da interface móvel
- bloquear acesso externo por padrão
- permitir DNS e DHCP na LAN
- permitir encaminhamento LAN para WAN móvel
- impedir exposição do backend
- impedir comandos arbitrários
- proteção básica contra força bruta
- rate limit do login
rate limit da API.
**Adicionar no painel:**
- habilitar SSH
- desabilitar SSH
- alterar porta
- mostrar sessões
- exportar regras
restaurar firewall.
Nunca abrir o painel diretamente para a internet móvel por padrão.
## 17. SMS

Criar um módulo completo de SMS.
**Funções:**
- caixa de entrada
- enviados
- rascunhos
- não lidos
- arquivados
- excluídos
- busca
- paginação
- envio
- resposta
- encaminhamento
- exclusão
- marcar como lido
- atualizar automaticamente
- suporte a SMS multipartes
- suporte a UCS-2
- caracteres acentuados
- identificação do remetente
- data e hora
status de entrega, quando disponível.
**Usar preferencialmente:**
- ModemManager Messaging API
- fallback com comandos AT CMGF, CMGL, CMGR, CMGS, CMGD
modo PDU quando necessário.
**Criar proteção contra:**
- mensagens duplicadas
- concatenação incorreta
- caracteres corrompidos
- envio repetido
- timeout
modem ocupado.
**Permitir notificações opcionais por:**
- webhook
- Telegram
- e-mail
API local.
Não implementar integração com WhatsApp sem API oficial ou configuração explícita.
## 18. CHAMADAS

Criar módulo de chamadas como experimental.
**Detectar suporte real para:**
- `ATD;`
- `ATA;`
- `ATH;`
- CLCC
- CLIP
- chamada recebida
- chamada realizada
- número do chamador
- duração
- histórico
- atender
- rejeitar
encerrar.
**Detectar:**
- registro IMS
- VoLTE
- suporte de voz
- USB Audio
- ALSA
- PCM
interfaces de áudio expostas pelo modem.
**O painel deve diferenciar:**
- Controle de chamada disponível
- Áudio de chamada disponível
- Somente sinalização disponível
- Chamadas não suportadas pelo firmware
- Chamadas não suportadas pela operadora
Nunca prometer áudio funcional apenas porque o modem aceita ATD.
**Se não houver interface de áudio:**
- permitir apenas detecção e controle, se possível
- mostrar aviso claro
não simular que a chamada está utilizável.
## 19. GNSS E LOCALIZAÇÃO

**Quando o firmware e hardware suportarem GNSS:**
- detectar porta NMEA
- iniciar GNSS
- parar GNSS
- exibir latitude
- longitude
- altitude
- velocidade
- precisão
- número de satélites
- data da última posição
- estado do fix
- exportar GPX
exibir histórico.
Não depender de serviços externos de mapas para o funcionamento básico.
Mapas online poderão ser opcionais.
## 20. WATCHDOG E AUTORRECUPERAÇÃO

Criar serviço de watchdog independente do painel.
**O watchdog deverá avaliar:**
- modem detectado
- SIM disponível
- modem registrado
- bearer ativo
- interface com IP
- gateway acessível
- DNS funcionando
- acesso externo
- latência
perda de pacotes.
**Criar recuperação progressiva:**
- Nível 1: renovar DNS
- Nível 2: renovar rota
- Nível 3: desconectar e reconectar
- Nível 4: recriar bearer
- Nível 5: alternar modo avião
- Nível 6: AT+CFUN
- Nível 7: reiniciar ModemManager
- Nível 8: reset USB
- Nível 9: reset físico por GPIO
- Nível 10: reiniciar NanoPi
**Cada nível deve possuir:**
- intervalo mínimo
- contador
- cooldown
- limite por hora
- log
- motivo
resultado.
Impedir loops infinitos de reinicialização.
**Permitir configurar:**
- host de teste
- intervalo
- timeout
- quantidade de falhas
- níveis habilitados
- reinício automático
horário de manutenção.
## 21. FAILOVER ENTRE OPERADORAS OU PERFIS

**Mesmo que inicialmente exista apenas um SIM, preparar o sistema para:**
- vários perfis APN
- eSIM, quando suportado
- múltiplos SIMs
- múltiplos modems USB
- alternância automática de perfil
- alternância de operadora
- fallback entre 5G e LTE
- fallback entre APNs
fallback entre células.
A troca automática deverá ser configurável.
**Exemplo:**
- Perfil principal: Correios Celular
- Perfil secundário: TIM
- Fallback de rede: 5G → LTE
Não tentar trocar de operadora de forma incompatível com o SIM ou contrato.
## 22. TESTE DE VELOCIDADE

**Criar teste opcional de:**
- download
- upload
- latência
- jitter
perda.
Evitar executar automaticamente com frequência, pois consome franquia de dados.
Exigir ação manual ou agendamento explícito.
Permitir configurar limite mensal para testes.
**Registrar:**
- data
- operadora
- banda
- célula
- RSRP
- SINR
resultado.
## 23. CONSUMO DE DADOS

**Criar contadores de:**
- sessão atual
- diário
- semanal
- mensal
- ciclo personalizado
- upload
- download
total.
**Permitir:**
- definir data de renovação da franquia
- definir limite mensal
- alerta de 50%
- alerta de 75%
- alerta de 90%
- alerta de 100%
- bloquear testes de velocidade ao atingir limite
exportar CSV.
Deixar claro que a medição local pode diferir da medição oficial da operadora.
## 24. ADMINISTRAÇÃO DO SISTEMA

**Criar páginas para:**
- usuários
- senha
- sessões ativas
- idioma
- fuso horário
- data e hora
- hostname
- rede LAN
- atualização
- backup
- restauração
- logs
- diagnóstico
- reboot
- desligamento
- serviços
- armazenamento
- temperatura
configuração avançada.
**Criar níveis:**
- Administrador
- Operador
- Visualização
**Usar:**
- senha com hash Argon2id ou bcrypt
- cookies seguros
- proteção CSRF
- expiração de sessão
- bloqueio temporário após várias tentativas
log de auditoria.
No primeiro acesso, obrigar troca ou definição de senha.
## 25. TERMINAL AT SEGURO

Criar uma tela de terminal AT avançado, desabilitada por padrão.
**Ela deverá:**
- exigir senha do administrador
- mostrar aviso de risco
- permitir apenas comandos AT
- bloquear comandos de shell
- limitar tamanho
- definir timeout
- registrar todos os comandos
- ocultar dados sensíveis
- permitir lista de comandos seguros
exigir confirmação para comandos destrutivos.
**Bloquear inicialmente comandos que possam:**
- apagar firmware
- alterar IMEI
- apagar calibração
- modificar NV permanentemente
- bloquear o modem
- alterar partições
iniciar download mode.
Nunca oferecer alteração de IMEI.
## 26. LOGS E DIAGNÓSTICOS

**Criar logs separados:**
- application.log
- modem.log
- network.log
- watchdog.log
- sms.log
- calls.log
- security.log
- audit.log
- installer.log
- update.log
Usar logrotate.
**Criar botão:**
- Gerar pacote de diagnóstico
**O pacote deverá conter:**
- sistema operacional
- kernel
- arquitetura
- lsusb
- lsusb -t
- lspci
- ip link
- ip route
- nftables
- nmcli
- mmcli
- estado dos serviços
- dmesg filtrado
- portas detectadas
- firmware
- métricas
últimos erros.
**Antes de gerar, remover ou mascarar:**
- senhas
- PIN
- PUK
- tokens
- números completos sensíveis
- IMSI completo
- ICCID completo
- conteúdo de SMS
- cookies
chaves privadas.
## 27. BACKUP E RESTAURAÇÃO

**O backup deverá incluir:**
- configurações
- perfis
- usuários
- histórico opcional
- regras
- presets de bandas
- configurações de watchdog
- certificados
banco SQLite.
**Criar backup:**

```bash
sudo bash backup.sh
```

**Criar restauração:**

```bash
sudo bash restore.sh arquivo-backup.tar.gz
```

O painel também deverá permitir exportar e restaurar.
O backup deverá ser criptografado opcionalmente.
## 28. INSTALADOR

O install.sh deverá ser idempotente.
**Ele deverá:**
- validar execução como root
- verificar arquitetura ARM64
- detectar sistema
- verificar espaço
- verificar internet, quando necessária
- instalar dependências
- detectar interfaces
- detectar modem
- instalar backend
- compilar frontend
- criar usuário de serviço
- criar diretórios
- definir permissões
- configurar banco
- executar migrations
- configurar systemd
- configurar nginx
- configurar NetworkManager
- configurar nftables
- configurar DHCP
- habilitar avahi
- iniciar serviços
- executar testes
- gerar relatório
exibir endereço do painel.
**O instalador deverá aceitar:**

```bash
sudo bash install.sh
```

```bash
sudo bash install.sh --non-interactive
```

```bash
sudo bash install.sh --repair
```

```bash
sudo bash install.sh --offline
```

```bash
sudo bash install.sh --skip-modem-check
```

```bash
sudo bash install.sh --interface eth0
```

Criar menu interativo amigável.
**Nunca apagar uma configuração de rede existente sem:**
- detectar
- criar backup
- mostrar aviso
permitir restauração.
## 29. INSTALAÇÃO OFFLINE

Como o usuário deseja copiar tudo para o microSD, preparar opção de instalação offline.
**Criar no ZIP:**
- packages/
- vendor/
- wheels/
- node-dist/
**Quando possível, incluir:**
- wheels Python ARM64
- frontend já compilado
- dependências JavaScript já empacotadas
- arquivos estáticos
scripts de instalação.
Não incluir pacotes proprietários sem licença de redistribuição.
**Criar dois modos:**
- Modo online
- Modo offline
No modo offline, o instalador deverá verificar se todos os pacotes necessários estão presentes.
Se algo estiver faltando, informar exatamente qual pacote precisa ser obtido.
## 30. ATUALIZAÇÃO

**Criar:**

```bash
sudo bash update.sh
```

**O atualizador deverá:**
- criar backup
- verificar versão
- validar integridade
- parar serviços
- atualizar arquivos
- executar migrations
- preservar configuração
- iniciar serviços
- executar health check
reverter em caso de falha.
Criar sistema de versão sem depender obrigatoriamente de servidor externo.
Permitir atualização por upload de um ZIP no painel.
## 31. DESINSTALAÇÃO

**Criar:**

```bash
sudo bash uninstall.sh
```

**Perguntar se deseja:**
- remover apenas aplicação
- manter configurações
- manter banco
- remover dependências
- restaurar rede anterior
- remover firewall
remover usuário de serviço.
Sempre criar backup antes da remoção.
## 32. SERVIÇOS SYSTEMD

**Criar serviços separados:**
- nanopi-fm350-api.service
- nanopi-fm350-worker.service
- nanopi-fm350-watchdog.service
- nanopi-fm350-metrics.service
- nanopi-fm350-sms.service
- nanopi-fm350-gnss.service
- nanopi-fm350-recovery.service
**Usar:**
- usuário sem privilégios
- restart automático
- limites de recurso
- proteção de filesystem
- NoNewPrivileges
- PrivateTmp
- ProtectSystem
- ProtectHome
capability mínima.
Não executar todo o backend como root.
Criar helper privilegiado estritamente limitado para operações que realmente precisem de root.
## 33. API

Criar API documentada.
**Exemplos:**
- GET /api/health
- GET /api/system/status
- GET /api/modem
- GET /api/modem/signal
- GET /api/modem/cell
- GET /api/modem/bands
- POST /api/modem/bands
- POST /api/modem/reset
- GET /api/operators
- POST /api/operators/scan
- POST /api/operators/register
- GET /api/profiles
- POST /api/profiles
- POST /api/connection/connect
- POST /api/connection/disconnect
- GET /api/sms
- POST /api/sms/send
- GET /api/calls
- POST /api/calls/dial
- POST /api/calls/answer
- POST /api/calls/hangup
- GET /api/metrics
- GET /api/logs
- POST /api/diagnostics
Usar autenticação e autorização em todas as rotas sensíveis.
Não expor Swagger publicamente sem autenticação.
## 34. TESTES

**Criar:**
- testes unitários
- testes de API
- testes de parsing AT
- testes de ModemManager
- mocks do modem
- testes de máscara de bandas
- testes de SMS
- testes de watchdog
- testes de recuperação
- testes do instalador
- testes de segurança
testes do frontend.
**Criar modo de demonstração sem modem:**

```bash
sudo bash install.sh --demo
```

No modo demo, o painel deverá funcionar com dados simulados.
## 35. DOCUMENTAÇÃO

**Criar documentos completos:**
- README.md
- docs/INSTALLATION.md
- docs/HARDWARE.md
- docs/FIRST_BOOT.md
- docs/NETWORK.md
- docs/MODEM_DETECTION.md
- docs/FM350_COMMANDS.md
- docs/SMS.md
- docs/CALLS.md
- docs/BANDS.md
- docs/CELL_LOCK.md
- docs/WATCHDOG.md
- docs/SECURITY.md
- docs/BACKUP_RESTORE.md
- docs/TROUBLESHOOTING.md
- docs/UDR7_INTEGRATION.md
- docs/OFFLINE_INSTALL.md
- docs/DEVELOPMENT.md
Explicar como integrar ao Ubiquiti Dream Router 7.
**Incluir exemplo:**
**NanoPi:**
- 192.168.8.1
**UDR7 WAN secundária:**
- DHCP
**Explicar também:**
- como testar USB
- como identificar portas
- como conferir ModemManager
- como gerar diagnóstico
- como recuperar acesso
- como resetar senha
- como voltar rede padrão
como restaurar configurações.
## 36. SEGURANÇA

**Implementar no mínimo:**
- validação de entrada
- prevenção contra command injection
- prevenção contra path traversal
- autenticação
- autorização
- sessões seguras
- rate limiting
- CSRF
- XSS
- CSP
- headers de segurança
- logs de auditoria
- permissões Linux
- isolamento de serviços
- proteção dos segredos
- sanitização de logs
bloqueio de terminal shell.
**Não usar:**
- os.system(user_input)
Não concatenar entradas do usuário em comandos.
Usar argumentos separados em subprocess.run.
Criar lista explícita de comandos permitidos.
## 37. REQUISITOS DE UX

A interface deverá estar inicialmente em português do Brasil.
**Preparar internacionalização para:**
- português
- inglês
espanhol.
**Criar:**
- modo claro
- modo escuro
- feedback visual
- skeleton loading
- tratamento de erro
- mensagens explicativas
- confirmação para ações de risco
- ajuda contextual
- tela de primeiro acesso
assistente de configuração inicial.
**O assistente inicial deverá perguntar:**
- senha do administrador
- nome do dispositivo
- fuso horário
- interface LAN
- IP LAN
- APN
- operadora
- modo de rede
- watchdog
integração com UDR7.
## 38. RECURSOS LIMITADOS

O NanoPi NEO3 Plus tem recursos limitados.
**O sistema deve:**
- reduzir uso de RAM
- evitar processos desnecessários
- evitar banco pesado
- evitar Docker obrigatório
- limitar tamanho dos logs
- agregar métricas antigas
- evitar gráficos pesados
- usar frontend estático
- usar SQLite
- limitar workers
- evitar polling excessivo
- usar cache
usar WebSocket ou SSE apenas quando necessário.
**Criar metas:**
- RAM do projeto em repouso: preferencialmente abaixo de 300 MB
- CPU em repouso: preferencialmente abaixo de 5%
- Espaço inicial: preferencialmente abaixo de 1,5 GB
## 39. VALIDAÇÃO FINAL

**Antes de gerar o ZIP, executar:**
- `lint`
- `typecheck`
- testes backend
- testes frontend
- build frontend
- verificação de shell scripts
- verificação de permissões
- verificação de systemd
- verificação de nginx
- verificação de nftables
- verificação de migrations
- teste de instalação em ambiente limpo
- teste de atualização
- teste de desinstalação
Usar shellcheck nos scripts.
Usar validação de YAML, JSON, TOML e arquivos de configuração.
**Gerar:**
- BUILD_REPORT.md
- TEST_REPORT.md
- SECURITY_REPORT.md
- COMPATIBILITY_REPORT.md
## 40. GERAÇÃO DO ZIP

**Ao final:**
- remover arquivos temporários
- remover segredos
- remover caches
- remover .env
- remover node_modules, quando não necessário
- incluir frontend compilado
- incluir checksums
- gerar manifesto
compactar o projeto.
**Criar:**
- nanopi-fm350-manager-vX.Y.Z.zip
- nanopi-fm350-manager-vX.Y.Z.zip.sha256
**Gerar também:**
- RELEASE_NOTES.md
- MANIFEST.txt
**Exibir no terminal:**
Projeto concluído.
**Arquivos gerados:**
- ./releases/nanopi-fm350-manager-vX.Y.Z.zip
- ./releases/nanopi-fm350-manager-vX.Y.Z.zip.sha256
**Para instalar:**
## 1. Copie o ZIP para o NanoPi ou microSD.

## 2. Descompacte.

## 3. Entre na pasta.

## 4. Execute:

```bash
sudo bash install.sh
```

## 41. REGRAS DE EXECUÇÃO DO AGENTE

Você deve executar o projeto até a conclusão.
Não pare apenas na criação de documentação ou estrutura vazia.
Não criar arquivos com apenas TODO.
Não criar funções fictícias sem implementação.
Não considerar o projeto concluído enquanto o ZIP não tiver sido gerado.
**Caso uma função dependa de hardware não conectado:**
- implementar a estrutura real
- criar mock
- criar detector
- criar teste
- documentar
marcar como não validada em hardware.
Não inventar respostas de comandos AT.
Criar tabelas de compatibilidade baseadas em detecção.
**Manter um arquivo:**
- PROGRESS.md
Atualizá-lo após cada etapa.
**Manter também:**
- DECISIONS.md
- KNOWN_LIMITATIONS.md
- HARDWARE_VALIDATION_CHECKLIST.md
**Quando encontrar erro:**
- registrar
- investigar
- corrigir
- executar novamente
documentar o resultado.
Não solicitar autorização para continuar entre etapas normais.
**Use agentes paralelos quando disponíveis para:**
- backend
- frontend
- Linux/rede
- modem
- segurança
- testes
documentação.
Ao final, revisar a integração entre todas as partes.
## 42. FASES OBRIGATÓRIAS

**Executar nesta ordem:**
- **FASE 1 — auditoria do ambiente**
- **FASE 2 — arquitetura**
- **FASE 3 — estrutura do repositório**
- **FASE 4 — detector do hardware**
- **FASE 5 — backend**
- **FASE 6 — conexão móvel**
- **FASE 7 — roteamento**
- **FASE 8 — SMS**
- **FASE 9 — chamadas experimentais**
- **FASE 10 — bandas e células**
- **FASE 11 — watchdog**
- **FASE 12 — frontend**
- **FASE 13 — segurança**
- **FASE 14 — instalador**
- **FASE 15 — instalação offline**
- **FASE 16 — testes**
- **FASE 17 — documentação**
- **FASE 18 — build da versão**
- **FASE 19 — geração do ZIP**
- **FASE 20 — relatório final**
## 43. OBSERVAÇÃO SOBRE IMAGEM DE MICROSD

O principal produto deverá ser o ZIP instalável.
Opcionalmente, caso o ambiente permita manipular imagens ARM64 com segurança, criar também um script:
- build-image.sh
**Esse script poderá:**
- receber uma imagem Debian/Armbian compatível
- montar a imagem
- copiar o instalador
- configurar primeiro boot
- expandir filesystem
- habilitar SSH
- configurar hostname
preparar instalação automática.
Não distribuir uma imagem .img sem validar compatibilidade específica com o NanoPi NEO3 Plus.
Priorizar o ZIP, pois ele pode ser usado sobre uma imagem oficial compatível.
## 44. ENTREGA

**Ao concluir, apresente:**
- caminho do ZIP
- checksum SHA-256
- versão
- tamanho
- sistemas compatíveis
- recursos implementados
- recursos experimentais
- limitações conhecidas
- instruções para copiar para o microSD
- instruções de primeiro boot
- instruções de instalação
instruções de recuperação.
O trabalho somente estará concluído quando existir um ZIP funcional, validado e documentado.
