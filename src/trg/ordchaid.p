block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

удаление цепочки

Автор: Чернова Светлана Александровна
Дата создания: 05/07/07
Author: Svetlana Chernova
Creation date: 05/07/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.ord-chain.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запись цепочки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
/* TODO Вставить команду на удаление */
  run nws/cmd-del.p
    ( input {&table_ord-chain}
      ,input (buffer ub.ord-chain:handle)
      ,input "":U
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи ord-chain. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

    if g#oxml = yes  then do:
        run str/calloxml.p (
              input {&nwsdochs_action_delete}
            , input {&table_ord-chain}
            , input ( buffer ub.ord-chain:handle )
        ) no-error.
        if error-status :error  then do:
            undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                                            , {&new-line}
                                            , vss-workfile
                                            , return-value
                                            , error-status :get-message ( 1 ) ).

        end.
    end.
end.