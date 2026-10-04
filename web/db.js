import { DatabaseSync } from 'node:sqlite';
import { employees } from './seed.js';

const COLUMNS = 'pernr, ename, personnel_area, org_unit, position, begda, endda';

export function openDatabase(path) {
  const db = new DatabaseSync(path);
  db.exec(`CREATE TABLE IF NOT EXISTS employees (
    pernr TEXT PRIMARY KEY CHECK (length(pernr) = 8),
    ename TEXT NOT NULL,
    personnel_area TEXT,
    org_unit TEXT,
    position TEXT,
    begda TEXT NOT NULL,
    endda TEXT NOT NULL
  )`);

  if (db.prepare('SELECT COUNT(*) AS n FROM employees').get().n === 0) {
    const insert = db.prepare(`INSERT INTO employees (${COLUMNS}) VALUES (?, ?, ?, ?, ?, ?, ?)`);
    for (const row of employees) insert.run(...row);
  }

  const byPernr = db.prepare(`SELECT ${COLUMNS} FROM employees WHERE pernr = ?`);
  const byPrefix = db.prepare(
    `SELECT ${COLUMNS} FROM employees WHERE ltrim(pernr, '0') LIKE ? || '%' ORDER BY pernr LIMIT ?`,
  );

  return {
    findByPernr: (pernr) => byPernr.get(pernr) ?? null,
    searchByPrefix: (digits, limit = 20) => byPrefix.all(digits, limit),
    close: () => db.close(),
  };
}
