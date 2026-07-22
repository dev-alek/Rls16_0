block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице ИСТОРИЯ КУРСА ММВБ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/27/05
Author: Bakhtadze Natalya
Creation date: 04/27/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-curr-accnt.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице ИСТОРИЯ КУРСА ММВБ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                        , ub.c-curr-accnt.curr-code
                        , ub.c-curr-accnt.exch-date
                        , ub.c-curr-accnt.corr-user-db-num
                        , ub.c-curr-accnt.chip-num
                                                         ) " }
{ cmp/trg-def.i }

define buffer buf_curr-accnt for ub.curr-accnt.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    find first buf_curr-accnt no-lock where
               buf_curr-accnt.curr-code = c-curr-accnt.curr-code
           AND buf_curr-accnt.exch-date = c-curr-accnt.exch-date
               no-error .
    if not available buf_curr-accnt then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на КУРС ВАЛЮТЫ ММВБ" skip
      "код" c-curr-accnt.curr-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории КУРСА ВАЛЮТЫ ММВБ в УБД" skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  run str/callnews.p
    (input {&table_c-curr-accnt}
    ,input (buffer ub.c-curr-accnt:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-curr-accnt}
        , input ( buffer ub.c-curr-accnt:handle )
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