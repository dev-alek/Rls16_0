/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отчет о выручке  - сбор данных по чекам - общая часть для первого прохода по чекам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/17/05
Author: Bakhtadze Natalya
Creation date: 11/17/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

ACCUMULATE
( chk-doc.netto ) ( SUB-TOTAL BY chk-doc.pay-desk )
chk-doc.doc-code ( COUNT BY chk-doc.pay-desk).

if last-of( chk-doc.pay-desk ) then do:
  create day_sum.
  assign
  day_sum.obj-type = obj-list.obj-type
  day_sum.obj-code = obj-list.obj-code
  day_sum.pay-desk = chk-doc.pay-desk
  day_sum.tot-rubl = (if v-curr-r-b = {&r-b-base}
                      then day_sum.tot-rubl
                      else ((ACCUM SUB-TOTAL BY chk-doc.pay-desk ( chk-doc.netto )) -  {1}))
  day_sum.tot-base = (if v-curr-r-b = {&r-b-rubl}
                      then day_sum.tot-base
                      else ((ACCUM SUB-TOTAL BY chk-doc.pay-desk ( chk-doc.netto )) -  {1}))
  day_sum.tot-r-b  = (if v-curr-r-b = {&r-b-base}
                      then day_sum.tot-base
                      else day_sum.tot-rubl)
  day_sum.chk-cnt-all =  (ACCUM COUNT BY chk-doc.pay-desk  chk-doc.doc-code) -  {2}
  .
end.

/* $Workfile$ e n d */