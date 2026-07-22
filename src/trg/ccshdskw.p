block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись ИСТОРИИ КАССЫ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-cash-desk.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись ИСТОРИИ КАССЫ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5', ub.c-cash-desk.db-num, ub.c-cash-desk.obj-code, ub.c-cash-desk.pos-type, ub.c-cash-desk.cash-num, ub.c-cash-desk.chip-num) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_cash-desk for ub.cash-desk.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

    /*проверим реляционность*/
    if c-cash-desk.is-del = no then do:
      find first buf_cash-desk no-lock where
                buf_cash-desk.db-num = c-cash-desk.db-num
            AND buf_cash-desk.obj-code = c-cash-desk.obj-code
            AND buf_cash-desk.pos-type = c-cash-desk.pos-type
            AND buf_cash-desk.cash-num = c-cash-desk.cash-num
                no-error .
      if not available buf_cash-desk then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неправильная ссылка на КАССУ" skip
        "БД" c-cash-desk.db-num skip
        "магазин" c-cash-desk.obj-code
        "Тип" c-cash-desk.pos-type
        "Номер" c-cash-desk.cash-num
        view-as alert-box error .
        undo main-block, return error.
      end.
   end.
  run str/callnews.p
    (input "c-cash-desk"
    ,input (buffer ub.c-cash-desk:handle)
    ) no-error .
  if error-status:error then undo main-block, return error return-value .
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-cash-desk}
        , input ( buffer ub.c-cash-desk:handle )
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