*&---------------------------------------------------------------------*
*& Report ZEMP_LIST
*& Prints personnel number and name of employees valid on a key date
*&---------------------------------------------------------------------*
REPORT zemp_list LINE-SIZE 80.

DATA gv_pernr TYPE zif_emp_repository=>ty_pernr.
DATA go_list TYPE REF TO zcl_emp_list.
DATA gt_lines TYPE zcl_emp_list=>ty_lines.
DATA gv_line TYPE string.

SELECT-OPTIONS s_pernr FOR gv_pernr.
PARAMETERS p_date TYPE sy-datum DEFAULT sy-datum OBLIGATORY.

TOP-OF-PAGE.
  WRITE: / 'Employee No.'(h01), AT zcl_emp_list=>c_name_column 'Name'(h02).
  ULINE.

START-OF-SELECTION.
  go_list = NEW zcl_emp_list( NEW zcl_emp_repository_pa0001( ) ).
  gt_lines = go_list->build_lines( it_pernr   = s_pernr[]
                                   iv_keydate = p_date ).

  IF gt_lines IS INITIAL.
    MESSAGE s001(zemp_list) DISPLAY LIKE 'W'.
    RETURN.
  ENDIF.

  LOOP AT gt_lines INTO gv_line.
    WRITE / gv_line.
  ENDLOOP.
