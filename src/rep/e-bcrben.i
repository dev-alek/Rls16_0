/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет о выручке  - сбор данных по чекам - общая часть для второго прохода по чекам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

        if FIRST-of( chk-pay.curr-code ) then do:
          assign
          acc-sub-curr-sum = 0
          acc-sub-curr-base = 0
          acc-sub-curr-rubl = 0
          acc-curr-sum = 0
          acc-curr-base = 0
          acc-curr-rubl = 0
          .
        end.
        
        if v-is-sub-count then do:
          assign
          acc-sub-curr-sum  = acc-sub-curr-sum  + chk-pay.tot-sum
          acc-sub-curr-base = acc-sub-curr-base + chk-pay.tot-base
          acc-sub-curr-rubl = acc-sub-curr-rubl + chk-pay.tot-rubl
          acc-sub-date-base = acc-sub-date-base + chk-pay.tot-base
          acc-sub-date-rubl = acc-sub-date-rubl + chk-pay.tot-rubl
          .
        END.
        assign
        acc-curr-sum  = acc-curr-sum  + chk-pay.tot-sum
        acc-curr-base = acc-curr-base + chk-pay.tot-base
        acc-curr-rubl = acc-curr-rubl + chk-pay.tot-rubl
        acc-date-base = acc-date-base + chk-pay.tot-base
        acc-date-rubl = acc-date-rubl + chk-pay.tot-rubl
        acc-count-ln  = acc-count-ln  + 1
        .
if acc-count-ln > acc-count-step then do:
  run waitfram-show in this-procedure ( obj-list.obj-type + string( obj-list.obj-code ) +
                                  ", обработано строк чеков : " +
                                  string( ACC-count-ln) ) .
  acc-count-step = acc-count-ln + 96 .                                  
end.

if last-of( chk-pay.curr-code ) and (acc-curr-sum - acc-sub-curr-sum) <> 0 then do:
  run CreateBenefits in this-procedure 
  ( obj-list.obj-type
  , obj-list.obj-code
  , chk-pay.pay-code
  , chk-pay.curr-code
  , {1}
  , (acc-curr-sum  - acc-sub-curr-sum)
  , (acc-curr-base - acc-sub-curr-base)
  , (acc-curr-rubl - acc-sub-curr-rubl)
  ) .
  if not v-is-sub-count then do :
  if not can-find (first ben-chk-count where ben-chk-count.doc-code  = chk-pay.doc-code
                                         and ben-chk-count.obj-type  = obj-list.obj-type
                                         and ben-chk-count.obj-code  = obj-list.obj-code
                                         and ben-chk-count.date_     = {1}
                                         and ben-chk-count.pay-code  = chk-pay.pay-code
                                         and ben-chk-count.curr-code = chk-pay.curr-code) then do:
    create ben-chk-count.
    assign
      ben-chk-count.doc-code  = chk-pay.doc-code
      ben-chk-count.obj-type  = obj-list.obj-type
      ben-chk-count.obj-code  = obj-list.obj-code
      ben-chk-count.date_     = {1}
      ben-chk-count.pay-code  = chk-pay.pay-code
      ben-chk-count.curr-code = chk-pay.curr-code
    .
  end.
  end .
end. /* end_of last_of curr_code */


/* $Workfile$ e n d */