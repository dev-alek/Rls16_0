/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях истории платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


define buffer buf_c-fin-doc-tax      for ub.c-fin-doc-tax.
define buffer buf_c-fin-doc-attr     for ub.c-fin-doc-attr.

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb-c-fin-doc-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-c-fin-doc-attr.
end.
for each locb-c-fin-doc-tax
on error undo, return error error-status :get-message (1)
:
  delete locb-c-fin-doc-tax.
end.



/* $Workfile$ e n d */