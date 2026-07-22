block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице ВАРИАНТЫ ДОСТАВКИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/04
Author: Bakhtadze Natalya
Creation date: 03/24/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.variant-delivery OLD old_variant-delivery.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице ВАРИАНТЫ ДОСТАВКИ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4', ub.variant-delivery.deliv-type-code, ub.variant-delivery.deliv-subj-code,
                                        ub.variant-delivery.obj-type,
                                        ub.variant-delivery.obj-code
                                        ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-variant-delivery for ub.c-variant-delivery.
define buffer buf_delivery-type for ub.delivery-type.
define buffer buf_delivery-subject for ub.delivery-subject.
define buffer buf_clients for ub.clients.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя изменять запись ВАРИАНТЫ ДОСТАВКИ" skip
      view-as alert-box error .
      undo main-block, return error .
    end.
    /*проверим реляционность*/
    find first buf_delivery-type no-lock where
               buf_delivery-type.deliv-type-code = ub.variant-delivery.deliv-type-code  no-error .
    if not available buf_delivery-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ТИП ДОСТАВКИ" skip
      "код типа доставки" ub.variant-delivery.deliv-type-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_delivery-subject no-lock where
               buf_delivery-subject.deliv-subj-code = ub.variant-delivery.deliv-subj-code  no-error .
    if not available buf_delivery-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на СУБЪЕКТ ДОСТАВКИ" skip
      "код субъекта доставки" ub.variant-delivery.deliv-subj-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_clients no-lock where
               buf_clients.obj-type = ub.variant-delivery.obj-type
           AND buf_clients.obj-code = ub.variant-delivery.obj-code
               no-error .
    if not available buf_clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ОБЪЕКТ ДОСТАВКИ" skip
      "тип" ub.variant-delivery.obj-type    skip
      "код" ub.variant-delivery.obj-code   skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-variant-delivery.
    buffer-copy old_variant-delivery to buf_c-variant-delivery
    assign
    buf_c-variant-delivery.deliv-type-code    = ub.variant-delivery.deliv-type-code
    buf_c-variant-delivery.deliv-subj-code    = ub.variant-delivery.deliv-subj-code
    buf_c-variant-delivery.obj-type           = ub.variant-delivery.obj-type
    buf_c-variant-delivery.obj-code           = ub.variant-delivery.obj-code
    buf_c-variant-delivery.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-variant-delivery.corr-time          = v-time
    buf_c-variant-delivery.corr-user-db-num   = g#db-num
    buf_c-variant-delivery.corr-user-name     = g#userid
    buf_c-variant-delivery.corr-date          = v-date
    .
  end.

  run str/callnews.p
    (input "variant-delivery"
    ,input (buffer ub.variant-delivery:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_variant-delivery}
        , input ( buffer ub.variant-delivery:handle )
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