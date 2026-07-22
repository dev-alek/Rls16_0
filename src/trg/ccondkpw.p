block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице истории УСЛОВИЙ ХРАНЕНИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/15/04
Author: Bakhtadze Natalya
Creation date: 03/15/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-condition-keeping  OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице истории УСЛОВИЙ ХРАНЕНИЯ".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.c-condition-keeping.cond-keep-code
                         , ub.c-condition-keeping.corr-user-db-num
                         , ub.c-condition-keeping.chip-num
                         ) " }
{ cmp/trg-def.i }

define buffer buf_condition-keeping for ub.condition-keeping.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    find first buf_condition-keeping no-lock where
               buf_condition-keeping.cond-keep-code = c-condition-keeping.cond-keep-code  no-error .
    if not available buf_condition-keeping then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на УСЛОВИЯ ХРАНЕНИЯ" skip
      "код" c-condition-keeping.cond-keep-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории УСЛОВИЙ ХРАНЕНИЯ в УБД" skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.

  run str/callnews.p
    (input "c-condition-keeping"
    ,input (buffer ub.c-condition-keeping:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-condition-keeping}
        , input ( buffer ub.c-condition-keeping:handle )
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