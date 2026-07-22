/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
Поиск 2-х fact-order-ов за диапазон дат.

!!! РАБОТАЕТ ВМЕСТЕ С LASTORDR.I !!!

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dfactord:
define input  parameter parobj-type         like ub.clients.obj-type   no-undo.
define input  parameter parobj-code         like ub.clients.obj-code   no-undo.
define input  parameter paris-calend-day    as   logical            no-undo. /*календарные или сменные сутки*/
define input  parameter paris-shift-num     as   logical            no-undo. /*по порядкам смен или только учитывая сменные сутки*/
define input  parameter pardate-start       as   date               no-undo.
define input  parameter pardate-end         as   date               no-undo.
define input  parameter parshift-start      as   integer            no-undo.
define input  parameter parshift-end        as   integer            no-undo.
define output parameter parfact-order-start like ub.stk-tot.fact-order no-undo.
define output parameter parfact-order-end   like ub.stk-tot.fact-order no-undo.
/*Расчет двух fact-order*/
if paris-calend-day then do:
   /*Календарные сутки*/
   run lastordr
       (input  parobj-type,
        input  parobj-code,
        input  no,
        input  ?,
        input  pardate-start - 1,
        input  ?,
        output parfact-order-start) no-error.
   if error-status:error then return error.
   run lastordr
       (input  parobj-type,
        input  parobj-code,
        input  no,
        input  ?,
        input  pardate-end,
        input  ?,
        output parfact-order-end) no-error.
   if error-status:error then return error.
end.
else do:
   /*Сменные сутки*/
   if paris-shift-num then do:
      /*С номерами смен*/
      run lastordr
          (input  parobj-type,
           input  parobj-code,
           input  yes,
           input  yes,
           input  pardate-start,
           input  parshift-start - 1,
           output parfact-order-start) no-error.
      if error-status:error then return error.
      run lastordr
          (input  parobj-type,
           input  parobj-code,
           input  yes,
           input  yes,
           input  pardate-end,
           input  parshift-end,
           output parfact-order-end) no-error.
      if error-status:error then return error.
   end.
   else do:
      /*Без номеров смен*/
      run lastordr
          (input  parobj-type,
           input  parobj-code,
           input  yes,
           input  no,
           input  pardate-start - 1,
           input  ?,
           output parfact-order-start) no-error.
      if error-status:error then return error.
      run lastordr
          (input  parobj-type,
           input  parobj-code,
           input  yes,
           input  no,
           input  pardate-end,
           input  ?,
           output parfact-order-end) no-error.
      if error-status:error then return error.
   end.
end.
end procedure.
/*end of dfactord.i*/