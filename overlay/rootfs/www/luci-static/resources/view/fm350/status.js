'use strict';
'require view';
'require dom';
'require fs';
'require poll';
'require ui';

const strings = {
	en: {
		title: 'FM350 Modem Manager', description: 'Live status and safe controls for the Fibocom FM350-GL cellular connection.',
		connection: 'Connection', hardware: 'Hardware', sim: 'SIM', operator: 'Operator', registration: 'Registration',
		signal: 'Signal', device: 'AT port', interface: 'Data interface', apn: 'APN', ip: 'IPv4 address', gateway: 'Gateway',
		dns: 'DNS servers', uptime: 'Connected time', connected: 'Connected', connecting: 'Connecting', disconnected: 'Disconnected',
		unknown: 'Unknown', home: 'Home network', roaming: 'Roaming', searching: 'Searching', denied: 'Denied', controls: 'Controls',
		refresh: 'Refresh', connect: 'Connect', disconnect: 'Disconnect', reconnect: 'Reconnect', autodetect: 'Auto-detect port',
		configuration: 'Cellular configuration', pdp: 'PDP type', profile: 'Profile', save: 'Save and reconnect',
		working: 'Working…', done: 'Operation completed', error: 'Operation failed', seconds: 'seconds', technology: 'Technology',
		analytics: 'Analytics', bandsInUse: 'Bands in use', configuredBands: 'Enabled bands', supportedBands: 'Available bands',
		signalHistory: 'Signal history', trafficHistory: 'Cellular traffic', download: 'Download', upload: 'Upload',
		pin: 'SIM PIN', pinHint: 'Leave blank to keep the saved PIN', clearPin: 'Remove saved PIN', auth: 'Authentication',
		none: 'None', username: 'Username', password: 'Password', secretHint: 'Leave blank to keep the saved value',
		configured: 'Configured', notConfigured: 'Not configured', sms: 'SMS', smsDescription: 'Receive, read, send and delete text messages.',
		storage: 'Storage', modemStorage: 'Modem (ME)', simStorage: 'SIM card (SM)', loadSms: 'Load messages',
		noMessages: 'No messages in this storage', from: 'From / to', status: 'Status', date: 'Date', message: 'Message',
		delete: 'Delete', recipient: 'Recipient', smsText: 'Text (standard SMS, up to 160 bytes)', send: 'Send SMS', confirmDelete: 'Delete this SMS?',
		advancedRadio: 'Advanced radio details', advancedSettings: 'Advanced APN and SIM settings', excellent: 'Excellent', good: 'Good', fair: 'Fair', weak: 'Weak'
	},
	pt: {
		title: 'Gerenciador do modem FM350', description: 'Status em tempo real e controles seguros para a conexão celular Fibocom FM350-GL.',
		connection: 'Conexão', hardware: 'Hardware', sim: 'SIM', operator: 'Operadora', registration: 'Registro',
		signal: 'Sinal', device: 'Porta AT', interface: 'Interface de dados', apn: 'APN', ip: 'Endereço IPv4', gateway: 'Gateway',
		dns: 'Servidores DNS', uptime: 'Tempo conectado', connected: 'Conectado', connecting: 'Conectando', disconnected: 'Desconectado',
		unknown: 'Desconhecido', home: 'Rede doméstica', roaming: 'Roaming', searching: 'Procurando', denied: 'Negado', controls: 'Controles',
		refresh: 'Atualizar', connect: 'Conectar', disconnect: 'Desconectar', reconnect: 'Reconectar', autodetect: 'Autodetectar porta',
		configuration: 'Configuração celular', pdp: 'Tipo PDP', profile: 'Perfil', save: 'Salvar e reconectar',
		working: 'Processando…', done: 'Operação concluída', error: 'Falha na operação', seconds: 'segundos', technology: 'Tecnologia',
		analytics: 'Análises', bandsInUse: 'Bandas em uso', configuredBands: 'Bandas habilitadas', supportedBands: 'Bandas disponíveis',
		signalHistory: 'Histórico do sinal', trafficHistory: 'Tráfego celular', download: 'Download', upload: 'Upload',
		pin: 'PIN do SIM', pinHint: 'Deixe vazio para manter o PIN salvo', clearPin: 'Remover PIN salvo', auth: 'Autenticação',
		none: 'Nenhuma', username: 'Usuário', password: 'Senha', secretHint: 'Deixe vazio para manter o valor salvo',
		configured: 'Configurado', notConfigured: 'Não configurado', sms: 'SMS', smsDescription: 'Receba, leia, envie e apague mensagens de texto.',
		storage: 'Armazenamento', modemStorage: 'Modem (ME)', simStorage: 'Cartão SIM (SM)', loadSms: 'Carregar mensagens',
		noMessages: 'Nenhuma mensagem neste armazenamento', from: 'De / para', status: 'Status', date: 'Data', message: 'Mensagem',
		delete: 'Apagar', recipient: 'Destinatário', smsText: 'Texto (SMS padrão, até 160 bytes)', send: 'Enviar SMS', confirmDelete: 'Apagar esta mensagem?',
		advancedRadio: 'Detalhes avançados do rádio', advancedSettings: 'Configurações avançadas de APN e SIM', excellent: 'Excelente', good: 'Bom', fair: 'Regular', weak: 'Fraco'
	},
	es: {
		title: 'Gestor del módem FM350', description: 'Estado en vivo y controles seguros para la conexión celular Fibocom FM350-GL.',
		connection: 'Conexión', hardware: 'Hardware', sim: 'SIM', operator: 'Operador', registration: 'Registro',
		signal: 'Señal', device: 'Puerto AT', interface: 'Interfaz de datos', apn: 'APN', ip: 'Dirección IPv4', gateway: 'Puerta de enlace',
		dns: 'Servidores DNS', uptime: 'Tiempo conectado', connected: 'Conectado', connecting: 'Conectando', disconnected: 'Desconectado',
		unknown: 'Desconocido', home: 'Red local', roaming: 'Roaming', searching: 'Buscando', denied: 'Denegado', controls: 'Controles',
		refresh: 'Actualizar', connect: 'Conectar', disconnect: 'Desconectar', reconnect: 'Reconectar', autodetect: 'Detectar puerto',
		configuration: 'Configuración celular', pdp: 'Tipo PDP', profile: 'Perfil', save: 'Guardar y reconectar',
		working: 'Procesando…', done: 'Operación completada', error: 'Error en la operación', seconds: 'segundos', technology: 'Tecnología',
		analytics: 'Analítica', bandsInUse: 'Bandas en uso', configuredBands: 'Bandas habilitadas', supportedBands: 'Bandas disponibles',
		signalHistory: 'Historial de señal', trafficHistory: 'Tráfico celular', download: 'Descarga', upload: 'Subida',
		pin: 'PIN de la SIM', pinHint: 'Vacío conserva el PIN guardado', clearPin: 'Eliminar PIN guardado', auth: 'Autenticación',
		none: 'Ninguna', username: 'Usuario', password: 'Contraseña', secretHint: 'Vacío conserva el valor guardado',
		configured: 'Configurado', notConfigured: 'No configurado', sms: 'SMS', smsDescription: 'Reciba, lea, envíe y elimine mensajes de texto.',
		storage: 'Almacenamiento', modemStorage: 'Módem (ME)', simStorage: 'Tarjeta SIM (SM)', loadSms: 'Cargar mensajes',
		noMessages: 'No hay mensajes', from: 'De / para', status: 'Estado', date: 'Fecha', message: 'Mensaje', delete: 'Eliminar',
		recipient: 'Destinatario', smsText: 'Texto (SMS estándar, hasta 160 bytes)', send: 'Enviar SMS', confirmDelete: '¿Eliminar este SMS?',
		advancedRadio: 'Detalles avanzados de radio', advancedSettings: 'Ajustes avanzados de APN y SIM', excellent: 'Excelente', good: 'Buena', fair: 'Regular', weak: 'Débil'
	},
	fr: {
		title: 'Gestionnaire du modem FM350', description: 'État en direct et commandes sûres pour la connexion cellulaire Fibocom FM350-GL.',
		connection: 'Connexion', hardware: 'Matériel', sim: 'SIM', operator: 'Opérateur', registration: 'Enregistrement',
		signal: 'Signal', device: 'Port AT', interface: 'Interface de données', apn: 'APN', ip: 'Adresse IPv4', gateway: 'Passerelle',
		dns: 'Serveurs DNS', uptime: 'Temps connecté', connected: 'Connecté', connecting: 'Connexion', disconnected: 'Déconnecté',
		unknown: 'Inconnu', home: 'Réseau domestique', roaming: 'Itinérance', searching: 'Recherche', denied: 'Refusé', controls: 'Commandes',
		refresh: 'Actualiser', connect: 'Connecter', disconnect: 'Déconnecter', reconnect: 'Reconnecter', autodetect: 'Détecter le port',
		configuration: 'Configuration cellulaire', pdp: 'Type PDP', profile: 'Profil', save: 'Enregistrer et reconnecter',
		working: 'Traitement…', done: 'Opération terminée', error: 'Échec de l’opération', seconds: 'secondes', technology: 'Technologie',
		analytics: 'Analyses', bandsInUse: 'Bandes utilisées', configuredBands: 'Bandes activées', supportedBands: 'Bandes disponibles',
		signalHistory: 'Historique du signal', trafficHistory: 'Trafic cellulaire', download: 'Réception', upload: 'Envoi',
		pin: 'PIN SIM', pinHint: 'Laisser vide pour conserver le PIN', clearPin: 'Supprimer le PIN', auth: 'Authentification',
		none: 'Aucune', username: 'Utilisateur', password: 'Mot de passe', secretHint: 'Laisser vide pour conserver la valeur',
		configured: 'Configuré', notConfigured: 'Non configuré', sms: 'SMS', smsDescription: 'Recevez, lisez, envoyez et supprimez les SMS.',
		storage: 'Stockage', modemStorage: 'Modem (ME)', simStorage: 'Carte SIM (SM)', loadSms: 'Charger les messages',
		noMessages: 'Aucun message', from: 'De / vers', status: 'État', date: 'Date', message: 'Message', delete: 'Supprimer',
		recipient: 'Destinataire', smsText: 'Texte (SMS standard, 160 octets max.)', send: 'Envoyer le SMS', confirmDelete: 'Supprimer ce SMS ?',
		advancedRadio: 'Détails radio avancés', advancedSettings: 'Réglages APN et SIM avancés', excellent: 'Excellent', good: 'Bon', fair: 'Moyen', weak: 'Faible'
	},
	zh: {
		title: 'FM350 调制解调器管理器', description: 'Fibocom FM350-GL 蜂窝连接的实时状态和安全控制。',
		connection: '连接', hardware: '硬件', sim: 'SIM 卡', operator: '运营商', registration: '注册状态',
		signal: '信号', device: 'AT 端口', interface: '数据接口', apn: 'APN', ip: 'IPv4 地址', gateway: '网关',
		dns: 'DNS 服务器', uptime: '连接时间', connected: '已连接', connecting: '正在连接', disconnected: '已断开',
		unknown: '未知', home: '本地网络', roaming: '漫游', searching: '搜索中', denied: '被拒绝', controls: '控制',
		refresh: '刷新', connect: '连接', disconnect: '断开', reconnect: '重新连接', autodetect: '自动检测端口',
		configuration: '蜂窝配置', pdp: 'PDP 类型', profile: '配置文件', save: '保存并重新连接',
		working: '处理中…', done: '操作完成', error: '操作失败', seconds: '秒', technology: '网络技术', analytics: '分析',
		bandsInUse: '当前频段', configuredBands: '已启用频段', supportedBands: '可用频段', signalHistory: '信号历史', trafficHistory: '蜂窝流量',
		download: '下载', upload: '上传', pin: 'SIM PIN', pinHint: '留空以保留已保存的 PIN', clearPin: '删除已保存 PIN', auth: '认证',
		none: '无', username: '用户名', password: '密码', secretHint: '留空以保留已保存值', configured: '已配置', notConfigured: '未配置',
		sms: '短信', smsDescription: '接收、阅读、发送和删除短信。', storage: '存储', modemStorage: '调制解调器 (ME)', simStorage: 'SIM 卡 (SM)',
		loadSms: '加载短信', noMessages: '没有短信', from: '发件人 / 收件人', status: '状态', date: '日期', message: '内容', delete: '删除',
		recipient: '收件人', smsText: '文本（标准短信，最多 160 字节）', send: '发送短信', confirmDelete: '删除这条短信？',
		advancedRadio: '高级无线详情', advancedSettings: '高级 APN 和 SIM 设置', excellent: '极佳', good: '良好', fair: '一般', weak: '较弱'
	}
};

