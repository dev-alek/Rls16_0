block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи информации по базе данных

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/03
Author: Dmitry Ukhanov
Creation date: 03/22/03

*/

trigger procedure for delete of ub.db-info .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи информации по базе данных".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

do
on error undo, return error
:

  define variable v-message as character no-undo .

  /* пишем команду на удаление в новости */
  run nws/cmd-del.p
    ( input {&table_db-info}
     ,input (buffer ub.db-info:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    assign
      v-message = substitute( "&1. Ошибка при отправке в новости команды на удаление записи информации по БД. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) )
    .
    if g#news = false then do:
      message
        v-message
        view-as alert-box error.
    end.
    return error v-message .
  end.

  if g#oxml = yes then do:
    run str/calloxml.p
      ( input {&nwsdochs_action_delete}
        ,input {&table_db-info}
        ,input ( buffer ub.db-info:handle )
      ) no-error.
    if error-status :error then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи информации по БД&1&3&1&4"
                                      ,{&new-line}
                                      ,vss-workfile
                                      ,return-value
                                      ,error-status :get-message ( 1 )
                                     ).
    end.
  end.
end.
