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

&scop BuffCopy if g#db-num = 0 and lookup( tb-dis-card.status_ , ({&chown-status} + {&comma-char} + {&nonused-status})) > 0  then do: ~
  buffer-copy wt-dis-card ~
    except wt-dis-card.status_ ~
    to tb-dis-card. ~
end. ~
else do: ~
  buffer-copy wt-dis-card to tb-dis-card. ~
end.


if not available tb-dis-card then do:
  create tb-dis-card.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-dis-card TO wt-dis-card case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  {&buffcopy}
  run fill-dc-list in p-imp-handle ( buffer tb-Dis-card) .
end.

/* $Workfile$ e n d */