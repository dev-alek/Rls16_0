block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригер на корректировку Групп сумм для ценообразованиz

Автор: Чернова Светлана Александровна
Дата создания: 02/06/06
Author: Svetlana Chernova
Creation date: 02/06/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.sum-group OLD old_sum-group.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Тригер на корректировку Групп сумм для ценообразованиz".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .
define variable v-chg-fields as character no-undo .


main-block :
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop",   vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

run cur-time in this-procedure(output v-today, output start-time).
 assign
   ub.sum-group.sys-date      = v-today
   ub.sum-group.sys-time-chr  = string(start-time, "hh:mm")
   ub.sum-group.sys-time      = start-time
   ub.sum-group.who           = g#userid
   ub.sum-group.db-num-chg    = g#db-num
 .
      if new (ub.sum-group)  then do:
          BUFFER-COPY ub.sum-group TO ub.c-sum-group
          assign
            ub.c-sum-group.chip-num           = next-value (s-corr-chip, {&db-name_schema})
            ub.c-sum-group.corr-time          = start-time
            ub.c-sum-group.corr-user-db-num   = g#db-num
            ub.c-sum-group.corr-user-name     = g#userid
            ub.c-sum-group.corr-date          = v-today
          .
      end.
      else do:
          BUFFER-COPY old_sum-group TO ub.c-sum-group
          assign
            ub.c-sum-group.chip-num           = next-value (s-corr-chip, {&db-name_schema})
            ub.c-sum-group.corr-time          = start-time
            ub.c-sum-group.corr-user-db-num   = g#db-num
            ub.c-sum-group.corr-user-name     = g#userid
            ub.c-sum-group.corr-date          = v-today
          .
      end.

if g#db-num = 0  or ( g#db-num > 0 and g#news = false  ) then do:
  run str/callnews.p
    (input "sum-group"
    ,input (buffer ub.sum-group:handle)
    ) no-error .
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при передаче в новости sum-group" skip
        return-value skip
        view-as alert-box error .
        return error.
    end.

end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_sum-group}
        , input ( buffer ub.sum-group:handle )
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