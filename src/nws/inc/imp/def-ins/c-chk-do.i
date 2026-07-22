/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях истории чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_c-chk-gds         for ub.c-chk-gds.
define buffer buf_c-chk-pay         for ub.c-chk-pay.
define buffer buf_c-chk-discnt      for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr    for ub.c-chk-doc-attr.

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb2-c-chk-gds
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-chk-gds.
end.
for each locb2-c-chk-pay
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-chk-pay.
end.

for each locb2-c-chk-discnt
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-chk-discnt.
end.
for each locb2-c-chk-doc-attr
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-chk-doc-attr.
end.


/* $Workfile$ e n d */