block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление товаров ABC анализа

Автор: Чернова Светлана Александровна
Дата создания: 03/09/06
Author: Svetlana Chernova
Creation date: 03/09/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.abc-analysis-goods .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление товаров ABC анализа ".
{ cmp/vssrevis.i "substitute('&1', ub.abc-analysis-goods.abc-id ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }



main-block :
do transaction
on error undo main-block, return error
:
for each   ub.abc-analysis-goods-attr exclusive-lock where
           ub.abc-analysis-goods-attr.abc-id = ub.abc-analysis-goods.abc-id and
           ub.abc-analysis-goods-attr.db-num = ub.abc-analysis-goods.db-num and
           ub.abc-analysis-goods-attr.gds-code = ub.abc-analysis-goods.gds-code :

    delete ub.abc-analysis-goods-attr.
end.


for each   ub.abc-analysis-gds-obj exclusive-lock where
           ub.abc-analysis-gds-obj.abc-id = ub.abc-analysis-goods.abc-id and
           ub.abc-analysis-gds-obj.db-num = ub.abc-analysis-goods.db-num and
           ub.abc-analysis-gds-obj.gds-code = ub.abc-analysis-goods.gds-code :

    delete ub.abc-analysis-gds-obj.
end.


for each   ub.abc-analysis-gds-obj-attr exclusive-lock where
           ub.abc-analysis-gds-obj-attr.abc-id = ub.abc-analysis-goods.abc-id and
           ub.abc-analysis-gds-obj-attr.db-num = ub.abc-analysis-goods.db-num and
           ub.abc-analysis-gds-obj-attr.gds-code = ub.abc-analysis-goods.gds-code :

    delete ub.abc-analysis-gds-obj-attr.
end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_abc-analysis-goods}
        , input ( buffer ub.abc-analysis-goods:handle )
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