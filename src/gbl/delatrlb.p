block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: delatrlb.p $
$Archive: gbl/delatrlb.p $

Удаление бибилиотеки attr-lib.p

Автор: Перваков Михаил Сергеевич
Дата создания: 12/13/06
Author: Mikhail Pervakov
Creation date: 12/13/06

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: delatrlb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/delatrlb.p $":U .
define variable vss-description as character no-undo init "Удаление бибилиотеки attr-lib.p".
{ cmp/vssrevis.i }
{ gbl/attr-lib.i }

do
on error undo, return error return-value
:
  {&del_attr-lib}
end.