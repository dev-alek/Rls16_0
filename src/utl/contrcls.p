block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: contrcls.p $
$Archive: utl/contrcls.p $

Закрытие договоров, срок действия которых истёк

Автор: Чернова Светлана Александровна
Дата создания: 05/07/09
Author: Svetlana Chernova
Creation date: 05/07/09

*/

define input  parameter parparentproc  as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: contrcls.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/contrcls.p $":U .
define variable vss-description as character no-undo init "Закрытие договоров, срок действия которых истёк".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

if v-cntxt-db-num <> 0 then do:
  message "Утилита для ГБД !" view-as alert-box .
  return .
end.

define buffer buf_contract for ub.contract  .
define buffer buf_sysconf for ub.sysconf  .

run waitfram-show in this-procedure ( substitute("Закрытие договоров"  ) ).
for each buf_sysconf no-lock :

    for each buf_contract exclusive-lock where
             buf_contract.host-code = buf_sysconf.host-code and
             buf_contract.status_ = {&current-contr} and
             buf_contract.contract-date-end < today
             :
              run waitfram-show in this-procedure ( substitute("Закрытие договоров по фирме  &1  № договора &2 " , buf_sysconf.host-code , buf_contract.contract-code )) .
              assign
                buf_contract.status_ = {&close-contr}
              .
    end.
end.
run waitfram-hide in this-procedure .