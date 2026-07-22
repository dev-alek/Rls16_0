/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_fin-doc-tax      for ub.fin-doc-tax.
define buffer buf_fin-doc-attr     for ub.fin-doc-attr.
define buffer buf_sysconf for ub.sysconf .


define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
define variable v-obj-db-num as integer no-undo .

for each locb-fin-doc-tax
on error undo, return error error-status :get-message (1)
:
  delete locb-fin-doc-tax.
end.
for each locb-fin-doc-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-fin-doc-attr.
end.


/* $Workfile$ e n d */