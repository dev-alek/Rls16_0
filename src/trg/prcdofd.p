block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление всего ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 12/19/05
Author: Svetlana Chernova
Creation date: 12/19/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.price-doc-forming.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление ДНЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

Main-block:
do transaction
on error undo main-block, return error
on end-key undo main-block, return error
:

for each ub.price-doc-forming-attr exclusive-lock where
         ub.price-doc-forming-attr.pdf-db        = ub.price-doc-forming.pdf-db      and
         ub.price-doc-forming-attr.pdf-id        = ub.price-doc-forming.pdf-id      and
         ub.price-doc-forming-attr.plt-db-num    = ub.price-doc-forming.plt-db-num  and
         ub.price-doc-forming-attr.plt-id        = ub.price-doc-forming.plt-id
         :
         delete ub.price-doc-forming-attr.
end.

for each ub.price-doc-forming-gds exclusive-lock where
         ub.price-doc-forming-gds.pdf-db        = ub.price-doc-forming.pdf-db      and
         ub.price-doc-forming-gds.pdf-id        = ub.price-doc-forming.pdf-id      and
         ub.price-doc-forming-gds.plt-db-num    = ub.price-doc-forming.plt-db-num  and
         ub.price-doc-forming-gds.plt-id        = ub.price-doc-forming.plt-id
         :
         delete ub.price-doc-forming-gds.
end.

for each ub.price-all exclusive-lock where
         ub.price-all.pdf-db        = ub.price-doc-forming.pdf-db      and
         ub.price-all.pdf-id        = ub.price-doc-forming.pdf-id      and
         ub.price-all.plt-db-num    = ub.price-doc-forming.plt-db-num  and
         ub.price-all.plt-id        = ub.price-doc-forming.plt-id
         :
         delete ub.price-all.
end.


    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_price-doc-forming}
        , input ( buffer ub.price-doc-forming:handle )
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