/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях истории  док-тов МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_c-wth-line      for ub.c-wth-line.
define buffer buf_c-wth-dtl       for ub.c-wth-dtl.
define buffer buf_c-wth-parts     for ub.c-wth-parts.
define buffer buf_c-inkas-pay-wth for ub.c-inkas-pay-wth.

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb-c-wth-line
on error undo, return error error-status :get-message (1)
:
  delete locb-c-wth-line.
end.
for each locb-c-wth-dtl
on error undo, return error error-status :get-message (1)
:
  delete locb-c-wth-dtl.
end.
for each locb-c-wth-parts
on error undo, return error error-status :get-message (1)
:
  delete locb-c-wth-parts.
end.
for each locbw-c-inkas-pay-wth
on error undo, return error error-status :get-message (1)
:
  delete locbw-c-inkas-pay-wth.
end.


/* $Workfile$ e n d */