block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление маршрутизации во внешней системы.

Автор: Хныкин Павел Андреевич
Дата создания: 02/21/07
Author: Pavel Khnykin
Creation date: 02/21/07

Input:

Output:

*/

trigger procedure for delete of ub.esys-route .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление маршрутизации во внешней системы.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define buffer buf_esys-all-attr for ub.esys-all-attr.

main-block:
do
on error  undo main-block, return error substitute("&1. error &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo main-block, return error substitute("&1. endkey")
on stop   undo main-block, return error substitute("&1. stop")
:

  { trg/esrouted.i ub }
  /*
  убрали хождение в ГБД рутов во внешнюю систему,
  т.к. при настроенном DATAKRAT при закрытии продаж, в новости уходили изменения остатков
  и все умирало.

  if g#db-num > 0 then do:
    run nws/cmd-del.p
      ( input {&table_esys-route}
      ,input (buffer ub.esys-route:handle)
      ,input ''
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
  */

  for each buf_esys-all-attr where
          buf_esys-all-attr.attr-code =  {&table_esys-route}
      and buf_esys-all-attr.key1 = ub.esys-route.esr-dump-ord
      and buf_esys-all-attr.key2 = ub.esys-route.esys-id
      and buf_esys-all-attr.key5 = ub.esys-route.db-num
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    delete buf_esys-all-attr.
  end.

  /*а вот это непонятно зачем надо !!! - NVB
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_esys-route}
        , input ( buffer ub.esys-route:handle )
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
  */
end.