function language() {
	const code = String(L.env.lang || document.documentElement.lang || navigator.language || 'en').toLowerCase().replace('_', '-');
	if (code.startsWith('pt')) return 'pt';
	if (code.startsWith('es')) return 'es';
	if (code.startsWith('fr')) return 'fr';
	if (code.startsWith('zh')) return 'zh';
	return 'en';
}

function t(key) {
	return strings[language()][key] || strings.en[key] || key;
}

function parseResult(result) {
	let payload = {};
	try { payload = JSON.parse((result && result.stdout) || '{}'); } catch (error) { payload = {}; }
	if (!result || result.code !== 0)
		throw new Error(payload.message || (result && result.stderr) || t('error'));
	return payload;
}

function valueRow(label, value) {
	return E('tr', { 'class': 'tr' }, [
		E('td', { 'class': 'td left', 'style': 'width:35%;font-weight:600' }, [ label ]),
		E('td', { 'class': 'td left' }, [ String(value == null || value === '' ? '-' : value) ])
	]);
}

function decodeSms(text) {
	text = String(text || '').replace(/\\n/g, '\n').trim();
	const compact = text.replace(/\s+/g, '');
	if (compact.length && compact.length % 4 === 0 && /^(?:[0-9a-fA-F]{4})+$/.test(compact)) {
		let decoded = '';
		for (let i = 0; i < compact.length; i += 4)
			decoded += String.fromCharCode(parseInt(compact.slice(i, i + 4), 16));
		return decoded;
	}
	return text;
}

