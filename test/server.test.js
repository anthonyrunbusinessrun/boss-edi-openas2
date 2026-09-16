const test = require('node:test');
const assert = require('node:assert/strict');
const app = require('../server');

async function withServer(run) {
  const server = app.listen(0, '127.0.0.1');
  await new Promise(resolve => server.once('listening', resolve));
  try { await run(`http://127.0.0.1:${server.address().port}`); }
  finally { await new Promise(resolve => server.close(resolve)); }
}

test('health clearly reports AS2 disabled', async () => withServer(async base => {
  const response = await fetch(`${base}/health`);
  assert.equal(response.status, 200);
  assert.equal((await response.json()).status, 'disabled');
}));

test('AS2 messages are rejected rather than falsely acknowledged', async () => withServer(async base => {
  const response = await fetch(`${base}/as2`, { method: 'POST', body: 'ISA*...' });
  assert.equal(response.status, 410);
  assert.match((await response.json()).error, /not enabled/i);
}));
