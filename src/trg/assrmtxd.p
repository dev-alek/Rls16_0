block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление ассортиментной матрицы из БД

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06


*/

TRIGGER PROCEDURE FOR delete OF ub.assortment-matrix .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление ассортиментной матрицы".
{ cmp/vssrevis.i  }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


main-block :
do transaction
on error undo main-block, return error
:
for each  ub.assortment-matrix-goods exclusive-lock where
          ub.assortment-matrix-goods.asmt-id = ub.assortment-matrix.asmt-id and
          ub.assortment-matrix-goods.db-num  = ub.assortment-matrix.db-num :
    delete ub.assortment-matrix-goods.
end.
for each  ub.c-assortment-matrix-goods exclusive-lock where
          ub.c-assortment-matrix-goods.asmt-id = ub.assortment-matrix.asmt-id and
          ub.c-assortment-matrix-goods.db-num  = ub.assortment-matrix.db-num :
    delete ub.c-assortment-matrix-goods.
end.

for each  ub.c-assortment-matrix exclusive-lock where
          ub.c-assortment-matrix.asmt-id = ub.assortment-matrix.asmt-id and
          ub.c-assortment-matrix.db-num  = ub.assortment-matrix.db-num :
    delete ub.c-assortment-matrix.
end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_assortment-matrix}
        , input ( buffer ub.assortment-matrix:handle )
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