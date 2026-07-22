/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отчет о выручке  - сбор данных по чекам - общая часть для первого прохода по чекам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
/*define variable acc-count-ln as int no-undo.*/
        acc-count-ln = acc-count-ln + 1.
if acc-count-ln > acc-count-step then do:
  run waitfram-show in this-procedure ( obj-list.obj-type + string( obj-list.obj-code ) +
                                  ", обработано строк чеков : " +
                                  string( ACC-count-ln) ) .
  acc-count-step = acc-count-ln + 96 .                                  
end.
        
        if FIRST-of( chk-pay.curr-code ) then assign
          acc-curr-sum  = 0
          acc-curr-base = 0
          acc-curr-rubl = 0
        .
          
      assign
          acc-curr-sum  = acc-curr-sum  + chk-pay.tot-sum
          acc-curr-base = acc-curr-base + chk-pay.tot-base
          acc-curr-rubl = acc-curr-rubl + chk-pay.tot-rubl
          acc-desk-base = acc-desk-base + chk-pay.tot-base
          acc-desk-rubl = acc-desk-rubl + chk-pay.tot-rubl
      .

if last-of( chk-pay.curr-code ) then do:
  run CreateBenefits2 in this-procedure
  ( obj-list.obj-type
  , obj-list.obj-code
  , chk-pay.pay-code
  , chk-pay.curr-code
  , chk-doc.pay-desk
  , acc-curr-sum
  , acc-curr-base
  , acc-curr-rubl
  ) .
  
  if not can-find (first ben-chk-count where ben-chk-count.doc-code  = chk-pay.doc-code
                                         and ben-chk-count.obj-type  = obj-list.obj-type
                                         and ben-chk-count.obj-code  = obj-list.obj-code
                                         and ben-chk-count.pay-desk  = chk-doc.pay-desk
                                         and ben-chk-count.pay-code  = chk-pay.pay-code
                                         and ben-chk-count.curr-code = chk-pay.curr-code) then do:
    create ben-chk-count.
    assign
      ben-chk-count.doc-code  = chk-pay.doc-code
      ben-chk-count.obj-type  = obj-list.obj-type
      ben-chk-count.obj-code  = obj-list.obj-code
      ben-chk-count.pay-desk  = chk-doc.pay-desk
      ben-chk-count.pay-code  = chk-pay.pay-code
      ben-chk-count.curr-code = chk-pay.curr-code
    .
  end.
end.

/* $Workfile$ e n d */