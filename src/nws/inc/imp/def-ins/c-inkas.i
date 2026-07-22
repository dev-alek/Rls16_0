/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях истории продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_c-inkas-pay      for ub.c-inkas-pay.
define buffer buf_c-sale-doc       for ub.c-sale-doc.
define buffer buf_c-inkas-pay-desk for ub.c-inkas-pay-desk.
define buffer buf_c-inkas-pay-wth  for ub.c-inkas-pay-wth.

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb2-c-inkas
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-inkas.
end.
for each locb2-c-inkas-pay
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-inkas-pay.
end.
for each locb2-c-inkas-pay-desk
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-inkas-pay-desk.
end.
for each locb2-c-inkas-pay-wth
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-inkas-pay-wth.
end.

for each locb2-c-sale-doc
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-sale-doc.
end.


/* $Workfile$ e n d */