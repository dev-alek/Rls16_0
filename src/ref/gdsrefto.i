/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Лейблы полей, которые в справочнике товара для просмотра настраиваются по пользователю через настройку gdsreffi

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE gds-ref-to:

DEFINE INPUT PARAMETER v-gds-ref-fi as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-1 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-2 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-3 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-4 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-5 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-6 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-7 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-8 as char no-undo.

DEFINE VARiable II AS INTEGER NO-UNDO.
DEFINE variable myto as char no-undo extent 8.
DEFINE variable mypr as char no-undo extent 8.
DEFINE VARiable jj as integer no-undo init 1.
DEFINE VARiable vNum-entries as integer no-undo.
DEFINE VARiable entry-ii as char no-undo.
define buffer buf_custom-labels for ub.custom-labels.
define buffer buf_usr-flt_custom-labels for usr-flt_custom-labels.
&Scoped-define conf-error-message message "Для пользователя " v-cntxt-userid skip ~
"настройки доп.поле справочника товаров содержат неопознанный элемент " ENTRY-ii skip ~
"Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
return-value skip view-as alert-box ERROR.

IF v-gds-ref-fi = "" then
v-gds-ref-fi = {&gdsreffi-ord}.
vNum-entries = NUm-ENTRIES(v-gds-ref-fi).
for each usr-flt_custom-labels:
  delete usr-flt_custom-labels.
end.
DO ii = 1 to vNum-entries:
   entry-ii = ENTRY(ii, v-gds-ref-fi).
  find first buf_custom-labels no-lock where
          buf_custom-labels.tbl-name = entry(1, entry-ii, ".":U)
      and buf_custom-labels.fld-name = entry(2, entry-ii, ".":U)
      and buf_custom-labels.call-point = {&uf-gdsreffi}
      and buf_custom-labels.call-type = {&add-fields}
      no-error.
   if available buf_custom-labels then do:
     create buf_usr-flt_custom-labels.
     buffer-copy buf_custom-labels to buf_usr-flt_custom-labels.
      assign
      myto[jj] =  buf_custom-labels.custom-tooltip
      .
   end.
   else do:
    {&conf-error-message}
   END.
   jj = jj + 1.
   if jj = 9 then LEAVE.
END.
assign
to-1 = myto[1]
to-2 = myto[2]
to-3 = myto[3]
to-4 = myto[4]
to-5 = myto[5]
to-6 = myto[6]
to-7 = myto[7]
to-8 = myto[8]
.
END PROCEDURE.

PROCEDURE gds-ref-to-description:
define variable v-ok  as logical no-undo .
  run ref/cstmlabs.w ( input parparentproc
                     ,input {&add-fields}
                     ,input {&uf-gdsreffi}
                     ,input no
                     ,input 8
                     ,output v-ok
                     ) no-error.
if v-ok then do:
  message
  "Изменения вступят в силу при следующем входе в справочник товаров"
  view-as alert-box warning.
end.
END PROCEDURE.