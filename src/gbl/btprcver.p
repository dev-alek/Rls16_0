block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: btprcver.p $
$Archive: gbl/btprcver.p $

Проверка наличия отложенных заданий по расчету переоценок

Автор: Чернова Светлана Александровна
Дата создания: 04/20/07
Author: Svetlana Chernova
Creation date: 04/20/07

*/
define output parameter p-exist as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: btprcver.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/btprcver.p $":U .
define variable vss-description as character no-undo init "Проверка наличия отложенных заданий по расчету переоценок".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define buffer buf_BatchProcess for ub.BatchProcess  .
do
on error undo, return error substitute( "&1 &2", return-value, error-status :get-message(1) )
:
   p-exist = false .
    find first buf_BatchProcess exclusive-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-prc}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
        no-error .
    if available buf_BatchProcess then p-exist = true .

end.