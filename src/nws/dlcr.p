block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dlcr.p $
$Archive: nws/dlcr.p $

процедура удаления code-range (разовая)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/02
Author: Dmitry Ukhanov
Creation date: 03/23/02

*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: dlcr.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/dlcr.p $":U .
def var vss-description as character no-undo init "процедура удаления code-range (разовая)".
{ cmp/vssrevis.i }

define input parameter r-type like ub.code-range.range-type no-undo.
define input parameter f-code like ub.code-range.first-code no-undo.

on delete of ub.code-range override do: end.

do
on error undo, return error :
  find first ub.code-range
    where ub.code-range.range-type = r-type
      and ub.code-range.first-code = f-code.
  delete ub.code-range.
end.