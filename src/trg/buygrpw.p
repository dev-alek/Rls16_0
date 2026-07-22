block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригер на корректировку Групп покупателей для ценообразованиЯ

Автор: Чернова Светлана Александровна
Дата создания: 02/06/06
Author: Svetlana Chernova
Creation date: 02/06/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.buyer-group OLD old_buyer-group.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Тригер на корректировку Групп покупателей для ценообразовани".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .
define variable v-chg-fields as character no-undo .

main-block :
do transaction
on error undo main-block, return error
:
run cur-time in this-procedure(output v-today, output start-time).
if not g#news then do:
 assign
   ub.buyer-group.sys-date      = v-today
   ub.buyer-group.sys-time-chr  = string(start-time, "hh:mm")
   ub.buyer-group.sys-time      = start-time
   ub.buyer-group.who           = g#userid
   ub.buyer-group.db-num-chg    = g#db-num
 .
 end.
/* История */

      create ub.c-buyer-group.
      if new (ub.buyer-group)  then do:
          BUFFER-COPY ub.buyer-group TO ub.c-buyer-group
          assign
            ub.c-buyer-group.chip-num           = next-value (s-corr-chip, {&db-name_schema})
            ub.c-buyer-group.corr-time          = start-time
            ub.c-buyer-group.corr-user-db-num   = g#db-num
            ub.c-buyer-group.corr-user-name     = g#userid
            ub.c-buyer-group.corr-date          = v-today
          .
      end.
      else do:
          BUFFER-COPY old_buyer-group TO ub.c-buyer-group
          assign
            ub.c-buyer-group.chip-num           = next-value (s-corr-chip, {&db-name_schema})
            ub.c-buyer-group.corr-time          = start-time
            ub.c-buyer-group.corr-user-db-num   = g#db-num
            ub.c-buyer-group.corr-user-name     = g#userid
            ub.c-buyer-group.corr-date          = v-today
          .
      end.

/*  НОВОСТИ   */
    if g#db-num = 0  or ( g#db-num > 0 and g#news = false  ) then do:
      run str/callnews.p
        (input "buyer-group"
        ,input (buffer ub.buyer-group:handle)
        ) no-error .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при передаче в новости buyer-group" skip
          return-value skip
          view-as alert-box error .
          return error.
      end.
    end.


    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_buyer-group}
        , input ( buffer ub.buyer-group:handle )
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