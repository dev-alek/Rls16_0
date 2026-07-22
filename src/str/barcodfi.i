/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение информации о баркод

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/09/10
Author: Bakhtadze Natalya
Creation date: 07/09/10

Используется в программах списков

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/nativstr.i }

FUNCTION barcodfi_node-code-name returns character ( buffer buf_bar-code for ub.bar-code):
define variable v-f-name as character no-undo .
FIND FIRST buf_gds-prt No-LOCK where
            buf_gds-prt.node-code = buf_bar-code.node-code NO-ERROR.
if available buf_gds-prt then do:
  assign
  v-f-name = buf_gds-prt.f-name.
end.
else do:
  v-f-name = "!!!Неизвестный признак".
end.
return v-f-name .
end function.


PROCEDURE barcodfi:
DEFINE PARAMETER BUFFER fi-bar-code for ub.bar-code.
DEFINE INPUT PARAMETER v-barcodfi as char no-undo.
define input parameter p-excel as logical no-undo .
DEFINE INPUT-OUTPUT PARAMETER fi-1 as char no-undo.
DEFINE VARiable II AS INTEGER NO-UNDO.
DEFINE variable myfi as char no-undo extent 1.
DEFINE VARiable jj as integer no-undo init 1.
DEFINE variable Myformat as character no-undo.
DEFINE VARiable vNum-entries as integer no-undo.
DEFINE VARiable entry-ii as character no-undo.
DEFINE VARiable vvalue as character no-undo.
DEFINE VARiable vtype as character no-undo.
DEFINE VARiable vlabel as character no-undo.
define buffer buf_usr-flt_custom-labels for usr-flt_custom-labels.
  IF v-barcodfi = "" then
  v-barcodfi = {&barcodfi-ord}.
 if avail fi-bar-code then do:

vNum-entries = NUm-ENTRIES(v-barcodfi).

&scop J-plus
  DO ii = 1 to vNum-entries:
    entry-ii = ENTRY(ii, v-barcodfi).
    find first buf_usr-flt_custom-labels where
              buf_usr-flt_custom-labels.tbl-name = entry(1, entry-ii, ".")
         and  buf_usr-flt_custom-labels.fld-name = entry(2, entry-ii, ".")
         and  buf_usr-flt_custom-labels.call-point = {&uf-barcodfi}
         and  buf_usr-flt_custom-labels.call-type = {&add-fields} no-error.
    if  available buf_usr-flt_custom-labels then do:
      case buf_usr-flt_custom-labels.tbl-name:
        when {&table_bar-code} then do:
          if entry(2, entry-ii, ".") begins "#" then do:
            assign
            myfi[jj] = string(dynamic-function(buf_usr-flt_custom-labels.custom-view-func, buffer fi-bar-code)
                              , buf_usr-flt_custom-labels.custom-format) no-error .
          end.
          else do:
            myfi[jj] =  string(buffer fi-bar-code:buffer-field(buf_usr-flt_custom-labels.fld-name):buffer-value, buf_usr-flt_custom-labels.custom-format).

          end.
        end.
      end case.
      if p-excel then do:
        if buf_usr-flt_custom-labels.fld-data-type = {&abl-datatype-decimal}
        or buf_usr-flt_custom-labels.fld-data-type = {&abl-datatype-integer}
        then do:
          myfi[jj] = replace(myfi[jj], {&comma-char}, "").
        end.
      end.
      {&j-plus}
    end.
  END.
  end.
  assign
  fi-1 = myfi[1]
  .

END PROCEDURE.

/* $Workfile$ e n d */