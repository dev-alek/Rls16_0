block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись информации о базе данных

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.db-status old buffer old-db-status .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись информации о базе данных".
{ cmp/vssrevis.i "substitute('&1|&2|&3':U,ub.db-status.db-num,ub.db-status.stock-date,ub.db-status.stock-time)" }
{ cmp/trg-def.i  }

main-block:
do
on error undo, return error
:
  define variable v-msg as character no-undo .
  /* записи БД маршрутизируются всегда только из ГБД */
  run str/callnews.p
    (input "db-status"
    ,input (buffer ub.db-status:handle)
    ) no-error .
  if error-status :error then do:
    assign
      v-msg = substitute( "Невозможно маршрутизировать db-status для отправки в новости&1&2&1&3"
                          ,{&new-line}
                          ,error-status :get-message(1)
                          ,return-value
                        )
    .
    if g#auto = true then do:
      return error substitute( "&1. &2", vss-workfile, v-msg ).
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        v-msg skip
        view-as alert-box.
      undo, return error .
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_db-status}
        , input ( buffer ub.db-status:handle )
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