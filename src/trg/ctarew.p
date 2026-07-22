block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории тары

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/09
Author: Bakhtadze Natalya
Creation date: 09/29/09

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-tare.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории тары".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.c-tare.tare-code
                         , ub.c-tare.corr-user-db-num
                         , ub.c-tare.chip-num
                         ) " }


{ cmp/trg-def.i }

define buffer buf_tare for ub.tare.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    find first buf_tare no-lock where
               buf_tare.tare-code = ub.c-tare.tare-code  no-error .
    if not available buf_tare then do:
      undo main-block, return error substitute("&1 &2 &3&4Неправильная ссылка на ТАРУ&4Код тары &5"
                                                ,vss-workfile
                                                ,vss-revision
                                               ,vss-description
                                               ,{&new-line}
                                               , ub.c-tare.tare-code).
    end.
  end.
  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      undo main-block, return error substitute("&1 &2 &3&4Нельзя создавать записи истории тары в УБД"
                                                ,vss-workfile
                                                ,vss-revision
                                               ,vss-description
                                               , {&new-line}
                                               ).

    end.
  end.

  run str/callnews.p
    (input {&table_c-tare}
    ,input (buffer ub.c-tare:handle)
    ).


  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-tare}
        , input ( buffer ub.c-tare:handle )
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