block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление связи счета-фактуры с док-ми

Автор: Чернова Светлана Александровна
Дата создания: 10/06/05
Author: Svetlana Chernova
Creation date: 10/06/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.factur-connect .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление связи счета-фактуры с док-ми".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.factur-connect.connect-code, ub.factur-connect.factur-doc-code, ub.factur-connect.trn-doc-code ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error
:
  run nws/cmd-del.p  (input "factur-connect",input (buffer ub.factur-connect:handle),input "":U ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_factur-connect}
        , input ( buffer ub.factur-connect:handle )
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