block-level on error undo, throw.
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись акцизной или специальной марки

Автор: Хныкин Павел Андреевич
Дата создания: 03/01/06
Author: Pavel Khnykin
Creation date: 03/01/06

*/

trigger procedure for write of ub.ex-mark old old_ex-mark.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись акцизной или специальной марки".
{ cmp/vssrevis.i "substitute('&1|&2'
                            , ub.ex-mark.db-num
                            , ub.ex-mark.mark-code
                            ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

define variable v-date as date    no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-ex-mark for ub.c-ex-mark.

main-block :
do transaction
on error undo main-block, return error return-value
:
  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-ex-mark.
    /* при создании новой записи копируем в историю текущие значения */
    if new ub.ex-mark then do:
      buffer-copy ub.ex-mark to buf_c-ex-mark.
    end.
    else do:
      buffer-copy old_ex-mark to buf_c-ex-mark.
    end.
    assign
      buf_c-ex-mark.chip-num         = next-value (s-corr-chip, {&db-name_schema})
      buf_c-ex-mark.corr-time        = v-time
      buf_c-ex-mark.corr-user-db-num = g#db-num
      buf_c-ex-mark.corr-user-name   = g#userid
      buf_c-ex-mark.corr-date        = v-date
    .
  end.

  run str/callnews.p
    (input "ex-mark"
    ,input (buffer ub.ex-mark:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_ex-mark}
        , input ( buffer ub.ex-mark:handle )
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