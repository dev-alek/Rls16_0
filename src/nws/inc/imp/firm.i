/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием фирмы по СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/30/03
Author: Bakhtadze Natalya
Creation date: 06/30/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not available tb-firm then do:
  create tb-firm.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-firm TO wt-firm case-sensitive save result in compare-log no-error.
end.
 buffer-compare tb-firm using city ind addres1 TO wt-firm case-sensitive save result in v-l no-error.

if not compare-log then do:
  buffer-copy wt-firm TO tb-firm.
end.
if not v-l then do:
  for each buf_dis-card no-lock where
           buf_dis-card.cli-type = {&cmp}
       AND buf_dis-card.cli-code = tb-firm.firm-code:
    run fill-dc-list in p-imp-handle ( buffer buf_Dis-card).
  end.
end.

/* $Workfile$ e n d */