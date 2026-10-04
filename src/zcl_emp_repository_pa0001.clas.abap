CLASS zcl_emp_repository_pa0001 DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_emp_repository.

ENDCLASS.


CLASS zcl_emp_repository_pa0001 IMPLEMENTATION.

  METHOD zif_emp_repository~get_employees.
    TYPES:
      BEGIN OF ty_pa0001,
        pernr TYPE pa0001-pernr,
        ename TYPE pa0001-ename,
        werks TYPE pa0001-werks,
        persg TYPE pa0001-persg,
        persk TYPE pa0001-persk,
        vdsk1 TYPE pa0001-vdsk1,
      END OF ty_pa0001.
    DATA lt_pa0001 TYPE STANDARD TABLE OF ty_pa0001 WITH EMPTY KEY.
    DATA ls_pa0001 TYPE ty_pa0001.
    DATA ls_employee TYPE zif_emp_repository=>ty_employee.

    " Infotype 0001 (Organizational Assignment) holds ENAME, the formatted employee name
    SELECT pernr, ename, werks, persg, persk, vdsk1
      FROM pa0001
      WHERE pernr IN @it_pernr
        AND begda <= @iv_keydate
        AND endda >= @iv_keydate
      ORDER BY pernr
      INTO TABLE @lt_pa0001.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_pa0001 INTO ls_pa0001.
      AUTHORITY-CHECK OBJECT 'P_ORGIN'
        ID 'INFTY' FIELD '0001'
        ID 'SUBTY' DUMMY
        ID 'AUTHC' FIELD 'R'
        ID 'PERSA' FIELD ls_pa0001-werks
        ID 'PERSG' FIELD ls_pa0001-persg
        ID 'PERSK' FIELD ls_pa0001-persk
        ID 'VDSK1' FIELD ls_pa0001-vdsk1.
      IF sy-subrc = 0.
        ls_employee-pernr = ls_pa0001-pernr.
        ls_employee-ename = ls_pa0001-ename.
        INSERT ls_employee INTO TABLE rt_employees.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
