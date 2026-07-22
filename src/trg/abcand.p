block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление ABC анализа

Автор: Чернова Светлана Александровна
Дата создания: 03/09/06
Author: Svetlana Chernova
Creation date: 03/09/06

*/

TRIGGER PROCEDURE FOR delete OF ub.abc-analysis .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись ABC анализа ".
{ cmp/vssrevis.i "substitute('&1', ub.abc-analysis.abc-id ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


main-block :
do transaction
on error undo main-block, return error
:
    for each  ub.abc-analysis-attr exclusive-lock where
        ub.abc-analysis-attr.abc-id =   ub.abc-analysis.abc-id and
        ub.abc-analysis-attr.db-num =   ub.abc-analysis.db-num
        :
        delete ub.abc-analysis-attr.
    end.
    for each  ub.abc-analysis-doc exclusive-lock where
        ub.abc-analysis-doc.abc-id =   ub.abc-analysis.abc-id and
        ub.abc-analysis-doc.db-num =   ub.abc-analysis.db-num
        :
        delete ub.abc-analysis-doc.
    end.
    for each  ub.abc-analysis-obj exclusive-lock where
        ub.abc-analysis-obj.abc-id =   ub.abc-analysis.abc-id and
        ub.abc-analysis-obj.db-num =   ub.abc-analysis.db-num
        :
        delete ub.abc-analysis-obj.
    end.
    for each  ub.abc-analysis-period exclusive-lock where
        ub.abc-analysis-period.abc-id =   ub.abc-analysis.abc-id and
        ub.abc-analysis-period.db-num =   ub.abc-analysis.db-num
        :
        delete ub.abc-analysis-period.
    end.

    for each  ub.abc-analysis-goods exclusive-lock where
        ub.abc-analysis-goods.abc-id =   ub.abc-analysis.abc-id and
        ub.abc-analysis-goods.db-num =   ub.abc-analysis.db-num
        :
        delete ub.abc-analysis-goods.
    end.

    for each  ub.abc-analysis-goods-attr exclusive-lock where
        ub.abc-analysis-goods-attr.abc-id =   ub.abc-analysis.abc-id and
        ub.abc-analysis-goods-attr.db-num =   ub.abc-analysis.db-num
        :
        delete ub.abc-analysis-goods-attr.
    end.

    for each  ub.abc-analysis-gds-obj exclusive-lock where
        ub.abc-analysis-gds-obj.abc-id =   ub.abc-analysis.abc-id and
        ub.abc-analysis-gds-obj.db-num =   ub.abc-analysis.db-num
        :
        delete ub.abc-analysis-gds-obj.
    end.

    for each  ub.abc-analysis-gds-obj-attr exclusive-lock where
        ub.abc-analysis-gds-obj-attr.abc-id =   ub.abc-analysis.abc-id and
        ub.abc-analysis-gds-obj-attr.db-num =   ub.abc-analysis.db-num
        :
        delete ub.abc-analysis-gds-obj-attr.
    end.

    for each  ub.abcxyz-analysis exclusive-lock where
        ub.abcxyz-analysis.abc-id =   ub.abc-analysis.abc-id and
        ub.abcxyz-analysis.abc-db-num =   ub.abc-analysis.db-num
        :
        delete ub.abcxyz-analysis.
    end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_abc-analysis}
        , input ( buffer ub.abc-analysis:handle )
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