function signalQuality(dbm) {
	dbm = Number(dbm);
	if (!Number.isFinite(dbm)) return t('unknown');
	if (dbm >= -80) return t('excellent');
	if (dbm >= -90) return t('good');
	if (dbm >= -100) return t('fair');
	return t('weak');
}

function drawLineChart(canvas, title, unit, series) {
	if (!canvas || !canvas.getContext) return;
	const width = Math.max(320, canvas.parentNode.clientWidth || 640);
	const height = 180;
	const scale = window.devicePixelRatio || 1;
	canvas.width = width * scale;
	canvas.height = height * scale;
	canvas.style.width = width + 'px';
	canvas.style.height = height + 'px';
	const ctx = canvas.getContext('2d');
	ctx.scale(scale, scale);
	ctx.clearRect(0, 0, width, height);
	ctx.fillStyle = '#f8f9fa';
	ctx.fillRect(0, 0, width, height);
	ctx.font = '12px sans-serif';
	ctx.fillStyle = '#333';
	ctx.fillText(title, 10, 18);
	let values = [];
	series.forEach(function(item) { values = values.concat(item.values.filter(Number.isFinite)); });
	let min = values.length ? Math.min.apply(null, values) : 0;
	let max = values.length ? Math.max.apply(null, values) : 1;
	if (min === max) { min -= 1; max += 1; }
	const left = 46, top = 30, right = 12, bottom = 24;
	ctx.strokeStyle = '#d7dce1';
	ctx.lineWidth = 1;
	for (let i = 0; i <= 4; i++) {
		const y = top + ((height - top - bottom) * i / 4);
		ctx.beginPath(); ctx.moveTo(left, y); ctx.lineTo(width - right, y); ctx.stroke();
		const label = (max - ((max - min) * i / 4)).toFixed(unit === 'dBm' ? 0 : 1);
		ctx.fillStyle = '#667'; ctx.fillText(label, 4, y + 4);
	}
	series.forEach(function(item, index) {
		ctx.strokeStyle = item.color;
		ctx.lineWidth = 2;
		ctx.beginPath();
		item.values.forEach(function(value, i) {
			const x = left + (width - left - right) * (item.values.length <= 1 ? 0 : i / (item.values.length - 1));
			const y = top + (height - top - bottom) * (1 - ((value - min) / (max - min)));
			if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
		});
		ctx.stroke();
		ctx.fillStyle = item.color;
		ctx.fillText(item.label, left + (index * 120), height - 6);
	});
	ctx.fillStyle = '#667';
	ctx.fillText(unit, width - right - 35, 18);
}

