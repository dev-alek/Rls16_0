block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: update2.p $
$Archive: gbl/update2.p $

Запуск выправляющих утилит, требующих parparentproc

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/03/09
Author: Bakhtadze Natalya
Creation date: 06/03/09

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: update2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/update2.p $":U .
define variable vss-description as character no-undo init "Запуск выправляющих утилит, требующих parparentproc".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/get-ro.i }

define variable v-proc-name as character no-undo .
define buffer buf_sys-ctrl for ub.sys-ctrl.
define buffer buf_config   for ub.config .
define variable v-get-ro_read-only as logical   no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if transaction then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Вызов данной процедуры невозможен при наличии транзакции" )
      view-as alert-box error
    .
    return error .
  end.
  run get-ro_get-read-only in this-procedure
    ( output v-get-ro_read-only
    ) .

  if g#db-num  > 0 then do:
    run utl/fix-sldc.p ( input parparentproc
                        ,input v-get-ro_read-only
                      ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при запуске выгруженных продаж и накладных, недосчитанных по ДК" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return error .
    end.
  end.
end. /*doe*/