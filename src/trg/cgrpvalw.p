block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице истории групп сроков годности

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/10/04
Author: Bakhtadze Natalya
Creation date: 03/10/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-group-period-validity OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице групп сроков годности".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.c-group-period-validity.gr-per-val-code
                         , c-group-period-validity.corr-user-db-num
                         , ub.c-group-period-validity.chip-num
                         ) " }
{ cmp/trg-def.i }

define buffer buf_group-period-validity for ub.group-period-validity.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news then do:
    /*проверим реляционность*/
    find first buf_group-period-validity no-lock where
               buf_group-period-validity.gr-per-val-code = c-group-period-validity.gr-per-val-code  no-error .
    if not available buf_group-period-validity then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ГРУППУ СРОКОВ ГОДНОСТИ" skip
      "код" c-group-period-validity.gr-per-val-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории ГРУППЫ СРОКОВ ГОДНОСТИ в УБД" skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.

  run str/callnews.p
    (input "c-group-period-validity"
    ,input (buffer ub.c-group-period-validity:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-group-period-validity}
        , input ( buffer ub.c-group-period-validity:handle )
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