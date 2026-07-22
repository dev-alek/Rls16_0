block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prntput.p $
$Archive: gbl/prntput.p $

Находит необходимый шаблон печати, на который устанавливается броуз шаблонов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/

define input parameter c-p as character no-undo .
define output parameter p-flt-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prntput.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/prntput.p $":U .
define variable vss-description as character no-undo init "Находит необходимый шаблон печати, на который устанавливается броуз шаблонов".
{ cmp/vssrevis.i "substitute('&1',c-p)"}
{ cmp/trg-def.i }

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
    assign
     p-flt-rec = recid (ubflt.filter)
    .
  end.
  else do:
    assign
    p-flt-rec = ?
    .
  end.
end.
else do:
  assign
  p-flt-rec = ?
  .
end.