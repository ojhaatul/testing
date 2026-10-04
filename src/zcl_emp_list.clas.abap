CLASS zcl_emp_list DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    CONSTANTS c_name_column TYPE i VALUE 15.

    "! @parameter io_repository | Source of employee data
    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO zif_emp_repository.

    "! One output line per employee: personnel number, then name at column C_NAME_COLUMN
    METHODS build_lines
      IMPORTING
        it_pernr        TYPE zif_emp_repository=>ty_pernr_range
        iv_keydate      TYPE d
      RETURNING
        VALUE(rt_lines) TYPE ty_lines.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO zif_emp_repository.

ENDCLASS.


CLASS zcl_emp_list IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD build_lines.
    DATA ls_employee TYPE zif_emp_repository=>ty_employee.
    DATA lv_line TYPE string.

    DATA(lt_employees) = mo_repository->get_employees(
      it_pernr   = it_pernr
      iv_keydate = iv_keydate ).

    SORT lt_employees BY pernr.
    DELETE ADJACENT DUPLICATES FROM lt_employees COMPARING pernr.

    LOOP AT lt_employees INTO ls_employee.
      lv_line = |{ ls_employee-pernr WIDTH = c_name_column - 1 }{ ls_employee-ename }|.
      INSERT lv_line INTO TABLE rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