return view.extend({
	history: [],
	loadStatus: function() {
		return fs.exec('/usr/sbin/fm350-control', [ 'status' ]).then(parseResult);
	},
	loadRadio: function() {
		return fs.exec('/usr/sbin/fm350-radio', []).then(parseResult);
	},

	load: function() {
		return this.loadStatus().then(L.bind(function(status) {
			return this.loadRadio().catch(function() { return {}; }).then(function(radio) {
				return { status: status, radio: radio };
			});
		}, this));
	},

	recordSample: function(status) {
		const now = Date.now();
		const previous = this.history.length ? this.history[this.history.length - 1] : null;
		let down = 0, up = 0;
		if (previous) {
			const seconds = Math.max(1, (now - previous.time) / 1000);
			down = Math.max(0, (Number(status.rx_bytes || 0) - previous.rxBytes) / seconds / 1024);
			up = Math.max(0, (Number(status.tx_bytes || 0) - previous.txBytes) / seconds / 1024);
		}
		this.history.push({
			time: now, dbm: Number(status.dbm), down: down, up: up,
			rxBytes: Number(status.rx_bytes || 0), txBytes: Number(status.tx_bytes || 0)
		});
		if (this.history.length > 60) this.history.shift();
	},

	drawCharts: function() {
		const signal = this.history.map(function(item) { return Number.isFinite(item.dbm) ? item.dbm : -113; });
		const down = this.history.map(function(item) { return item.down; });
		const up = this.history.map(function(item) { return item.up; });
		drawLineChart(document.getElementById('fm350-signal-chart'), t('signalHistory'), 'dBm', [
			{ label: t('signal'), color: '#2d7dd2', values: signal }
		]);
		drawLineChart(document.getElementById('fm350-traffic-chart'), t('trafficHistory'), 'KiB/s', [
			{ label: t('download'), color: '#2ca25f', values: down },
			{ label: t('upload'), color: '#de2d26', values: up }
		]);
	},

	renderStatus: function(status) {
		const stateKey = status.state || 'unknown';
		const signal = status.dbm === 'unknown' ? t('unknown') : '%s — %s'.format((status.csq === 'unknown' || status.csq === '99' ? '%s dBm'.format(status.dbm) : 'CSQ %s (%s dBm)'.format(status.csq, status.dbm)), signalQuality(status.dbm));
		const registration = t(status.registration || 'unknown');
		const uptime = status.up ? '%s %s'.format(status.uptime || '0', t('seconds')) : '-';
		return E('div', {}, [
			E('h3', {}, [ t('connection'), ' — ', E('span', { 'class': status.up ? 'label success' : 'label warning' }, [ t(stateKey) ]) ]),
			E('table', { 'class': 'table' }, [
				valueRow(t('hardware'), status.model), valueRow(t('sim'), status.sim),
				valueRow(t('operator'), '%s (RAT %s)'.format(status.operator, status.rat)),
				valueRow(t('technology'), status.technology),
				valueRow(t('registration'), registration), valueRow(t('signal'), signal),
				valueRow(t('device'), status.device), valueRow(t('interface'), status.interface),
				valueRow(t('apn'), status.apn), valueRow(t('auth'), status.auth && status.auth !== 'none' ? status.auth.toUpperCase() : t('none')),
				valueRow(t('pin'), status.pin_configured ? t('configured') : t('notConfigured')), valueRow(t('ip'), status.ip),
				valueRow(t('gateway'), status.gateway), valueRow(t('dns'), status.dns), valueRow(t('uptime'), uptime)
			])
		]);
	},

	renderAnalytics: function(radio) {
		return E('div', {}, [
			E('table', { 'class': 'table' }, [
				valueRow(t('technology'), radio.technology || t('unknown')),
				valueRow(t('bandsInUse'), radio.bands_in_use || t('unknown'))
			]),
			E('details', { 'style': 'margin:.75em 0' }, [
				E('summary', { 'style': 'cursor:pointer;font-weight:600' }, [ t('advancedRadio') ]),
				E('table', { 'class': 'table' }, [
					valueRow(t('configuredBands'), radio.configured_bands || t('unknown')),
					valueRow(t('supportedBands'), radio.supported_bands || t('unknown'))
				])
			]),
			E('canvas', { 'id': 'fm350-signal-chart', 'style': 'display:block;max-width:100%;margin-top:1em' }),
			E('canvas', { 'id': 'fm350-traffic-chart', 'style': 'display:block;max-width:100%;margin-top:1em' })
		]);
	},

	renderSmsMessages: function(result) {
		const messages = result.messages || [];
		if (!messages.length) return E('p', {}, [ t('noMessages') ]);
		return E('table', { 'class': 'table' }, [
			E('tr', { 'class': 'tr table-titles' }, [
				E('th', { 'class': 'th' }, [ t('from') ]), E('th', { 'class': 'th' }, [ t('status') ]),
				E('th', { 'class': 'th' }, [ t('date') ]), E('th', { 'class': 'th' }, [ t('message') ]), E('th', { 'class': 'th' }, [ '' ])
			])
		].concat(messages.map(L.bind(function(message) {
			return E('tr', { 'class': 'tr' }, [
				E('td', { 'class': 'td' }, [ message.number || '-' ]), E('td', { 'class': 'td' }, [ message.status || '-' ]),
				E('td', { 'class': 'td' }, [ message.timestamp || '-' ]), E('td', { 'class': 'td', 'style': 'white-space:pre-wrap' }, [ decodeSms(message.text) ]),
				E('td', { 'class': 'td' }, [ E('button', { 'class': 'cbi-button cbi-button-negative fm350-action', 'click': L.bind(this.handleSmsDelete, this, message.storage, message.index) }, [ t('delete') ]) ])
			]);
		}, this))));
	},

	setBusy: function(busy) {
		document.querySelectorAll('.fm350-action').forEach(function(button) {
			button.disabled = busy;
		});
		if (!busy) this.updateActionStates();
	},

	updateActionStates: function() {
		const status = this.currentStatus || {};
		const connect = document.getElementById('fm350-connect');
		const disconnect = document.getElementById('fm350-disconnect');
		if (connect) connect.disabled = !!status.up;
		if (disconnect) disconnect.disabled = !status.up && !status.pending;
	},

	handleAuthChange: function() {
		const enabled = document.getElementById('fm350-auth').value !== 'none';
		document.getElementById('fm350-username').disabled = !enabled;
		document.getElementById('fm350-password').disabled = !enabled;
	},

	handlePinClearChange: function() {
		document.getElementById('fm350-pin').disabled = document.getElementById('fm350-clear-pin').checked;
	},

	handleSmsInput: function() {
		const field = document.getElementById('fm350-sms-text');
		const counter = document.getElementById('fm350-sms-counter');
		if (field && counter) counter.textContent = field.value.length + '/160';
	},

	refresh: function() {
		const target = document.getElementById('fm350-status');
		if (!target) return Promise.resolve();
		return this.loadStatus().then(L.bind(function(status) {
			this.currentStatus = status;
			this.recordSample(status);
			dom.content(target, this.renderStatus(status));
			this.drawCharts();
			this.updateActionStates();
		}, this)).catch(function(error) {
			ui.addNotification(null, E('p', [ error.message || t('error') ]));
		});
	},

	handleAction: function(action, event) {
		if (event) event.preventDefault();
		this.setBusy(true);
		ui.showModal(t('working'), [ E('p', { 'class': 'spinning' }, [ t('working') ]) ]);
		return fs.exec('/usr/sbin/fm350-control', [ action ]).then(parseResult).then(L.bind(function() {
			ui.hideModal();
			ui.addNotification(null, E('p', [ t('done') ]));
			return new Promise(function(resolve) { window.setTimeout(resolve, 3500); });
		}, this)).then(L.bind(this.refresh, this)).catch(function(error) {
			ui.hideModal();
			ui.addNotification(null, E('p', [ error.message || t('error') ]));
		}).finally(L.bind(function() { this.setBusy(false); }, this));
	},

	handleRadioRefresh: function(event) {
		if (event) event.preventDefault();
		this.setBusy(true);
		return this.loadRadio().then(function(radio) {
			dom.content(document.getElementById('fm350-radio'), this.renderAnalytics(radio));
			this.drawCharts();
		}.bind(this)).catch(function(error) {
			ui.addNotification(null, E('p', [ error.message || t('error') ]));
		}).finally(L.bind(function() { this.setBusy(false); }, this));
	},

	handleSmsRefresh: function(event) {
		if (event) event.preventDefault();
		const storage = document.getElementById('fm350-sms-storage').value;
		const target = document.getElementById('fm350-sms-list');
		this.setBusy(true);
		dom.content(target, E('p', { 'class': 'spinning' }, [ t('working') ]));
		return fs.exec('/usr/sbin/fm350-sms', [ 'list', storage ]).then(parseResult).then(L.bind(function(result) {
			dom.content(target, this.renderSmsMessages(result));
		}, this)).catch(function(error) {
			dom.content(target, E('p', {}, [ error.message || t('error') ]));
		}).finally(L.bind(function() { this.setBusy(false); }, this));
	},

	handleSmsDelete: function(storage, index, event) {
		if (event) event.preventDefault();
		if (!window.confirm(t('confirmDelete'))) return Promise.resolve();
		this.setBusy(true);
		return fs.exec('/usr/sbin/fm350-sms', [ 'delete', storage, String(index) ]).then(parseResult).then(L.bind(function() {
			return this.handleSmsRefresh();
		}, this)).catch(function(error) {
			ui.addNotification(null, E('p', [ error.message || t('error') ]));
		}).finally(L.bind(function() { this.setBusy(false); }, this));
	},

	handleSmsSend: function(event) {
		if (event) event.preventDefault();
		const number = document.getElementById('fm350-sms-number').value.trim();
		const message = document.getElementById('fm350-sms-text').value;
		if (!/^\+?[0-9]{8,15}$/.test(number) || !message || message.length > 160) {
			ui.addNotification(null, E('p', [ t('error') ]));
			return Promise.resolve();
		}
		this.setBusy(true);
		ui.showModal(t('working'), [ E('p', { 'class': 'spinning' }, [ t('working') ]) ]);
		return fs.exec('/usr/sbin/fm350-sms', [ 'send', number, message ]).then(parseResult).then(L.bind(function() {
			ui.hideModal();
			document.getElementById('fm350-sms-text').value = '';
			this.handleSmsInput();
			ui.addNotification(null, E('p', [ t('done') ]));
		}, this)).catch(function(error) {
			ui.hideModal();
			ui.addNotification(null, E('p', [ error.message || t('error') ]));
		}).finally(L.bind(function() { this.setBusy(false); }, this));
	},

	handleConfigSave: function(event) {
		if (event) event.preventDefault();
		const apn = document.getElementById('fm350-apn').value.trim();
		const pdp = document.getElementById('fm350-pdp').value;
		const profile = document.getElementById('fm350-profile').value;
		const pin = document.getElementById('fm350-clear-pin').checked ? '__CLEAR__' : document.getElementById('fm350-pin').value.trim();
		const auth = document.getElementById('fm350-auth').value;
		const username = document.getElementById('fm350-username').value;
		const password = document.getElementById('fm350-password').value;
		if (!/^[A-Za-z0-9][A-Za-z0-9._-]{0,99}$/.test(apn)) {
			ui.addNotification(null, E('p', [ t('error') + ': APN' ]));
			return Promise.resolve();
		}
		this.setBusy(true);
		ui.showModal(t('working'), [ E('p', { 'class': 'spinning' }, [ t('working') ]) ]);
		return fs.exec('/usr/sbin/fm350-control', [ 'configure', apn, pdp, profile, pin, auth, username, password ]).then(parseResult).then(L.bind(function() {
			ui.hideModal();
			ui.addNotification(null, E('p', [ t('done') ]));
			return new Promise(function(resolve) { window.setTimeout(resolve, 5000); });
		}, this)).then(L.bind(this.refresh, this)).catch(function(error) {
			ui.hideModal();
			ui.addNotification(null, E('p', [ error.message || t('error') ]));
		}).finally(L.bind(function() { this.setBusy(false); }, this));
	},

	render: function(data) {
		const status = data.status;
		const radio = data.radio || {};
		this.recordSample(status);
		poll.add(L.bind(this.refresh, this), 30);
		const page = E('div', { 'class': 'cbi-map' }, [
			E('h2', {}, [ t('title') ]),
			E('div', { 'class': 'cbi-map-descr' }, [ t('description') ]),
			E('div', { 'id': 'fm350-status', 'class': 'cbi-section' }, [ this.renderStatus(status) ]),
			E('div', { 'class': 'cbi-section' }, [
				E('h3', {}, [ t('analytics') ]),
				E('div', { 'id': 'fm350-radio' }, [ this.renderAnalytics(radio) ]),
				E('div', { 'class': 'cbi-page-actions' }, [ E('button', { 'class': 'cbi-button cbi-button-reload fm350-action', 'click': L.bind(this.handleRadioRefresh, this) }, [ t('refresh') ]) ])
			]),
			E('div', { 'class': 'cbi-section' }, [
				E('h3', {}, [ t('controls') ]),
				E('div', {}, [
					E('button', { 'id': 'fm350-connect', 'class': 'cbi-button cbi-button-action fm350-action', 'click': L.bind(this.handleAction, this, 'connect') }, [ t('connect') ]), ' ',
					E('button', { 'id': 'fm350-disconnect', 'class': 'cbi-button cbi-button-negative fm350-action', 'click': L.bind(this.handleAction, this, 'disconnect') }, [ t('disconnect') ]), ' ',
					E('button', { 'class': 'cbi-button cbi-button-reload fm350-action', 'click': L.bind(this.handleAction, this, 'reconnect') }, [ t('reconnect') ]), ' ',
					E('button', { 'class': 'cbi-button fm350-action', 'click': L.bind(this.handleAction, this, 'autodetect') }, [ t('autodetect') ]), ' ',
					E('button', { 'class': 'cbi-button fm350-action', 'click': L.bind(this.refresh, this) }, [ t('refresh') ])
				])
			]),
			E('div', { 'class': 'cbi-section' }, [
				E('h3', {}, [ t('configuration') ]),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title', 'for': 'fm350-apn' }, [ t('apn') ]), E('div', { 'class': 'cbi-value-field' }, [ E('input', { 'id': 'fm350-apn', 'type': 'text', 'value': status.apn || 'surf.br' }) ]) ]),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title', 'for': 'fm350-pdp' }, [ t('pdp') ]), E('div', { 'class': 'cbi-value-field' }, [ E('select', { 'id': 'fm350-pdp' }, [
					E('option', { 'value': 'IP', 'selected': status.pdp === 'IP' ? '' : null }, [ 'IPv4' ]),
					E('option', { 'value': 'IPV4V6', 'selected': status.pdp === 'IPV4V6' ? '' : null }, [ 'IPv4/IPv6' ]),
					E('option', { 'value': 'IPV6', 'selected': status.pdp === 'IPV6' ? '' : null }, [ 'IPv6' ])
				]) ]) ]),
				E('details', { 'style': 'margin:.75em 0' }, [
					E('summary', { 'style': 'cursor:pointer;font-weight:600' }, [ t('advancedSettings') ]),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title', 'for': 'fm350-profile' }, [ t('profile') ]), E('div', { 'class': 'cbi-value-field' }, [ E('input', { 'id': 'fm350-profile', 'type': 'number', 'min': '1', 'max': '16', 'value': status.profile || '1' }) ]) ]),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title', 'for': 'fm350-pin' }, [ t('pin') ]), E('div', { 'class': 'cbi-value-field' }, [
						E('input', { 'id': 'fm350-pin', 'type': 'password', 'inputmode': 'numeric', 'maxlength': '8', 'placeholder': t('pinHint') }),
						E('label', { 'style': 'display:block;margin-top:.4em' }, [ E('input', { 'id': 'fm350-clear-pin', 'type': 'checkbox', 'change': L.bind(this.handlePinClearChange, this) }), ' ', t('clearPin') ])
					]) ]),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title', 'for': 'fm350-auth' }, [ t('auth') ]), E('div', { 'class': 'cbi-value-field' }, [ E('select', { 'id': 'fm350-auth', 'change': L.bind(this.handleAuthChange, this) }, [
						E('option', { 'value': 'none', 'selected': !status.auth || status.auth === 'none' ? '' : null }, [ t('none') ]),
						E('option', { 'value': 'pap', 'selected': status.auth === 'pap' ? '' : null }, [ 'PAP' ]),
						E('option', { 'value': 'chap', 'selected': status.auth === 'chap' ? '' : null }, [ 'CHAP' ])
					]) ]) ]),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title', 'for': 'fm350-username' }, [ t('username') ]), E('div', { 'class': 'cbi-value-field' }, [ E('input', { 'id': 'fm350-username', 'type': 'text', 'maxlength': '128', 'placeholder': t('secretHint') }) ]) ]),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title', 'for': 'fm350-password' }, [ t('password') ]), E('div', { 'class': 'cbi-value-field' }, [ E('input', { 'id': 'fm350-password', 'type': 'password', 'maxlength': '128', 'placeholder': t('secretHint') }) ]) ])
				]),
				E('div', { 'class': 'cbi-page-actions' }, [ E('button', { 'class': 'cbi-button cbi-button-apply fm350-action', 'click': L.bind(this.handleConfigSave, this) }, [ t('save') ]) ])
			]),
			E('div', { 'class': 'cbi-section' }, [
				E('h3', {}, [ t('sms') ]), E('p', {}, [ t('smsDescription') ]),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title', 'for': 'fm350-sms-storage' }, [ t('storage') ]), E('div', { 'class': 'cbi-value-field' }, [
					E('select', { 'id': 'fm350-sms-storage' }, [ E('option', { 'value': 'SM' }, [ t('simStorage') ]), E('option', { 'value': 'ME' }, [ t('modemStorage') ]) ]), ' ',
					E('button', { 'class': 'cbi-button cbi-button-reload fm350-action', 'click': L.bind(this.handleSmsRefresh, this) }, [ t('loadSms') ])
				]) ]),
				E('div', { 'id': 'fm350-sms-list' }, [ E('p', {}, [ t('loadSms') ]) ]),
				E('h4', {}, [ t('send') ]),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title', 'for': 'fm350-sms-number' }, [ t('recipient') ]), E('div', { 'class': 'cbi-value-field' }, [ E('input', { 'id': 'fm350-sms-number', 'type': 'tel', 'placeholder': '+5511999999999', 'maxlength': '16' }) ]) ]),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title', 'for': 'fm350-sms-text' }, [ t('smsText') ]), E('div', { 'class': 'cbi-value-field' }, [ E('textarea', { 'id': 'fm350-sms-text', 'rows': '4', 'maxlength': '160', 'style': 'width:100%', 'input': L.bind(this.handleSmsInput, this) }), E('small', { 'id': 'fm350-sms-counter', 'style': 'float:right' }, [ '0/160' ]) ]) ]),
				E('div', { 'class': 'cbi-page-actions' }, [ E('button', { 'class': 'cbi-button cbi-button-apply fm350-action', 'click': L.bind(this.handleSmsSend, this) }, [ t('send') ]) ])
			])
		]);
		this.currentStatus = status;
		window.setTimeout(L.bind(function() {
			this.drawCharts();
			this.updateActionStates();
			this.handleAuthChange();
			this.handlePinClearChange();
		}, this), 0);
		return page;
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
