import http from 'node:http';
import { readFile } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import path from 'node:path';
import { openDatabase } from './db.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const STATIC = {
  '/': ['index.html', 'text/html; charset=utf-8'],
  '/app.js': ['app.js', 'text/javascript; charset=utf-8'],
  '/styles.css': ['styles.css', 'text/css; charset=utf-8'],
};

// Accepts 1-8 digits, with or without leading zeros; returns the 8-digit PERNR or null.
export function normalizePernr(input) {
  const value = String(input ?? '').trim();
  return /^\d{1,8}$/.test(value) ? value.padStart(8, '0') : null;
}

function withStatus(employee, today = new Date().toISOString().slice(0, 10)) {
  const active = employee.begda <= today && today <= employee.endda;
  return { ...employee, status: active ? 'Active' : 'Inactive' };
}

function sendJson(res, status, body) {
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(body));
}

export function createServer(db) {
  return http.createServer(async (req, res) => {
    const url = new URL(req.url, 'http://localhost');

    if (req.method !== 'GET') return sendJson(res, 405, { error: 'Method not allowed' });

    const exact = url.pathname.match(/^\/api\/employees\/([^/]+)$/);
    if (exact) {
      const pernr = normalizePernr(decodeURIComponent(exact[1]));
      if (!pernr) return sendJson(res, 400, { error: 'Employee number must be 1 to 8 digits' });
      const employee = db.findByPernr(pernr);
      if (!employee) return sendJson(res, 404, { error: `No employee found with number ${pernr}` });
      return sendJson(res, 200, withStatus(employee));
    }

    if (url.pathname === '/api/employees') {
      const q = (url.searchParams.get('q') ?? '').trim().replace(/^0+(?=\d)/, '');
      if (!/^\d{1,8}$/.test(q)) return sendJson(res, 400, { error: 'q must be 1 to 8 digits' });
      return sendJson(res, 200, db.searchByPrefix(q).map((e) => withStatus(e)));
    }

    const file = STATIC[url.pathname];
    if (file) {
      const body = await readFile(path.join(here, 'public', file[0]));
      res.writeHead(200, { 'Content-Type': file[1] });
      return res.end(body);
    }

    sendJson(res, 404, { error: 'Not found' });
  });
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const port = Number(process.env.PORT ?? 3000);
  const db = openDatabase(process.env.DB_PATH ?? path.join(here, 'employees.db'));
  createServer(db).listen(port, () => {
    console.log(`Employee search running at http://localhost:${port}`);
  });
}
