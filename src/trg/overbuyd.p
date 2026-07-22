block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление по таблице Обороты по покупателю

Автор: Чернова Светлана Александровна
Дата создания: 11/21/05
Author: Svetlana Chernova
Creation date: 11/21/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.turnover-buyer.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление по таблице Обороты по покупателю".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
for each ub.turnover-buyer-gds exclusive-lock where
  ub.turnover-buyer-gds.cli-code = ub.turnover-buyer.cli-code and
  ub.turnover-buyer-gds.cli-type = ub.turnover-buyer.cli-type and
  ub.turnover-buyer-gds.obj-type = ub.turnover-buyer.obj-type and
  ub.turnover-buyer-gds.obj-code = ub.turnover-buyer.obj-code and
  ub.turnover-buyer-gds.ext-doc-type = ub.turnover-buyer.ext-doc-type and
  ub.turnover-buyer-gds.fact-order   = ub.turnover-buyer.fact-order and
  ub.turnover-buyer-gds.sum-type     = ub.turnover-buyer.sum-type
  :
    delete ub.turnover-buyer-gds .
end.

for each ub.turnover-buyer-attr exclusive-lock where
  ub.turnover-buyer-attr.cli-code = ub.turnover-buyer.cli-code and
  ub.turnover-buyer-attr.cli-type = ub.turnover-buyer.cli-type and
  ub.turnover-buyer-attr.obj-type = ub.turnover-buyer.obj-type and
  ub.turnover-buyer-attr.obj-code = ub.turnover-buyer.obj-code and
  ub.turnover-buyer-attr.ext-doc-type = ub.turnover-buyer.ext-doc-type and
  ub.turnover-buyer-attr.sum-type     = ub.turnover-buyer.sum-type  and
  ub.turnover-buyer-attr.fact-order   = ub.turnover-buyer.fact-order
  :
    delete ub.turnover-buyer-attr .
end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_turnover-buyer}
        , input ( buffer ub.turnover-buyer:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.