/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отчет о выручке  - сбор данных по чекам - общая часть для первого прохода по чекам

Автор: Молотков Сергей Михайлович
Дата создания: 05/09/17
Author: Molotkov Sergey
Creation date: 05/09/17

*/
/*

Структура отчёта

shop1
  наличные rub
  товар1
  товар2
  товар3
  наличные usd
  товар1
  товар2
  товар3
средн.чек = 
итого     =

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


for EACH buf-chk-pay no-lock
   WHERE buf-chk-pay.doc-code = buf-chk-doc.doc-code
     AND buf-chk-pay.tot-sum <> 0
BREAK by buf-chk-pay.doc-code
      BY buf-chk-pay.pay-code
      BY buf-chk-pay.curr-code:

  if first-of( buf-chk-pay.doc-code ) then do:
    assign
      acc-day-cnt = acc-day-cnt  + 1
    .
  end.
  
  for each buf-chk-gds-pay no-lock
     where buf-chk-gds-pay.doc-code   = buf-chk-pay.doc-code
       and buf-chk-gds-pay.algo-num   = v-algo-num
       and buf-chk-gds-pay.cpline-num = buf-chk-pay.line-num
  :
    /* на каждую долю оплаты добавляем:
       1. товар в подсчёт кол-ва чеков, в которых товар участвовал
       2. товар в подсчёт сумм, которые на него отнесены
    */
    if not can-find (first ben-chk-count where ben-chk-count.doc-code  = buf-chk-pay.doc-code
                                           and ben-chk-count.obj-type  = obj-list.obj-type
                                           and ben-chk-count.obj-code  = obj-list.obj-code
                                           and ben-chk-count.b-code    = buf-chk-gds-pay.b-code
                                           and ben-chk-count.pay-code  = buf-chk-pay.pay-code
                                           and ben-chk-count.curr-code = buf-chk-pay.curr-code) then do:
      create ben-chk-count.
      assign
        ben-chk-count.doc-code  = buf-chk-pay.doc-code
        ben-chk-count.obj-type  = obj-list.obj-type
        ben-chk-count.obj-code  = obj-list.obj-code
        ben-chk-count.b-code    = buf-chk-gds-pay.b-code
        ben-chk-count.pay-code  = buf-chk-pay.pay-code
        ben-chk-count.curr-code = buf-chk-pay.curr-code
      .
    end.
    find first tt-gds-sum where tt-gds-sum.b-code    = buf-chk-gds-pay.b-code
                            and tt-gds-sum.obj-type  = obj-list.obj-type
                            and tt-gds-sum.obj-code  = obj-list.obj-code 
                            and tt-gds-sum.pay-code  = buf-chk-pay.pay-code 
                            and tt-gds-sum.curr-code = buf-chk-pay.curr-code no-error.
    if not available tt-gds-sum then do:
      create tt-gds-sum.
      assign
        tt-gds-sum.obj-type  = obj-list.obj-type
        tt-gds-sum.obj-code  = obj-list.obj-code
        tt-gds-sum.pay-code  = buf-chk-pay.pay-code
        tt-gds-sum.curr-code = buf-chk-pay.curr-code
        tt-gds-sum.b-code    = buf-chk-gds-pay.b-code
        tt-gds-sum.gds-code  = 0
        tt-gds-sum.tot-r-b   = buf-chk-gds-pay.tot-r-b
      .                     
    end.
    else assign
      tt-gds-sum.tot-r-b   = tt-gds-sum.tot-r-b + buf-chk-gds-pay.tot-r-b
    .
      
  end. /* end_of for_each buf-chk-gds-pay */
  

  assign
    acc-day-rubl = acc-day-rubl + buf-chk-pay.tot-rubl
    acc-day-base = acc-day-base + buf-chk-pay.tot-base
  .
END. /* end_of for_each buf-chk-pay */

/* $Workfile$ e n d */