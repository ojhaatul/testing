# Employee Search (local website)

Search the employee database by employee number (PERNR). Accepts 1–8 digits, with or without leading zeros (`1003` = `00001003`); typing shows matching numbers as suggestions.

Data is a local SQLite file (`employees.db`, created and seeded on first start) with fictitious records shaped like SAP HCM infotype 0001.

Requires Node.js 22.13+ (built-in `node:sqlite`, no npm dependencies).

```bash
cd web
npm start          # http://localhost:3000  (PORT=8080 npm start to change)
npm test
```

| Endpoint | Description |
|---|---|
| `GET /api/employees/:pernr` | Exact lookup; 404 if not found, 400 if not 1–8 digits |
| `GET /api/employees?q=10` | Up to 20 employees whose number starts with `q` |
| `GET /?pernr=1003` | Opens the page with that employee pre-searched |
