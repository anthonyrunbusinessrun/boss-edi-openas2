const express = require('express');

const app = express();
app.disable('x-powered-by');
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Cache-Control', 'no-store');
  next();
});

app.get('/health', (req, res) => res.json({
  status: 'disabled',
  service: 'Ray Land legacy AS2 endpoint',
  reason: 'DAAS GEX confirmed the Ray Land pathway uses HTTPS on port 443',
  version: '2.0.0',
}));

app.all('/as2', (req, res) => res.status(410).json({
  success: false,
  error: 'AS2 is not enabled for the Ray Land GEX pathway. Use the approved HTTPS endpoint.',
}));

app.use((req, res) => res.status(404).json({ success: false, error: 'Not found' }));

if (require.main === module) {
  const port = Number(process.env.PORT || 4080);
  app.listen(port, '0.0.0.0', () => console.log(`Legacy AS2 placeholder listening on ${port}; AS2 disabled`));
}

module.exports = app;
