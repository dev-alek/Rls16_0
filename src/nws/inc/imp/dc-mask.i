/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop BuffCopy if g#db-num = 0 then do: ~
  buffer-copy wt-dis-card-mask ~
    to tb-dis-card-mask. ~
end. ~
else do: ~
  buffer-copy wt-dis-card-mask to tb-dis-card-mask. ~
end.


if not available tb-dis-card-mask then do:
  create tb-dis-card-mask.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-dis-card-mask TO wt-dis-card-mask case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  {&buffcopy}
  run fill-dc-list-mask in p-imp-handle ( buffer tb-dis-card-mask) .
end.

/* $Workfile$ e n d */