/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях истории банковский выписок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_c-fin-statement-line      for ub.c-fin-statement-line.
define buffer buf_c-fin-statement-attr      for ub.c-fin-statement-attr.

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb-c-fin-statement-line
on error undo, return error error-status :get-message (1)
:
  delete locb-c-fin-statement-line.
end.
for each locb-c-fin-statement-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-c-fin-statement-attr.
end.


/* $Workfile$ e n d */