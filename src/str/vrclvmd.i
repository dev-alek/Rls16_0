/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка атрибута клиента ATTR-VETO-MANUAL-DOC

Автор: Чернова Светлана Александровна
Дата создания: 02/09/10
Author: Svetlana Chernova
Creation date: 02/09/10

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if defined (include_clntattr) = 0 &then
{ gbl/clntattr.i }
&endif

procedure ver-clients :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-error as logical   no-undo .

define variable v-veto-man-doc as character no-undo .
define variable v-type        as character no-undo .

  do
  on error undo, return error return-value
  :
  p-error = false .

run clntattr-value in this-procedure (
 input p-obj-type ,
 input p-obj-code ,
 input {&attr-veto-man-doc}     ,
 output v-veto-man-doc ,
 output v-type        ) no-error .
 if error-status :error then message
   error-status :get-message(1) skip
   return-value skip
   "Ошибка clntattr-veto-man-doc"
   view-as alert-box error
 .

  if v-veto-man-doc = 'ALL' then do:
      message "Запрещено создание документа на этого контрагента оператору вручную." view-as alert-box error  .
      p-error = true .
  end.

 end.
end procedure. /* ver-clients */