block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории ед изм

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/04/05
Author: Bakhtadze Natalya
Creation date: 08/04/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-units.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории ед изм".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.c-units.unit-name
                         , ub.c-units.corr-user-db-num
                         , ub.c-units.chip-num
                         ) " }


{ cmp/trg-def.i }

define buffer buf_units for ub.units.
define variable v-value as character no-undo.
define variable v-ttype as character no-undo.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    find first buf_units no-lock where
               buf_units.unit-name = ub.c-units.unit-name  no-error .
    if not available buf_units then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ЕД.ИЗМ." skip
      "код" ub.c-units.unit-name skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
    if v-value = "no"  then do: 
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории ЕД.ИЗМ." skip
      view-as alert-box error .
      undo main-block, return error.
    end.
    end.
  end.

  run str/callnews.p
    (input "c-units"
    ,input (buffer ub.c-units:handle)
    ).


    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-units}
        , input ( buffer ub.c-units:handle )
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
