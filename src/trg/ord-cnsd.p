block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление СЗФП

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 04/27/02 2:43

*/

TRIGGER PROCEDURE FOR DELETE OF ub.ORD-cons .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление СЗФП".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block :
do transaction
on error undo main-block, return error
:

  /* удаление всех строк документа */
  for each ub.ORD-gds-cons
    where ub.ORD-gds-cons.cons-code = ub.ORD-cons.cons-code
  on error undo main-block, return error
  :
    delete ub.ORD-gds-cons .
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_ORD-cons}
        , input ( buffer ub.ORD-cons:handle )
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

/* $Workfile$ e n d */