block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление ABCXYZ

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/


TRIGGER PROCEDURE FOR DELETE OF ub.abcxyz-analysis.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление ABCXYZ".
{ cmp/vssrevis.i "substitute('&1', ub.abcxyz-analysis.abcx-id ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


main-block :
do transaction
on error undo main-block, return error
:
    for each  ub.abcxyz-analysis-attr exclusive-lock where
        ub.abcxyz-analysis-attr.abcx-id =   ub.abcxyz-analysis.abcx-id and
        ub.abcxyz-analysis-attr.db-num  =   ub.abcxyz-analysis.db-num
        :
        delete ub.abcxyz-analysis-attr.
    end.

    for each  ub.abcxyz-analysis-goods exclusive-lock where
        ub.abcxyz-analysis-goods.abcx-id =   ub.abcxyz-analysis.abcx-id and
        ub.abcxyz-analysis-goods.db-num  =   ub.abcxyz-analysis.db-num
        :
        delete ub.abcxyz-analysis-goods.
    end.

    for each  ub.abcxyz-analysis-goods-attr exclusive-lock where
        ub.abcxyz-analysis-goods-attr.abcx-id =   ub.abcxyz-analysis.abcx-id and
        ub.abcxyz-analysis-goods-attr.db-num  =   ub.abcxyz-analysis.db-num
        :
        delete ub.abcxyz-analysis-goods-attr.
    end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_abcxyz-analysis}
        , input ( buffer ub.abcxyz-analysis:handle )
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