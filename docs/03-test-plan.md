# 03 – Test Plan

## Level 1 – Automated (every push / PR, GitHub Actions)
| Check        | Tool                                  | Command        |
|--------------|---------------------------------------|----------------|
| Static check | abaplint (`abaplint.json`, release v757) | `npm run lint` |
| ABAP Unit    | open-abap transpiler (runs ABAP in Node) | `npm run unit` |

ABAP Unit cases (`ZCL_EMP_LIST`, local class `LTCL_EMP_LIST`):
| Test method                  | Covers |
|------------------------------|--------|
| `formats_number_and_name`    | AC1    |
| `sorts_by_personnel_number`  | AC2    |
| `removes_duplicates`         | AC2    |
| `empty_when_no_employees`    | AC6 (logic side) |
| `passes_selection_through`   | AC3, AC4 (selection reaches data layer) |

`ZEMP_LIST` and `ZCL_EMP_REPOSITORY_PA0001` are excluded from transpiled tests (they need the SAP DB/kernel); abaplint still checks them.

## Level 2 – In SAP DEV
- ATC run on package `ZEMPLOYEE` (no priority 1/2 findings).
- ABAP Unit via SE80 / ADT (Ctrl+Shift+F10) on package `ZEMPLOYEE`.

## Level 3 – QAS (SIT/UAT)
| # | Scenario                                         | Expected                          | AC  |
|---|--------------------------------------------------|-----------------------------------|-----|
| 1 | Run with no PERNR restriction, today             | All active employees, sorted      | 1,2,3 |
| 2 | Restrict PERNR to a range                        | Only that range                   | 4   |
| 3 | Key date before an employee's hire date          | Employee not listed               | 3   |
| 4 | User without `P_ORGIN` for a personnel area      | Those employees hidden            | 5   |
| 5 | PERNR range with no employees                    | Message ZEMP_LIST 001             | 6   |
| 6 | Print the list (Ctrl+P → printer / PDF)           | Header and lines printed          | 7   |
