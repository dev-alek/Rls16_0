block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dtaxgrpu.p $
$Archive: ref/dtaxgrpu.p $

Заполнение таблицы tax-rate-gds-grp по полям временной таблицы tt-tax

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

DEFINE INPUT PARAMETER parnode-code like ub.gds-grp.node-code no-undo.
DEFINE INPUT PARAMETER parupper-code like ub.gds-grp.node-code no-undo.
DEFINE INPUT PARAMETER to-del as logical no-undo.
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dtaxgrpu.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dtaxgrpu.p $":U .
define variable vss-description as character no-undo init "Заполнение таблицы tax-rate-gds-grp по полям временной таблицы tt-tax".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ str/tt-tax.i SHARED tt-tax full }

define buffer buf_tax for ub.tax.
define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
_tax:
  FOR EACH buf_tax No-LOCK
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

    if buf_tax.individual = yes then next _tax.
  find first tt-tax where
              tt-tax.tax-code  = buf_tax.tax-code No-ERROR.
  if not avail tt-tax then do:
      undo main-block, return error substitute("Вы не определили ставки налогов по умолчанию для товаров группы").
  end.
    find first buf_tax-rate-gds-grp where
              buf_tax-rate-gds-grp.node-code = parnode-code AND
              buf_tax-rate-gds-grp.tax-code = tt-tax.tax-code AND
             /*
             FREEZE
              buf_tax-rate-gds-grp.host-code = parhost-code AND
              buf_tax-rate-gds-grp.obj-type = parobj-type AND
              buf_tax-rate-gds-grp.obj-code = parobj-code
             */
              buf_tax-rate-gds-grp.host-code = 0 AND
              buf_tax-rate-gds-grp.obj-type = "":U AND
              buf_tax-rate-gds-grp.obj-code = 0 No-ERROR.
    if not avail buf_tax-rate-gds-grp then do:
      create buf_tax-rate-gds-grp.
    assign
      buf_tax-rate-gds-grp.node-code = parnode-code
      buf_tax-rate-gds-grp.tax-code = tt-tax.tax-code
    .
  end.
  assign
    buf_tax-rate-gds-grp.rate-code = tt-tax.rate-code.
  if to-del then
  delete tt-tax.
  END.

end.