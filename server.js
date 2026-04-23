const express = require('express');
const fetch = require('node-fetch');
const app = express();
const CONNECTOR = process.env.CONNECTOR_URL || 'https://boss-edi-connector-production.up.railway.app';
app.use((req, res, next) => { res.setHeader('AS2-Version', '1.2'); next(); });
app.post('/as2', (req, res) => {
  let body = '';
  req.on('data', c => body += c);
  req.on('end', async () => {
    console.log('AS2 received from:', req.headers['as2-from']);
    try { await fetch(CONNECTOR + '/as2', { method: 'POST', headers: {...req.headers, host: undefined}, body }); } catch(e) { console.error(e.message); }
    res.set('Disposition', 'automatic-action/MDN-sent-automatically; processed');
    res.status(200).send('Message received');
  });
});
app.get('/health', (req, res) => res.json({ status: 'online', service: 'BusinessOS AS2 Gateway', port: 4080 }));
app.listen(4080, () => console.log('AS2 Gateway running on port 4080'));
