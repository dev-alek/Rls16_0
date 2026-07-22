/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение информации о строке  чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/09/10
Author: Bakhtadze Natalya
Creation date: 07/09/10

Используется в программах списков строк чека

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/nativstr.i }

FUNCTION chkgdsfi_pcnt returns decimal ( buffer buf_chk-gds for ub.chk-gds):
define variable v-pcnt as decimal no-undo .
if buf_chk-gds.price-base = 0 then do:
  v-pcnt = 0.
end.
else do:
  v-pcnt = buf_chk-gds.discnt / buf_chk-gds.price-base * 100.
end.
return v-pcnt.
end function.

FUNCTION chkgdsfi_price-netto returns decimal ( buffer buf_chk-gds for ub.chk-gds):
return (buf_chk-gds.price-base - buf_chk-gds.discnt).
end function.

FUNCTION chkgdsfi_sum-netto returns decimal ( buffer buf_chk-gds for ub.chk-gds):
return ((buf_chk-gds.price-base - buf_chk-gds.discnt) * buf_chk-gds.doc-qnty).
end function.

FUNCTION chkgdsfi_write-off-name returns character ( buffer buf_chk-gds for ub.chk-gds):
&GLOBAL-DEFINE wro-code STRING(if buf_chk-gds.write-off-code = ? then 0 else buf_chk-gds.write-off-code)
return {&wro-name}.
end function.

FUNCTION chkgdsfi_pass-gds-name returns character ( buffer buf_chk-gds for ub.chk-gds):
&GLOBAL-DEFINE pass-gds-code STRING(if buf_chk-gds.pass-gds = ? then 0 else buf_chk-gds.pass-gds)
return {&pass-gds-name}.
end function.


FUNCTION chkgdsfi_salesman-psn-code-name returns character ( buffer buf_chk-gds for ub.chk-gds):
if not (buf_chk-gds.salesman-psn-code = 0
        or
        buf_chk-gds.salesman-psn-code = ?) then do:
  find first buf_clients no-lock where
            buf_clients.obj-type = {&prs}
        and buf_clients.obj-code = buf_chk-gds.salesman-psn-code no-error.
  if available buf_clients then do:
    return buf_clients.obj-name.
  end.
  else do:
    return substitute("!!!Не найдено физ.лицо с кодом &1", buf_chk-gds.salesman-psn-code).
  end.
end.
else do:
  return ''.
end.
end function.


PROCEDURE chkgdsfi:
DEFINE PARAMETER BUFFER fi-chk-gds for ub.chk-gds.
DEFINE INPUT PARAMETER v-chkgdsfi as char no-undo.
define input parameter p-excel as logical no-undo .
DEFINE INPUT-OUTPUT PARAMETER fi-1 as char no-undo.
DEFINE VARiable II AS INTEGER NO-UNDO.
DEFINE BUFFER fi-gds-prt for gds-prt.
DEFINE variable myfi as char no-undo extent 1.
DEFINE VARiable jj as integer no-undo init 1.
DEFINE variable Myformat as character no-undo.
DEFINE VARiable vNum-entries as integer no-undo.
DEFINE VARiable entry-ii as character no-undo.
DEFINE VARiable vvalue as character no-undo.
DEFINE VARiable vtype as character no-undo.
DEFINE VARiable vlabel as character no-undo.
define buffer buf_usr-flt_custom-labels for usr-flt_custom-labels.
  IF v-chkgdsfi = "" then
  v-chkgdsfi = {&chkgdsfi-ord}.
 if avail fi-chk-gds then do:

vNum-entries = NUm-ENTRIES(v-chkgdsfi).

&scop J-plus
  DO ii = 1 to vNum-entries:
    entry-ii = ENTRY(ii, v-chkgdsfi).
    find first buf_usr-flt_custom-labels where
              buf_usr-flt_custom-labels.tbl-name = entry(1, entry-ii, ".")
         and  buf_usr-flt_custom-labels.fld-name = entry(2, entry-ii, ".")
         and  buf_usr-flt_custom-labels.call-point = {&uf-chkgdsfi}
         and  buf_usr-flt_custom-labels.call-type = {&add-fields} no-error.
    if  available buf_usr-flt_custom-labels then do:
      case buf_usr-flt_custom-labels.tbl-name:
        when {&table_chk-gds} then do:
          if entry(2, entry-ii, ".") begins "#" then do:
            assign
            myfi[jj] = string(dynamic-function(buf_usr-flt_custom-labels.custom-view-func, buffer fi-chk-gds)
                              , buf_usr-flt_custom-labels.custom-format) no-error .
          end.
          else do:
            myfi[jj] =  string(buffer fi-chk-gds:buffer-field(buf_usr-flt_custom-labels.fld-name):buffer-value, buf_usr-flt_custom-labels.custom-format).

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