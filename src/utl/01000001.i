/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Условный перенос истории по таблице {&first-tabl}e или таблице {&second-table}  -  заранее неизвестно

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/24/03
Author: Bakhtadze Natalya
Creation date: 07/24/03

т.к. алгоритм записи в history менялс

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

assign
var-rid-2 = ?
var-new-name = "":U
var-new-name-2 = "":U
.

find first old-{&first-table} no-lock where
          recid(old-{&first-table}) = old-history.tbl-rid no-error .
if avail old-{&first-table} then do:
  find first new-{&first-table} no-lock where
            {&first-where}
        no-error .
  if not avail new-{&first-table} then next _old-history.
  assign
  var-rid = recid(new-{&first-table})
  .
end. /*нашли по таблице {1}*/
else do:
  find first old-{&second-table} no-lock where
            recid(old-{&second-table}) = old-history.tbl-rid no-error .
  if available old-{&second-table} then do:
    find first new-{&first-table} no-lock where
              {&second-where}
          no-error .
    if not avail new-{&first-table} then next _old-history.
    assign
    var-rid = recid(new-{&first-table})
    .
  end.
  else do:
    next _old-history.
  end.
end.


/* $Workfile$ e n d */