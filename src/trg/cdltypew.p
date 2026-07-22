block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице ИСТОРИЯ ТИПОВ ДОСТАВКИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/16/04
Author: Bakhtadze Natalya
Creation date: 03/16/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-delivery-type.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице ИСТОРИЯ ТИПОВ ДОСТАВКИ".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                       , ub.c-delivery-type.deliv-type-code
                       , ub.c-delivery-type.corr-user-db-num
                       , ub.c-delivery-type.chip-num
                       ) " }
{ cmp/trg-def.i }

define buffer buf_delivery-type for ub.delivery-type.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    find first buf_delivery-type no-lock where
               buf_delivery-type.deliv-type-code = c-delivery-type.deliv-type-code  no-error .
    if not available buf_delivery-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ТИП ДОСТАВКИ" skip
      "код" c-delivery-type.deliv-type-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории ТИПА ДОСТАВКИ в УБД" skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.

  run str/callnews.p
    (input "c-delivery-type"
    ,input (buffer ub.c-delivery-type:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-delivery-type}
        , input ( buffer ub.c-delivery-type:handle )
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