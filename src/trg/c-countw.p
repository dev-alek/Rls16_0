block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории страны

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/04/05
Author: Bakhtadze Natalya
Creation date: 08/04/05

*/


TRIGGER PROCEDURE FOR WRITE OF ub.c-country.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории страны".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.c-country.num-code
                         , ub.c-country.corr-user-db-num
                         , ub.c-country.chip-num
                         ) " }


{ cmp/trg-def.i }

define buffer buf_country for ub.country.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    find first buf_country no-lock where
               buf_country.num-code = ub.c-country.num-code  no-error .
    if not available buf_country then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на СТРАНУ" skip
      "код" ub.c-country.num-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории СТРАНЫ в УБД" skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    run str/callnews.p
      (input "c-country"
      ,input (buffer ub.c-country:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-country}
        , input ( buffer ub.c-country:handle )
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