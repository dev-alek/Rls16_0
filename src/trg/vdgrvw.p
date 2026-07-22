block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице ВАРИАНТЫ ДОСТАВКИ ПО ГРУППАМ СРОКОВ ГОДНОСТИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/04
Author: Bakhtadze Natalya
Creation date: 03/24/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.var-deliv-gr-per-val old OLD_VAR-DELIV-GR-PER-VAL.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице ВАРИАНТЫ ДОСТАВКИ ПО ГРУППАМ СРОКОВ ГОДНОСТИ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5', ub.c-var-deliv-gr-per-val.deliv-type-code,
                                                ub.c-var-deliv-gr-per-val.deliv-subj-code,
                                              ub.c-var-deliv-gr-per-val.obj-type,
                                              ub.c-var-deliv-gr-per-val.obj-code,
                                              ub.c-var-deliv-gr-per-val.gr-per-val-code) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-var-deliv-gr-per-val for ub.c-var-deliv-gr-per-val.
define buffer buf_delivery-type for ub.delivery-type.
define buffer buf_delivery-subject for ub.delivery-subject.
define buffer buf_clients for ub.clients.
define buffer buf_group-period-validity for ub.group-period-validity.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя изменять запись ВАРИАНТЫ ДОСТАВКИ ПО ГРУППАМ СРОКОВ ГОДНОСТИ в УБД" skip
      view-as alert-box error .
      undo, return error .
    end.
    /*проверим реляционность*/
    find first buf_delivery-type no-lock where
               buf_delivery-type.deliv-type-code = ub.var-deliv-gr-per-val.deliv-type-code  no-error .
    if not available buf_delivery-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ТИП ДОСТАВКИ" skip
      "код типа доставки" ub.var-deliv-gr-per-val.deliv-type-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_delivery-subject no-lock where
               buf_delivery-subject.deliv-subj-code = ub.var-deliv-gr-per-val.deliv-subj-code  no-error .
    if not available buf_delivery-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на СУБЪЕКТ ДОСТАВКИ" skip
      "код субъекта доставки" ub.var-deliv-gr-per-val.deliv-subj-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_group-period-validity no-lock where
               buf_group-period-validity.gr-per-val-code = ub.var-deliv-gr-per-val.gr-per-val-code  no-error .
    if not available buf_delivery-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ГРУППУ СРОКОВ ГОДНОСТИ" skip
      "код" ub.var-deliv-gr-per-val.deliv-type-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.


    find first buf_clients no-lock where
               buf_clients.obj-type = ub.var-deliv-gr-per-val.obj-type
           AND buf_clients.obj-code = ub.var-deliv-gr-per-val.obj-code
               no-error .
    if not available buf_clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ОБЪЕКТ ДОСТАВКИ" skip
      "тип" ub.var-deliv-gr-per-val.obj-type    skip
      "код" ub.var-deliv-gr-per-val.obj-code   skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-var-deliv-gr-per-val.
    buffer-copy old_var-deliv-gr-per-val to buf_c-var-deliv-gr-per-val
    assign
    buf_c-var-deliv-gr-per-val.deliv-type-code    = ub.var-deliv-gr-per-val.deliv-type-code
    buf_c-var-deliv-gr-per-val.deliv-subj-code    = ub.var-deliv-gr-per-val.deliv-subj-code
    buf_c-var-deliv-gr-per-val.gr-per-val-code    = ub.var-deliv-gr-per-val.gr-per-val-code
    buf_c-var-deliv-gr-per-val.obj-type           = ub.var-deliv-gr-per-val.obj-type
    buf_c-var-deliv-gr-per-val.obj-code           = ub.var-deliv-gr-per-val.obj-code
    buf_c-var-deliv-gr-per-val.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-var-deliv-gr-per-val.corr-time          = v-time
    buf_c-var-deliv-gr-per-val.corr-user-db-num   = g#db-num
    buf_c-var-deliv-gr-per-val.corr-user-name     = g#userid
    buf_c-var-deliv-gr-per-val.corr-date          = v-date
    .
  end.

  run str/callnews.p
    (input "var-deliv-gr-per-val"
    ,input (buffer ub.var-deliv-gr-per-val:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_var-deliv-gr-per-val}
        , input ( buffer ub.var-deliv-gr-per-val:handle )
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