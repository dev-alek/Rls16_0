block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: crcrdc.p $
$Archive: utl/crcrdc.p $

Создание диапазона для дисконтных карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter p-install as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: crcrdc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/crcrdc.p $":U .
define variable vss-description as character no-undo init "Создание диапазона для дисконтных карт".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

DEFINE VARIABLE var-last-code as integer no-undo .

define buffer buf_code-range  for ub.code-range.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


 find ub.sys-ctrl No-LOCK.
  if not avail ub.sys-ctrl then undo main-block, return error.
  /*в ГБД - заполняем*/
  if sys-ctrl.db-num = 0 then do:
    assign
    var-last-code = 100000 * (integer (current-value(s-dcgb-code, {&db-name_schema}) / 100000 )  + 1)
    .

    create buf_code-range.
    assign
    buf_code-range.range-type = {&gbl-dc-code}
    buf_code-range.PS         = "авто"
    buf_code-range.beg-date   = today
    buf_code-range.first-code = 1
    buf_code-range.last-code  = var-last-code
    buf_code-range.db-num = 0
    buf_code-range.stts = "a":U
    .
  end.
  else do:
     message
    vss-workfile vss-revision vss-description skip
    "утилиту можно запустить только в ГБД"
    view-as alert-box error .
    undo main-block, return error .
  end.
END.