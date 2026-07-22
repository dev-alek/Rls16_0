block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление типов прайс-листов

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
TRIGGER PROCEDURE FOR DELETE OF ub.price-list-type.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "<>".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  for each  ub.price-list-type-attr exclusive-lock where
            ub.price-list-type-attr.plt-db-num = ub.price-list-type.plt-db-num    and
            ub.price-list-type-attr.plt-id     = ub.price-list-type.plt-id
            :
            delete ub.price-list-type-attr.
  end.
  for each  ub.price-list-type-cash-pay exclusive-lock where
            ub.price-list-type-cash-pay.plt-db-num = ub.price-list-type.plt-db-num    and
            ub.price-list-type-cash-pay.plt-id     = ub.price-list-type.plt-id
            :
            delete ub.price-list-type-cash-pay.
  end.
  for each  ub.price-list-type-cassa exclusive-lock where
            ub.price-list-type-cassa.plt-db-num = ub.price-list-type.plt-db-num    and
            ub.price-list-type-cassa.plt-id     = ub.price-list-type.plt-id
            :
            delete ub.price-list-type-cassa.
  end.

  for each  ub.price-list-type-gds-grp exclusive-lock where
            ub.price-list-type-gds-grp.plt-db-num = ub.price-list-type.plt-db-num    and
            ub.price-list-type-gds-grp.plt-id     = ub.price-list-type.plt-id
            :
            delete ub.price-list-type-gds-grp.
  end.

  for each  ub.price-list-type-pay-type exclusive-lock where
            ub.price-list-type-pay-type.plt-db-num = ub.price-list-type.plt-db-num    and
            ub.price-list-type-pay-type.plt-id     = ub.price-list-type.plt-id
            :
            delete ub.price-list-type-pay-type.
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_price-list-type}
        , input ( buffer ub.price-list-type:handle )
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
