'use strict';
'require view';
'require fs';
'require ui';
'require dom';

function parseResult(result) {
	let payload = {};
	try { payload = JSON.parse((result && result.stdout) || '{}'); } catch (error) { payload = {}; }
	if (!result || result.code !== 0)
		throw new Error(payload.message || (result && result.stderr) || 'Operation failed');
	return payload;
}

function row(label, value) {
	return E('tr', { 'class': 'tr' }, [
		E('td', { 'class': 'td left', 'style': 'width:35%;font-weight:600' }, [ label ]),
		E('td', { 'class': 'td left' }, [ String(value == null || value === '' ? '-' : value) ])
	]);
}

return view.extend({
	load: function() {
		return Promise.all([
			fs.exec('/usr/sbin/fm350-api-token', [ 'show' ]).then(parseResult),
			fs.exec('/usr/sbin/fm350-telemetry', []).then(parseResult).catch(function() { return {}; }),
			fs.exec('/usr/sbin/fm350-control', [ 'status' ]).then(parseResult)
		]);
	},

	runTokenAction: function(action) {
		return fs.exec('/usr/sbin/fm350-api-token', [ action ]).then(parseResult).then(function(result) {
			const token = document.getElementById('fm350-api-token');
			const state = document.getElementById('fm350-api-state');
			if (token) token.value = result.token || '';
			if (state) state.textContent = result.enabled ? 'Enabled' : 'Disabled';
			ui.addNotification(null, E('p', {}, [ 'Telemetry API updated.' ]), 'info');
			return result;
		}).catch(function(error) {
			ui.addNotification(null, E('p', {}, [ error.message ]), 'error');
		});
	},

	render: function(data) {
		const api = data[0] || {};
		const telemetry = data[1] || {};
		const status = data[2] || {};
		const signal = telemetry.signal || {};
		const radio = telemetry.radio || {};
		const connection = telemetry.connection || {};
		const endpoint = api.endpoint || 'https://192.168.77.1/cgi-bin/fm350-telemetry';
		const example = "curl -k -H 'X-API-Key: " + (api.token || 'TOKEN') + "' '" + endpoint + "'";
		const nodes = [
			E('h2', {}, [ 'FM350 Telemetry API' ]),
			E('div', { 'class': 'cbi-map-descr' }, [
				'Token-protected telemetry for external systems such as RatoNet, Home Assistant, Prometheus adapters and monitoring tools. The endpoint is bound to the NanoPi maintenance network.'
			])
		];

		if (!status.admin_password_set) {
			nodes.push(E('div', { 'class': 'alert-message warning', 'style': 'margin:1em 0' }, [
				E('strong', {}, [ 'First-boot security setup required. ' ]),
				'The root password is intentionally unset instead of using a public default password. Set a strong password now in ',
				E('a', { 'href': L.url('admin/system/admin') }, [ 'System → Administration' ]),
				'. SSH password login remains disabled by default; SSH keys are recommended.'
			]));
		}

		nodes.push(
			E('div', { 'class': 'cbi-section' }, [
				E('h3', {}, [ 'API access' ]),
				E('table', { 'class': 'table' }, [
					row('State', E('span', { 'id': 'fm350-api-state' }, [ api.enabled ? 'Enabled' : 'Disabled' ])),
					row('Endpoint', endpoint)
				]),
				E('label', { 'style': 'display:block;font-weight:600;margin-top:.75em' }, [ 'API token' ]),
				E('input', { 'id': 'fm350-api-token', 'class': 'cbi-input-text', 'style': 'width:100%;font-family:monospace', 'readonly': '', 'value': api.token || '' }),
				E('div', { 'style': 'margin-top:.75em;display:flex;gap:.5em;flex-wrap:wrap' }, [
					E('button', { 'class': 'cbi-button cbi-button-apply', 'click': L.bind(this.runTokenAction, this, 'enable') }, [ 'Enable API' ]),
					E('button', { 'class': 'cbi-button', 'click': L.bind(this.runTokenAction, this, 'disable') }, [ 'Disable API' ]),
					E('button', { 'class': 'cbi-button cbi-button-negative', 'click': L.bind(this.runTokenAction, this, 'rotate') }, [ 'Rotate token' ])
				]),
				E('p', { 'style': 'margin-top:1em' }, [ 'Example:' ]),
				E('pre', { 'style': 'white-space:pre-wrap;word-break:break-all' }, [ example ])
			]),
			E('div', { 'class': 'cbi-section' }, [
				E('h3', {}, [ 'Live cellular telemetry' ]),
				E('table', { 'class': 'table' }, [
					row('Connection', connection.state || 'unknown'),
					row('Operator', connection.operator || 'unknown'),
					row('Technology', connection.technology || 'unknown'),
					row('RSSI', signal.rssi_dbm === 'unknown' ? 'unknown' : signal.rssi_dbm + ' dBm'),
					row('RSRP', signal.rsrp_dbm === 'unknown' ? 'unknown' : signal.rsrp_dbm + ' dBm'),
					row('RSRQ', signal.rsrq_db === 'unknown' ? 'unknown' : signal.rsrq_db + ' dB'),
					row('SINR', signal.sinr_db === 'unknown' ? 'unknown' : signal.sinr_db + ' dB'),
					row('Bands', radio.bands_in_use || 'unknown'),
					row('TAC', radio.tac || 'unknown'),
					row('Cell ID', radio.cell_id || 'unknown')
				])
			])
		);
		return E('div', { 'class': 'cbi-map' }, nodes);
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
