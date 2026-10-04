import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { openDatabase } from '../db.js';
import { createServer, normalizePernr } from '../server.js';

let server;
let base;

before(async () => {
  server = createServer(openDatabase(':memory:'));
  await new Promise((resolve) => server.listen(0, resolve));
  base = `http://localhost:${server.address().port}`;
});

after(() => server.close());

const get = async (path) => {
  const res = await fetch(base + path);
  return { status: res.status, body: res.headers.get('content-type').includes('json') ? await res.json() : await res.text() };
};

test('normalizePernr pads to 8 digits and rejects non-digits', () => {
  assert.equal(normalizePernr('1003'), '00001003');
  assert.equal(normalizePernr(' 00001003 '), '00001003');
  assert.equal(normalizePernr('12a'), null);
  assert.equal(normalizePernr('123456789'), null);
  assert.equal(normalizePernr(''), null);
});

test('finds employee by number without leading zeros', async () => {
  const { status, body } = await get('/api/employees/1003');
  assert.equal(status, 200);
  assert.equal(body.pernr, '00001003');
  assert.equal(body.ename, 'Rahul Sharma');
  assert.equal(body.status, 'Active');
});

test('finds employee by full 8-digit number', async () => {
  const { status, body } = await get('/api/employees/00001001');
  assert.equal(status, 200);
  assert.equal(body.ename, 'John Smith');
});

test('reports inactive employees', async () => {
  const { body } = await get('/api/employees/1009');
  assert.equal(body.status, 'Inactive');
});

test('returns 404 for unknown employee number', async () => {
  const { status, body } = await get('/api/employees/99999999');
  assert.equal(status, 404);
  assert.match(body.error, /99999999/);
});

test('returns 400 for invalid employee number', async () => {
  for (const bad of ['abc', '123456789', '1%27%20OR%201=1']) {
    const { status } = await get(`/api/employees/${bad}`);
    assert.equal(status, 400, bad);
  }
});

test('prefix search returns matches sorted by number', async () => {
  const { status, body } = await get('/api/employees?q=101');
  assert.equal(status, 200);
  assert.deepEqual(body.map((e) => e.pernr), [
    '00001010', '00001011', '00001012', '00001013', '00001014',
    '00001015', '00001016', '00001017', '00001018', '00001019',
  ]);
});

test('prefix search rejects non-digit queries', async () => {
  const { status } = await get('/api/employees?q=abc');
  assert.equal(status, 400);
});

test('serves the search page', async () => {
  const { status, body } = await get('/');
  assert.equal(status, 200);
  assert.match(body, /Employee Search/);
});
