/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях расписаний

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf1_dis-time-rule         for ub.dis-time-rule.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

{ gbl/distruls.i def }


for each locb1-dis-time-rule
on error undo, return error error-status :get-message (1)
:
  delete locb1-dis-time-rule.
end.


/* $Workfile$ e n d */