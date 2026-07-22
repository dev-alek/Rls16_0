block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись xyz анализа

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

TRIGGER PROCEDURE FOR delete OF ub.xyz-analysis .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись xyz анализа ".
{ cmp/vssrevis.i "substitute('&1', ub.xyz-analysis.xyz-id ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


main-block :
do transaction
on error undo main-block, return error
:
    for each  ub.xyz-analysis-attr exclusive-lock where
        ub.xyz-analysis-attr.xyz-id =   ub.xyz-analysis.xyz-id and
        ub.xyz-analysis-attr.db-num =   ub.xyz-analysis.db-num
        :
        delete ub.xyz-analysis-attr.
    end.
    for each  ub.xyz-analysis-doc exclusive-lock where
        ub.xyz-analysis-doc.xyz-id =   ub.xyz-analysis.xyz-id and
        ub.xyz-analysis-doc.db-num =   ub.xyz-analysis.db-num
        :
        delete ub.xyz-analysis-doc.
    end.
    for each  ub.xyz-analysis-obj exclusive-lock where
        ub.xyz-analysis-obj.xyz-id =   ub.xyz-analysis.xyz-id and
        ub.xyz-analysis-obj.db-num =   ub.xyz-analysis.db-num
        :
        delete ub.xyz-analysis-obj.
    end.
    for each  ub.xyz-analysis-period exclusive-lock where
        ub.xyz-analysis-period.xyz-id =   ub.xyz-analysis.xyz-id and
        ub.xyz-analysis-period.db-num =   ub.xyz-analysis.db-num
        :
        delete ub.xyz-analysis-period.
    end.

    for each  ub.xyz-analysis-goods exclusive-lock where
        ub.xyz-analysis-goods.xyz-id =   ub.xyz-analysis.xyz-id and
        ub.xyz-analysis-goods.db-num =   ub.xyz-analysis.db-num
        :
        delete ub.xyz-analysis-goods.
    end.

    for each  ub.xyz-analysis-goods-attr exclusive-lock where
        ub.xyz-analysis-goods-attr.xyz-id =   ub.xyz-analysis.xyz-id and
        ub.xyz-analysis-goods-attr.db-num =   ub.xyz-analysis.db-num
        :
        delete ub.xyz-analysis-goods-attr.
    end.

    for each  ub.xyz-analysis-gds-obj exclusive-lock where
        ub.xyz-analysis-gds-obj.xyz-id =   ub.xyz-analysis.xyz-id and
        ub.xyz-analysis-gds-obj.db-num =   ub.xyz-analysis.db-num
        :
        delete ub.xyz-analysis-gds-obj.
    end.

    for each  ub.xyz-analysis-gds-obj-attr exclusive-lock where
        ub.xyz-analysis-gds-obj-attr.xyz-id =   ub.xyz-analysis.xyz-id and
        ub.xyz-analysis-gds-obj-attr.db-num =   ub.xyz-analysis.db-num
        :
        delete ub.xyz-analysis-gds-obj-attr.
    end.

    for each  ub.abcxyz-analysis exclusive-lock where
        ub.abcxyz-analysis.xyz-id =   ub.xyz-analysis.xyz-id and
        ub.abcxyz-analysis.xyz-db-num =   ub.xyz-analysis.db-num
        :
        delete ub.abcxyz-analysis.
    end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_xyz-analysis}
        , input ( buffer ub.xyz-analysis:handle )
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