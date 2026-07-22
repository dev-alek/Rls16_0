block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: del-invc.p $
$Archive: str/del-invc.p $

Удаление чеков по инвентаризации

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/03/06
Author: Bakhtadze Natalya
Creation date: 09/03/06

*/

define input parameter p-doc-code as character no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-invc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/del-invc.p $":U .
define variable vss-description as character no-undo init "Удаление чеков по инвентаризации".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
define variable ii as integer no-undo .

_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

{ str/del-sale.i p-doc-code p-obj-type p-obj-code ii " " " " "inv" }

end.
