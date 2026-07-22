block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: flt-put.p $
$Archive: gbl/flt-put.p $

Сохраняет условие выборки фильтра во временные файлы, которые используются при открытии query

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/20/05
Author: Bakhtadze Natalya
Creation date: 10/20/05

*/

define input parameter c-p as character no-undo .
define input parameter g#report-num as integer no-undo .
define output parameter flt-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: flt-put.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/flt-put.p $":U .
define variable vss-description as character no-undo init "Сохраняет условие выборки фильтра во временные файлы".
{ cmp/vssrevis.i "substitute('&1|&2',c-p, g#report-num)"}
{ cmp/trg-def.i }

define variable ii as integer no-undo.
define variable jj as integer no-undo.

assign
  flt-rec = ?
.
if num-entries(c-p, {&delim-par}) > 1 then do:
  assign
  c-p        = entry(1, c-p, {&delim-par})
  .
end.

find ubflt.usr-flt no-lock
  where ubflt.usr-flt.user-name = g#userid
    and ubflt.usr-flt.call-point = c-p
  no-error .
if available ubflt.usr-flt then do:
  find ubflt.filter no-lock
    where ubflt.filter.call-point = ubflt.usr-flt.call-point
      and ubflt.filter.naim       = ubflt.usr-flt.naim
    no-error .
  if available ubflt.filter then do:
    { gbl/flt-put.i ubflt. }
    assign
      flt-rec = recid (ubflt.filter)
    .
  end.
  else do:
    assign
      flt-rec = ?
    .
  end.
end.
else do:
  assign
    flt-rec = ?
  .
end.
if flt-rec = ? then do:
  { gbl/empt-put.i }
end.