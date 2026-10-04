CLASS ltd_repository DEFINITION FOR TESTING FINAL.

  PUBLIC SECTION.
    INTERFACES zif_emp_repository.

    DATA mt_employees TYPE zif_emp_repository=>ty_employees.
    DATA mt_received_pernr TYPE zif_emp_repository=>ty_pernr_range.
    DATA mv_received_keydate TYPE d.

ENDCLASS.


CLASS ltd_repository IMPLEMENTATION.

  METHOD zif_emp_repository~get_employees.
    mt_received_pernr = it_pernr.
    mv_received_keydate = iv_keydate.
    rt_employees = mt_employees.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_emp_list DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO ltd_repository.
    DATA mo_cut TYPE REF TO zcl_emp_list.

    METHODS setup.
    METHODS formats_number_and_name FOR TESTING.
    METHODS sorts_by_personnel_number FOR TESTING.
    METHODS removes_duplicates FOR TESTING.
    METHODS empty_when_no_employees FOR TESTING.
    METHODS passes_selection_through FOR TESTING.

ENDCLASS.


CLASS ltcl_emp_list IMPLEMENTATION.

  METHOD setup.
    mo_repository = NEW #( ).
    mo_cut = NEW #( mo_repository ).
  ENDMETHOD.

  METHOD formats_number_and_name.
    mo_repository->mt_employees = VALUE #( ( pernr = '00001001' ename = 'John Smith' ) ).

    DATA(lt_lines) = mo_cut->build_lines( it_pernr   = VALUE #( )
                                          iv_keydate = '20260101' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_lines
      exp = VALUE zcl_emp_list=>ty_lines( ( |00001001      John Smith| ) ) ).
  ENDMETHOD.

  METHOD sorts_by_personnel_number.
    mo_repository->mt_employees = VALUE #(
      ( pernr = '00000300' ename = 'Carol' )
      ( pernr = '00000100' ename = 'Alice' )
      ( pernr = '00000200' ename = 'Bob' ) ).

    DATA(lt_lines) = mo_cut->build_lines( it_pernr   = VALUE #( )
                                          iv_keydate = '20260101' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_lines
      exp = VALUE zcl_emp_list=>ty_lines(
        ( |00000100      Alice| )
        ( |00000200      Bob| )
        ( |00000300      Carol| ) ) ).
  ENDMETHOD.

  METHOD removes_duplicates.
    mo_repository->mt_employees = VALUE #(
      ( pernr = '00000100' ename = 'Alice' )
      ( pernr = '00000100' ename = 'Alice' ) ).

    DATA(lt_lines) = mo_cut->build_lines( it_pernr   = VALUE #( )
                                          iv_keydate = '20260101' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 1 ).
  ENDMETHOD.

  METHOD empty_when_no_employees.
    DATA(lt_lines) = mo_cut->build_lines( it_pernr   = VALUE #( )
                                          iv_keydate = '20260101' ).

    cl_abap_unit_assert=>assert_initial( lt_lines ).
  ENDMETHOD.

  METHOD passes_selection_through.
    DATA(lt_pernr) = VALUE zif_emp_repository=>ty_pernr_range(
      ( sign = 'I' option = 'BT' low = '00000100' high = '00000199' ) ).

    mo_cut->build_lines( it_pernr   = lt_pernr
                         iv_keydate = '20261004' ).

    cl_abap_unit_assert=>assert_equals( act = mo_repository->mt_received_pernr
                                        exp = lt_pernr ).
    cl_abap_unit_assert=>assert_equals( act = mo_repository->mv_received_keydate
                                        exp = '20261004' ).
  ENDMETHOD.

ENDCLASS.
