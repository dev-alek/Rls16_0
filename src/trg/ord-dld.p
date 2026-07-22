block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление строки  заказа

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

TRIGGER PROCEDURE FOR DELETE OF UB.ORD-LINE .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление заказа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }


main-block :
do transaction
on error undo main-block, return error
:

  /* удаление всех строк признаков */
  for each ub.ord-dtl exclusive-lock
    where ub.ord-dtl.doc-code = ub.ORD-line.doc-code and
          ub.ord-dtl.artic = ub.ORD-line.artic and
          ub.ord-dtl.prod-type = ub.ORD-line.prod-type and
          ub.ord-dtl.prod-code = ub.ORD-line.prod-code
  on error undo main-block, return error
  :
    delete ub.ord-dtl .
  end.

/* удаление атрибутов */
  for each ub.ord-line-attr exclusive-lock
    where ub.ord-line-attr.doc-code = ub.ord-line.doc-code and
          ub.ord-line-attr.gds-code  = ub.ord-line.gds-code
    on error undo main-block, return error
    :
      delete ub.ord-line-attr .
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_ord-line}
        , input ( buffer ub.ord-line:handle )
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