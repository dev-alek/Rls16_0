/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием в новостях налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not available tb-tax then do:
  create tb-tax.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-tax TO wt-tax case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-tax TO tb-tax.
  if tb-tax.to-cashdesk = yes then do:
    run fill-cash-txn in p-imp-handle ( buffer tb-tax).
  end.
end.

/* $Workfile$ e n d */