/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях док-тов МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_wth-line      for ub.wth-line.
define buffer buf_wth-dtl       for ub.wth-dtl.
define buffer buf_chk-doc     for ub.chk-doc.
define buffer buf_chk-pay      for ub.chk-pay.
define buffer buf_wth-parts     for ub.wth-parts.
define buffer buf_wth-doc-attr  for ub.wth-doc-attr.
define buffer buf_c-chk-doc   for ub.c-chk-doc.
define buffer buf_c-chk-pay    for ub.c-chk-pay.
define buffer buf_c-wth-doc     for ub.c-wth-doc.
define buffer buf_c-wth-line    for ub.c-wth-line.
define buffer buf_c-wth-dtl     for ub.c-wth-dtl.
define buffer buf_c-wth-parts   for ub.c-wth-parts.
define buffer buf_inkas-pay-wth   for ub.inkas-pay-wth.
define buffer buf_c-inkas-pay-wth   for ub.c-inkas-pay-wth.

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb-wth-line
on error undo, return error error-status :get-message (1)
:
  delete locb-wth-line.
end.
for each locb-wth-dtl
on error undo, return error error-status :get-message (1)
:
  delete locb-wth-dtl.
end.
for each locb-wth-parts
on error undo, return error error-status :get-message (1)
:
  delete locb-wth-parts.
end.
for each locb-wth-doc-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-wth-doc-attr.
end.

for each locb-chk-doc
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-doc.
end.
for each locb-chk-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-pay.
end.
for each locb-c-chk-doc
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-doc.
end.
for each locb-c-chk-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-pay.
end.
for each locbw-c-wth-doc
on error undo, return error error-status :get-message (1)
:
  delete locbw-c-wth-doc.
end.
for each locbw-c-wth-line
on error undo, return error error-status :get-message (1)
:
  delete locbw-c-wth-line.
end.
for each locbw-c-wth-dtl
on error undo, return error error-status :get-message (1)
:
  delete locbw-c-wth-dtl.
end.
for each locbw-c-wth-parts
on error undo, return error error-status :get-message (1)
:
  delete locbw-c-wth-parts.
end.
for each locbw-inkas-pay-wth
on error undo, return error error-status :get-message (1)
:
  delete locbw-inkas-pay-wth.
end.
for each locbw-c-inkas-pay-wth
on error undo, return error error-status :get-message (1)
:
  delete locbw-c-inkas-pay-wth.
end.




/* $Workfile$ e n d */