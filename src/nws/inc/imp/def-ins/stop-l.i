/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/07/07
Author: Bakhtadze Natalya
Creation date: 07/07/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_stop-list-line for ub.stop-list-line.
define buffer buf_c-stop-list-line for ub.c-stop-list-line.
define buffer buf_c-stop-list for ub.c-stop-list.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
define variable v-to-send as logical no-undo .

for each locb-stop-list-line
on error undo, return error error-status :get-message (1)
:
  delete locb-stop-list-line.
end.
for each locb-c-stop-list-line
on error undo, return error error-status :get-message (1)
:
  delete locb-c-stop-list-line.
end.
for each locb-c-stop-list
on error undo, return error error-status :get-message (1)
:
  delete locb-c-stop-list.
end.

/* $Workfile$ e n d */