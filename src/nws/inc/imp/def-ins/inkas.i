/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_inkas-pay      for ub.inkas-pay.
define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
define buffer buf_inkas-pay-wth  for ub.inkas-pay-wth.
define buffer buf_sale-doc       for ub.sale-doc.
define buffer buf_c-sale-doc       for ub.c-sale-doc.
define buffer buf_chk-doc        for ub.chk-doc.
define buffer buf_chk-gds        for ub.chk-gds.
define buffer buf_chk-gds-attr   for ub.chk-gds-attr.
define buffer buf_chk-pay        for ub.chk-pay.
define buffer buf_chk-pay-attr   for ub.chk-pay-attr.
define buffer buf_chk-discnt     for ub.chk-discnt.
define buffer buf_chk-discnt-attr     for ub.chk-discnt-attr.
define buffer buf_chk-doc-attr   for ub.chk-doc-attr.
define buffer buf_chk-gds-pay    for ub.chk-gds-pay.
define buffer buf_c-chk-doc        for ub.c-chk-doc.
define buffer buf_c-chk-gds        for ub.c-chk-gds.
define buffer buf_c-chk-pay        for ub.c-chk-pay.

define buffer buf_c-chk-discnt     for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr   for ub.c-chk-doc-attr.
define buffer buf_c-inkas          for ub.c-inkas.
define buffer buf_c-inkas-pay      for ub.c-inkas-pay.
define buffer buf_c-inkas-pay-desk for ub.c-inkas-pay-desk.
define buffer buf_c-inkas-pay-wth  for ub.c-inkas-pay-wth.

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
define variable v-need-saledc as logical no-undo .

for each locb-inkas-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-inkas-pay.
end.
for each locb-inkas-pay-desk
on error undo, return error error-status :get-message (1)
:
  delete locb-inkas-pay-desk.
end.
for each locb-inkas-pay-wth
on error undo, return error error-status :get-message (1)
:
  delete locb-inkas-pay-wth.
end.
for each locb-sale-doc
on error undo, return error error-status :get-message (1)
:
  delete locb-sale-doc.
end.
for each locb-chk-doc
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-doc.
end.
for each locb-chk-gds
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-gds.
end.
for each locb-chk-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-pay.
end.
for each locb-chk-pay-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-pay-attr.
end.

for each locb-chk-discnt
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-discnt.
end.
for each locb-chk-discnt-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-discnt-attr.
end.
for each locb-chk-doc-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-doc-attr.
end.
for each locb-chk-gds-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-gds-pay.
end.
for each locb-c-chk-doc
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-doc.
end.
for each locb-c-chk-gds
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-gds.
end.
for each locb-c-chk-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-pay.
end.
for each locb-c-chk-discnt
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-discnt.
end.
for each locb-c-chk-doc-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-doc-attr.
end.
for each locb-c-inkas
on error undo, return error error-status :get-message (1)
:
  delete locb-c-inkas.
end.
for each locb-c-inkas-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-c-inkas-pay.
end.
for each locb-c-inkas-pay-desk
on error undo, return error error-status :get-message (1)
:
  delete locb-c-inkas-pay-desk.
end.
for each locb-c-inkas-pay-wth
on error undo, return error error-status :get-message (1)
:
  delete locb-c-inkas-pay-wth.
end.
for each locb-c-sale-doc
on error undo, return error error-status :get-message (1)
:
  delete locb-c-sale-doc.
end.

/* $Workfile$ e n d */