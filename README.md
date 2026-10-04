# ZEMP_LIST – Print employee number and name

ABAP report that lists personnel number and name of employees valid on a key date (SAP HCM infotype 0001), with the full delivery pipeline: requirement → design → abapGit source → CI (abaplint + ABAP Unit) → SAP transport.

| Doc | |
|---|---|
| [01 Requirement](docs/01-requirement.md) | Need, selection screen, output, acceptance criteria |
| [02 Technical design](docs/02-technical-design.md) | Objects, flow, decisions |
| [03 Test plan](docs/03-test-plan.md) | Automated, DEV, QAS test cases |
| [04 Process](docs/04-process.md) | End-to-end stages, gates, abapGit import |

```bash
npm ci && npm test
```
