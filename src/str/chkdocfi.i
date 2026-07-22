/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение информации о чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/09/10
Author: Bakhtadze Natalya
Creation date: 07/09/10

Используется в программах списков чеков

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/nativstr.i }

FUNCTION chkdocfi_chk-type-name returns character ( buffer buf_chk-doc for ub.chk-doc):
&scop RECEIPT-CODE string(buf_chk-doc.chk-type)
return {&receipt-name}.
end function.

FUNCTION chkdocfi_chk-time-chr returns character ( buffer buf_chk-doc for ub.chk-doc):
return string(buf_chk-doc.chk-time, "HH:MM:SS").
end function.

FUNCTION chkdocfi_cashier-psn-code-name returns character ( buffer buf_chk-doc for ub.chk-doc):
find first buf_clients no-lock where
          buf_clients.obj-type = {&prs}
      and buf_clients.obj-code = buf_chk-doc.cashier-psn-code no-error.
if available buf_clients then do:
  return buf_clients.obj-name.
end.
else do:
  return substitute("!Не найдено ФЛ (код &1)", buf_chk-doc.cashier-psn-code).
end.
end function.


FUNCTION chkdocfi_cli-name returns character ( buffer buf_chk-doc for ub.chk-doc):
if lookup(string(buf_chk-doc.chk-type), {&wth-receipt-codes}) > 0 then return ''.
if not (buf_chk-doc.cli-code = 0
or buf_chk-doc.cli-code = ?) then do:
  find first buf_clients no-lock where
            buf_clients.obj-type = buf_chk-doc.cli-type
        and buf_clients.obj-code = buf_chk-doc.cli-code no-error.
  if available buf_clients then do:
    return buf_clients.obj-name.
  end.
  else do:
    return substitute("!!!Не найден клиент &1&2", buf_chk-doc.cli-type, buf_chk-doc.cli-code).
  end.
end.
return ''.
end function.

FUNCTION chkdocfi_salesman-psn-code-name returns character ( buffer buf_chk-doc for ub.chk-doc):
if lookup(string(buf_chk-doc.chk-type), {&wth-receipt-codes}) > 0 then return ''.
if not (buf_chk-doc.salesman-psn-code = 0
        or
        buf_chk-doc.salesman-psn-code = ?) then do:
  find first buf_clients no-lock where
            buf_clients.obj-type = {&prs}
        and buf_clients.obj-code = buf_chk-doc.salesman-psn-code no-error.
  if available buf_clients then do:
    return buf_clients.obj-name.
  end.
  else do:
    return substitute("!Не найдено ФЛ (код &1)", buf_chk-doc.salesman-psn-code).
  end.
end.
else do:
  return ''.
end.
end function.


PROCEDURE chkdocfi:
DEFINE PARAMETER BUFFER fi-chk-doc for ub.chk-doc.
DEFINE INPUT PARAMETER v-chkdocfi as char no-undo.
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
  IF v-chkdocfi = "" then
  v-chkdocfi = {&chkdocfi-ord}.
 if avail fi-chk-doc then do:

vNum-entries = NUm-ENTRIES(v-chkdocfi).

&scop J-plus
  DO ii = 1 to vNum-entries:
    entry-ii = ENTRY(ii, v-chkdocfi).
    find first buf_usr-flt_custom-labels where
              buf_usr-flt_custom-labels.tbl-name = entry(1, entry-ii, ".")
         and  buf_usr-flt_custom-labels.fld-name = entry(2, entry-ii, ".")
         and  buf_usr-flt_custom-labels.call-point = {&uf-chkdocfi}
         and  buf_usr-flt_custom-labels.call-type = {&add-fields} no-error.
    if  available buf_usr-flt_custom-labels then do:
      case buf_usr-flt_custom-labels.tbl-name:
        when {&table_chk-doc} then do:
          if entry(2, entry-ii, ".") begins "#" then do:
            assign
            myfi[jj] = string(dynamic-function(buf_usr-flt_custom-labels.custom-view-func, buffer fi-chk-doc)
                              , buf_usr-flt_custom-labels.custom-format) no-error .
          end.
          else do:
            myfi[jj] =  string(buffer fi-chk-doc:buffer-field(buf_usr-flt_custom-labels.fld-name):buffer-value, buf_usr-flt_custom-labels.custom-format).

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