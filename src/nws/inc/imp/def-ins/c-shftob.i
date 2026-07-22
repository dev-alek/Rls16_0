/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях истории смены и т.д.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_shift-cash for ub.shift-cash.
define buffer buf_c-shift-staff for ub.c-shift-staff.
define buffer buf_c-sht-hist for ub.c-sht-hist.
define buffer buf_c-shift-obj for ub.c-shift-obj.

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb2-shift-cash
on error undo, return error error-status :get-message (1)
:
  delete locb2-shift-cash.
end.
for each locb2-c-shift-staff
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-shift-staff.
end.
for each locb2-c-sht-hist
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-sht-hist.
end.
for each locb2-c-shift-obj
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-shift-obj.
end.


/* $Workfile$ e n d */