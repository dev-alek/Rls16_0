/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение диапазона fact-order для всех клиентов

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create Суслов Алексей Юрьевич

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

assign fact-order-min = 0
       fact-order-max = 0.
for each tt-clients:
   run dfactord (input  tt-clients.obj-type,
                 input  tt-clients.obj-code,
                 input  (if varis-calend = 1 then yes else no),
                 input  varis-shift-num,
                 input  vardate-start,
                 input  vardate-end,
                 input  varshift-start,
                 input  varshift-end,
                 output fact-order-start,
                 output fact-order-end) no-error.
   if error-status:error then do:
      message "Ошибка при определении диапазона данных."
      view-as alert-box error.
      return no-apply.
   end.
   if fact-order-end = 0 then next.
   if fact-order-start > fact-order-min then assign fact-order-min = fact-order-start.
   if fact-order-end   > fact-order-max then assign fact-order-max = fact-order-end.
/* $Workfile$ e n d */