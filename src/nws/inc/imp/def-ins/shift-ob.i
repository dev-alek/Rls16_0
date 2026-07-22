/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием смены по СПН

Автор: Суслов Алексей Юрьевич
Дата создания: 04/11/06
Author: Alexey Suslov
Creation date: 04/11/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_shift-staff for ub.shift-staff.
define buffer buf_shift-cash for ub.shift-cash.
define buffer buf_c-shift-staff for ub.c-shift-staff.
define buffer buf_c-sht-hist for ub.c-sht-hist.
define buffer buf_c-shift-obj for ub.c-shift-obj.

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb-shift-staff
on error undo, return error error-status :get-message (1)
:
  delete locb-shift-staff.
end.
for each locb-shift-cash
on error undo, return error error-status :get-message (1)
:
  delete locb-shift-cash.
end.
for each locb-c-shift-staff
on error undo, return error error-status :get-message (1)
:
  delete locb-c-shift-staff.
end.
for each locb-c-sht-hist
on error undo, return error error-status :get-message (1)
:
  delete locb-c-sht-hist.
end.
for each locb-c-shift-obj
on error undo, return error error-status :get-message (1)
:
  delete locb-c-shift-obj.
end.

/* $Workfile$ e n d */