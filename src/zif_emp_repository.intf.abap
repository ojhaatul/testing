INTERFACE zif_emp_repository PUBLIC.

  TYPES ty_pernr TYPE n LENGTH 8.
  TYPES ty_ename TYPE c LENGTH 40.
  TYPES ty_pernr_range TYPE RANGE OF ty_pernr.

  TYPES:
    BEGIN OF ty_employee,
      pernr TYPE ty_pernr,
      ename TYPE ty_ename,
    END OF ty_employee.
  TYPES ty_employees TYPE STANDARD TABLE OF ty_employee WITH EMPTY KEY.

  "! Employees valid on the key date, restricted to the given personnel numbers
  METHODS get_employees
    IMPORTING
      it_pernr            TYPE ty_pernr_range
      iv_keydate          TYPE d
    RETURNING
      VALUE(rt_employees) TYPE ty_employees.

ENDINTERFACE.
