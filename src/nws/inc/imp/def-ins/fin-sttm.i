/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях банковских выписок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_fin-statement-line     for ub.fin-statement-line.
define buffer buf_fin-statement-attr     for ub.fin-statement-attr.


define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb-fin-statement-line
on error undo, return error error-status :get-message (1)
:
  delete locb-fin-statement-line.
end.
for each locb-fin-statement-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-fin-statement-attr.
end.

/* $Workfile$ e n d */