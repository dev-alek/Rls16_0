block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: crcrcont.p $
$Archive: utl/crcrcont.p $

Создание диапазона для договоров - утилита начальной настройки

Автор: Кочетков Михаил Юрьевич
Дата создания: 06/09/06
Author: Michael Kochetkov
Creation date: 06/09/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: crcrcont.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/crcrcont.p $":U .
define variable vss-description as character no-undo init "Создание диапазона для договоров".
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
  if ub.sys-ctrl.db-num = 0 then do:
    assign var-last-code = 2000 * (integer (current-value(s-ctgb-code, {&db-name_schema}) / 2000 )  + 1)  .

    create buf_code-range.
    assign
      buf_code-range.range-type = {&gbl-ct-code}
      buf_code-range.PS         = "авто"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 1
      buf_code-range.last-code  = var-last-code
      buf_code-range.db-num = 0
      buf_code-range.stts = "a":U
    .
    for each ub.db no-lock where ub.db.db-num > 0 :
      find first buf_code-range no-lock where buf_code-range.db-num = ub.db.db-num and buf_code-range.range-type = {&gbl-ct-code} no-error .
      if available buf_code-range then next .
      create buf_code-range.
      assign
        buf_code-range.range-type = {&gbl-ct-code}
        buf_code-range.PS         = "авто"
        buf_code-range.beg-date   = today
        buf_code-range.first-code = var-last-code + 1
        var-last-code             = var-last-code + 2000
        buf_code-range.last-code  = var-last-code
        buf_code-range.db-num = ub.db.db-num
        buf_code-range.stts = "f":U
      .
    end.
  end.
END.