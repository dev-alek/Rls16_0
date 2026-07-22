block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: scnbfill.p $
$Archive: gbl/scnbfill.p $

Формирование списка кодов с кол-вами по фильтру

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/11/09
Author: Bakhtadze Natalya
Creation date: 12/11/09

*/


define input parameter par-run-names as character no-undo .
define input parameter Rs-list-method as character no-undo .
define input parameter Rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-filter-var as character no-undo .
define output parameter lns-cnt as integer no-undo .
define output parameter line-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: scnbfill.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/scnbfill.p $":U .
define variable vss-description as character no-undo init "Формирование списка кодов с кол-вами по фильтру".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ gbl/bb-fill.i scnblist }