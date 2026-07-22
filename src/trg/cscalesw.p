block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись ИСТОРИИ ВЕСОВ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/22/05
Author: Bakhtadze Natalya
Creation date: 04/22/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-scales.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись ИСТОРИИ ВЕСОВ".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.c-scales.db-num
                                         , ub.c-scales.scales-num
                                         , ub.c-scales.corr-user-db-num
                                         , ub.c-scales.chip-num) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_scales for ub.scales.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
    /*проверим реляционность*/
    if ub.c-scales.is-del = no then do:
      find first buf_scales no-lock where
                buf_scales.db-num = ub.c-scales.db-num
            AND buf_scales.scales-num = ub.c-scales.scales-num
                no-error .
      if not available buf_scales then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неправильная ссылка на ВЕСЫ" skip
        "БД" c-scales.db-num skip
        "Номер" c-scales.scales-num
        view-as alert-box error .
        undo main-block, return error.
      end.
   end.
   if not g#news and g#db-num <> ub.c-scales.db-num then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя изменять запись ИСТОРИИ ВЕСОВ в БД, отличной от БД весов" skip
      "Номер текущей БД" g#db-num "Номер БД весов" c-scales.db-num
      view-as alert-box error .
      undo, return error .
    end.
  run str/callnews.p
    (input {&table_c-scales}
    ,input (buffer ub.c-scales:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-scales}
        , input ( buffer ub.c-scales:handle )
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