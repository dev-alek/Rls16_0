block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getvern.p $
$Archive: gbl/getvern.p $

Получение номера текущей версии

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/10/08
Author: Dmitry Ukhanov
Creation date: 10/10/08

*/

define output parameter p-version-num as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getvern.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/getvern.p $":U .
define variable vss-description as character no-undo init "Получение номера текущей версии".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    define buffer buf_upgrade  for ub.upgrade .

    find first buf_sys-ctrl no-lock .

    assign
      p-version-num  = '':U
    .
    for last buf_upgrade no-lock
      where buf_upgrade.db-num      = buf_sys-ctrl.db-num
        and buf_upgrade.version-num > '':U
        and buf_upgrade.complete    = true
    on error undo, return error return-value
    :
      assign
        p-version-num  = buf_upgrade.version-num
      .
    end.

    return .
end.