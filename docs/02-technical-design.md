# 02 – Technical Design

## Objects (package `ZEMPLOYEE`)
| Object                      | Type      | Purpose                                                      |
|-----------------------------|-----------|--------------------------------------------------------------|
| `ZEMP_LIST`                 | PROG      | Executable report: selection screen, list output             |
| `ZIF_EMP_REPOSITORY`        | INTF      | Data-access contract `GET_EMPLOYEES( it_pernr, iv_keydate )` |
| `ZCL_EMP_REPOSITORY_PA0001` | CLAS      | Reads `PA0001` (PERNR, ENAME) valid on key date + `P_ORGIN` check |
| `ZCL_EMP_LIST`              | CLAS      | Sorts, de-duplicates and formats output lines (unit tested)  |
| `ZEMP_LIST`                 | MSAG      | Message 001 "No employees found for the selection"           |

## Flow
```
ZEMP_LIST (report)
  └─ ZCL_EMP_LIST->build_lines( s_pernr[], p_date )
        └─ ZIF_EMP_REPOSITORY->get_employees( )      <- ZCL_EMP_REPOSITORY_PA0001 in production
                                                     <- LTD_REPOSITORY test double in ABAP Unit
  └─ WRITE each line (TOP-OF-PAGE prints header)
```

## Design decisions
- **Data source**: `PA0001-ENAME` is SAP HCM's pre-formatted "formatted name of employee", so no name assembly from `PA0002` is needed. Key-date filter on `BEGDA`/`ENDDA`.
- **Authorization**: explicit `AUTHORITY-CHECK OBJECT 'P_ORGIN'` per record (infotype 0001, read). If the client uses structural authorizations, swap the repository implementation for one using `HR_READ_INFOTYPE` or logical database `PNPCE` — the report and formatter are unaffected.
- **Testability**: database access is behind `ZIF_EMP_REPOSITORY`, so the business logic in `ZCL_EMP_LIST` runs in ABAP Unit without DB data, both in SAP and in CI via the open-abap transpiler.
- **Output**: classic list (`WRITE`) since the requirement is a printable list; ALV is out of scope.
- **Non-HCM systems**: if employees live in a custom table, implement `ZIF_EMP_REPOSITORY` against it; nothing else changes.
