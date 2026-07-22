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
( chk-doc.netto ) ( SUB-TOTAL BY {1} )
chk-doc.doc-code ( COUNT BY {1}).
if last-of( {1} ) then  do:
    create day_sum.
    assign
    day_sum.obj-type = obj-list.obj-type
    day_sum.obj-code = obj-list.obj-code
    day_sum.date = {1}
    day_sum.tot-base =  (ACCUM SUB-TOTAL BY {1} ( chk-doc.netto )) - {2}
    day_sum.chk-cnt-all =  (ACCUM COUNT BY {1}  chk-doc.doc-code) - {3}.
end.

/* $Workfile$ e n d */