/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Опеределения для приема чел

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/30/03
Author: Bakhtadze Natalya
Creation date: 06/30/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not available tb-person then do:
  create tb-person.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-person TO wt-person case-sensitive save result in compare-log no-error.
end.
 buffer-compare tb-person using city ind address name1 name2 TO wt-person case-sensitive save result in v-l no-error.

if not compare-log then do:
  buffer-copy wt-person TO tb-person.
end.
if not v-l then do:
  for each buf_dis-card no-lock where
           buf_dis-card.cli-type = {&prs}
       AND buf_dis-card.cli-code = tb-person.psn-code:
    run fill-dc-list in p-imp-handle ( buffer buf_Dis-card) .
  end.
end.

/* $Workfile$ e n d */