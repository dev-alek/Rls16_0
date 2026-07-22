/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

разбор записи db из пакета

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if wt-db.db-num = g#db-num and g#db-num <> 0 and available tb-db then do:
  assign
    wt-db.db-key     = tb-db.db-key
    wt-db.db-key-enc = tb-db.db-key-enc
    .
end.
if not available tb-db then do:
  create tb-db.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-db TO wt-db case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-db TO tb-db.
end.
/* $Workfile$ e n d */