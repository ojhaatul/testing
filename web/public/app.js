const form = document.getElementById('search-form');
const input = document.getElementById('pernr');
const suggestions = document.getElementById('suggestions');
const result = document.getElementById('result');

const FIELDS = [
  ['Personnel area', 'personnel_area'],
  ['Organizational unit', 'org_unit'],
  ['Position', 'position'],
  ['Valid from', 'begda'],
  ['Valid to', 'endda'],
];

function el(tag, props = {}, children = []) {
  const node = Object.assign(document.createElement(tag), props);
  node.append(...children);
  return node;
}

function showMessage(text, kind = '') {
  result.replaceChildren(el('div', { className: `message ${kind}`.trim(), textContent: text }));
}

function showEmployee(e) {
  const dl = el('dl');
  for (const [label, key] of FIELDS) dl.append(el('dt', { textContent: label }), el('dd', { textContent: e[key] }));
  result.replaceChildren(
    el('article', { className: 'card' }, [
      el('div', { className: 'pernr', textContent: `Employee No. ${e.pernr}` }),
      el('h2', {}, [e.ename, el('span', { className: `badge ${e.status}`, textContent: e.status })]),
      dl,
    ]),
  );
}

async function lookup(value) {
  suggestions.hidden = true;
  const query = value.trim();
  if (!/^\d{1,8}$/.test(query)) return showMessage('Enter an employee number of 1 to 8 digits.', 'error');

  const res = await fetch(`/api/employees/${encodeURIComponent(query)}`);
  const body = await res.json();
  if (res.ok) {
    input.value = body.pernr;
    showEmployee(body);
  } else {
    showMessage(body.error, res.status === 404 ? '' : 'error');
  }
}

async function suggest() {
  const q = input.value.trim();
  if (!/^\d{1,8}$/.test(q)) {
    suggestions.hidden = true;
    return;
  }
  const res = await fetch(`/api/employees?q=${encodeURIComponent(q)}`);
  if (!res.ok || q !== input.value.trim()) return;
  const list = await res.json();
  suggestions.replaceChildren(
    ...list.map((e) =>
      el('li', { role: 'option', onclick: () => lookup(e.pernr) }, [
        el('span', { className: 'num', textContent: e.pernr }),
        e.ename,
      ]),
    ),
  );
  suggestions.hidden = list.length === 0;
}

form.addEventListener('submit', (event) => {
  event.preventDefault();
  lookup(input.value);
});
input.addEventListener('input', suggest);
document.addEventListener('click', (event) => {
  if (!form.contains(event.target)) suggestions.hidden = true;
});

const initial = new URLSearchParams(location.search).get('pernr');
if (initial) {
  input.value = initial;
  lookup(initial);
}
