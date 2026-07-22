/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обновление статуса базы данных

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/19/07
Author: Dmitry Ukhanov
Creation date: 10/19/07

Автор1: Перваков Михаил Сергеевич
Дата создания1: 04/12/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if wt-db-status.db-num = g#db-num and g#db-num <> 0 then do:
  assign
    wt-db-status.stock-date = TODAY
    wt-db-status.stock-time = TIME
    .
  if available tb-db-status then do:
    assign
      wt-db-status.fact-num = tb-db-status.fact-num
      .
  end.
end.
if not available tb-db-status then do:
  create tb-db-status.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-db-status TO wt-db-status case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-db-status TO tb-db-status.
end.
/* $Workfile$ e n d */