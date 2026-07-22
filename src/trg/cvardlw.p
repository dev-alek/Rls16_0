block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице ИСТОРИЯ ВАРИАНТОВ ДОСТАВКИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/04
Author: Bakhtadze Natalya
Creation date: 03/24/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-variant-delivery.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице ИСТОРИЯ ВАРИАНТОВ ДОСТАВКИ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6', ub.c-variant-delivery.deliv-type-code,
                                              ub.c-variant-delivery.deliv-subj-code,
                                              ub.c-variant-delivery.obj-type,
                                              ub.c-variant-delivery.obj-code,
                                              ub.c-variant-delivery.corr-user-db-num,
                                              ub.c-variant-delivery.chip-num
                                              ) " }

{ cmp/trg-def.i }

define buffer buf_delivery-type for ub.delivery-type.
define buffer buf_delivery-subject for ub.delivery-subject.
define buffer buf_clients for ub.clients.
define buffer buf_variant-delivery for ub.variant-delivery.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    find first buf_delivery-type no-lock where
               buf_delivery-type.deliv-type-code = c-variant-delivery.deliv-type-code  no-error .
    if not available buf_delivery-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ТИП ДОСТАВКИ" skip
      "код" c-variant-delivery.deliv-type-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_delivery-subject no-lock where
               buf_delivery-subject.deliv-subj-code = c-variant-delivery.deliv-subj-code  no-error .
    if not available buf_delivery-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на СУБЪЕКТ ДОСТАВКИ" skip
      "код" c-variant-delivery.deliv-subj-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_clients no-lock where
               buf_clients.obj-type = c-variant-delivery.obj-type
           AND buf_clients.obj-code = c-variant-delivery.obj-code
               no-error .
    if not available buf_clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ОБЪЕКТ ДОСТАВКИ" skip
      "тип" c-variant-delivery.obj-type    skip
      "код" c-variant-delivery.obj-code   skip
       view-as alert-box error .
      undo main-block, return error.
    end.


    find first buf_variant-delivery no-lock where
               buf_variant-delivery.deliv-type-code = c-variant-delivery.deliv-type-code
           AND buf_variant-delivery.deliv-subj-code = c-variant-delivery.deliv-subj-code
           AND buf_variant-delivery.obj-type        = c-variant-delivery.obj-type
           AND buf_variant-delivery.obj-code        = c-variant-delivery.obj-code
               no-error .
    if not available buf_variant-delivery then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ВАРИАНТ ДОСТАВКИ" skip
      "код типа доставки" c-variant-delivery.deliv-type-code skip
      "код субъекта доставки" c-variant-delivery.deliv-subj-code skip
      "тип объекта доставки" c-variant-delivery.obj-type    skip
      "код объекта доставки" c-variant-delivery.obj-code   skip
       view-as alert-box error .
      undo main-block, return error.
    end.

  end.
  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории ВАРИАНТА ДОСТАВКИ в УБД" skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  run str/callnews.p
    (input {&table_c-variant-delivery}
  ,input (buffer ub.c-variant-delivery:handle)
  ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-variant-delivery}
        , input ( buffer ub.c-variant-delivery:handle )
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