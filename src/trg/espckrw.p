block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись номеров пакетов новостей, принятых данной БД от других внешних систем.

Автор: Хныкин Павел Андреевич
Дата создания: 02/21/07
Author: Pavel Khnykin
Creation date: 02/21/07

Input:

Output:

*/

trigger procedure for write of ub.esys-pck-rcvd .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись номеров пакетов новостей, принятых данной БД от других внешних систем.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute("&1. error &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo main-block, return error substitute("&1. endkey")
on stop   undo main-block, return error substitute("&1. stop")
:

  /*
  убрали хождение в ГБД рутов во внешнюю систему,
  т.к. при настроенном DATAKRAT при закрытии продаж, в новости уходили изменения остатков
  и все умирало.
  if g#db-num > 0
  and not g#news then do:
    run str/callnews.p
      (input {&table_esys-pck-rcvd}
      ,input (buffer ub.esys-pck-rcvd:handle)
      ) no-error .
    if error-status:error then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры callnews.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo main-block,  return error return-value .
    end.
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_esys-pck-rcvd}
        , input ( buffer ub.esys-pck-rcvd:handle )
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
  */
end.