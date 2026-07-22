block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице ИСТОРИЯ НАЛОГА ПО ЕД.ИЗМ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/16/04
Author: Bakhtadze Natalya
Creation date: 08/16/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-tax-units.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице ИСТОРИЯ НАЛОГА ПО ЕД.ИЗМ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.c-tax-units.tax-code
                         , ub.c-tax-units.type
                         , ub.c-tax.corr-user-db-num
                         , ub.c-tax.chip-num
                       ) " }
{ cmp/trg-def.i }

define buffer buf_tax-units for ub.tax-units.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    find first buf_tax-units no-lock where
               buf_tax-units.tax-code = c-tax-units.tax-code
           AND buf_tax-units.type     = c-tax-units.type
               no-error .
    if not available buf_tax-units then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на НАЛОГ на ед.изм" skip
      "код" c-tax.tax-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории НАЛОГА на ЕД.ИЗМ. в УБД" skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.

  run str/callnews.p
    (input "c-tax-units"
    ,input (buffer ub.c-tax-units:handle)
    ) .


    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-tax-units}
        , input ( buffer ub.c-tax-units:handle )
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