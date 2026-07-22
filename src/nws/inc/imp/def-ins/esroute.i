/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях роутов ВС

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/22/08
Author: Bakhtadze Natalya
Creation date: 02/22/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_esys-route-dump        for ub.esys-route-dump.

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb-esys-route-dump
on error undo, return error error-status :get-message (1)
:
  delete locb-esys-route-dump.
end.

/* $Workfile$ e n d */