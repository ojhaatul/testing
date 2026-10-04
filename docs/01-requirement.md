# 01 – Business Requirement

| Field        | Value                                         |
|--------------|-----------------------------------------------|
| ID           | REQ-EMP-001                                   |
| Title        | Print employee number and name                |
| Requested by | HR                                            |
| Program      | `ZEMP_LIST` (package `ZEMPLOYEE`)             |

## Need
HR users need a simple list of employees showing their **personnel number** and **name**, which can be viewed on screen and printed from the standard list output.

## Scope
- In: employees with an Organizational Assignment (infotype 0001) record valid on a chosen key date.
- Out: other employee attributes, ALV/Excel export, background email distribution.

## Selection screen
| Field              | Type                     | Default    | Mandatory |
|--------------------|--------------------------|------------|-----------|
| Personnel number   | Select-option (`PERNR`)  | all        | No        |
| Key date           | Date                     | today      | Yes       |

## Output
```
Employee No.  Name
--------------------------------------------------------------------------------
00001001      John Smith
00001002      Jane Doe
```

## Acceptance criteria
1. AC1 – Each line shows the 8-digit personnel number followed by the employee name, name starting at column 15.
2. AC2 – Lines are sorted ascending by personnel number, with no duplicates.
3. AC3 – Only employees whose infotype 0001 record is valid on the key date are listed.
4. AC4 – The personnel number selection restricts the list.
5. AC5 – Employees the user is not authorized for (`P_ORGIN`, infotype 0001, read) are not shown.
6. AC6 – If nothing is found, status message `ZEMP_LIST 001` "No employees found for the selection" is shown.
7. AC7 – The list can be printed via the standard list print function (Ctrl+P).
