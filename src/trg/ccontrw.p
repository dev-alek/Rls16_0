block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории договора

Автор: Чернова Светлана Александровна
Дата создания: 03/23/06
Author: Svetlana Chernova
Creation date: 03/23/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-contract .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории договора".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.c-contract.contract-code, ub.c-contract.host-code, ub.c-contract.status_) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error
:
  run str/callnews.p ( input "c-contract", input (buffer ub.c-contract:handle) ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip   "Ошибка при передаче в новости истории договора" skip
      error-status :get-message(1) skip    return-value skip     view-as alert-box error .
    undo, return error.
  end.
    if g#oxml = yes
    then do:
      run str/calloxml.p (
            input {&nwsdochs_action_update}
          , input {&table_c-contract}
          , input ( buffer ub.c-contract:handle )
      ) no-error.
      if error-status :error
      then do:
          undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                               , {&new-line}
                               , vss-workfile
                               , return-value
                               , error-status :get-message ( 1 ) ).
      end.
    end.
end.