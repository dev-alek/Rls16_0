block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Глобальные параметры ценообразования - триггер на запись

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06

*/
TRIGGER PROCEDURE FOR WRITE OF ub.global-state.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Глобальные параметры ценообразования - триггер на запись".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i }
{ gbl/cur-time.i }

define variable user-db-num as integer   no-undo .
main-block :
do transaction
on error undo main-block, return error
:

  /* обновляем пользователя, дату и время последнего обновления */
  if not g#news
  then do:

     if g#db-num <> 0 then return .

    { gbl/curdburt.i
      user-db-num
      ub.global-state.who
      ub.global-state.sys-date
      ub.global-state.sys-time-chr
      ub.global-state.sys-time
    }
/* создать историю и отправить их в новости  */
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).

   create ub.c-global-state.
   buffer-copy ub.global-state to ub.c-global-state
   assign
      ub.c-global-state.chip-num          = next-value ( s-chip-mp , {&db-name_schema} )
      ub.c-global-state.corr-date         = v-today
      ub.c-global-state.corr-time         = v-time
      ub.c-global-state.corr-user-db-num  = g#db-num
      ub.c-global-state.corr-user-name    = g#userid
      ub.c-global-state.db-num-chg        = g#db-num
   .
run str/callnews.p
          (input {&table_global-state}
          ,input (buffer ub.global-state:handle)
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно маршрутизировать global-state для отправки в новости" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.

  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_global-state}
        , input ( buffer ub.global-state:handle )
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