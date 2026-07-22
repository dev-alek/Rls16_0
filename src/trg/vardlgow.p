block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице ВАРИАНТЫ ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕКТЕ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/06/04
Author: Bakhtadze Natalya
Creation date: 04/06/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.varianty-delivery-gds-obj OLD old_varianty-delivery-gds-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице ВАРИАНТЫ ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕКТЕ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                                       , ub.varianty-delivery-gds-obj.gds-code
                                       , ub.varianty-delivery-gds-obj.obj-type
                                       , ub.varianty-delivery-gds-obj.obj-code
                                       , ub.varianty-delivery-gds-obj.deliv-type-code
                                       , ub.varianty-delivery-gds-obj.deliv-subj-code
                                        ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer buf_c-varianty-delivery-gds-obj for ub.c-varianty-delivery-gds-obj.
define buffer buf_clients for ub.clients.
define buffer buf_goods for ub.goods.
define buffer buf_group-period-validity  for ub.group-period-validity.
define buffer buf_var-deliv-gr-per-val for ub.var-deliv-gr-per-val.
define buffer buf_deliv-type-cond-keep for ub.deliv-type-cond-keep.
define buffer buf_c-gds-hist for ub.c-gds-hist.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    { gbl/objdbnum.i ub.varianty-delivery-gds-obj.obj-type ub.varianty-delivery-gds-obj.obj-code v-db-num }
    if g#db-num <> v-db-num then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя изменять запись ВАРИАНТЫ ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕКТЕ для объекта другой БД" skip
      view-as alert-box error .
      undo main-block, return error .
    end.
    /*проверим реляционность*/
    find first buf_goods no-lock where
               buf_goods.gds-code = ub.varianty-delivery-gds-obj.gds-code  no-error .
    if not available buf_goods then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ТОВАР" skip
      "код товара" ub.varianty-delivery-gds-obj.gds-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_clients no-lock where
               buf_clients.obj-type = ub.varianty-delivery-gds-obj.obj-type
           AND buf_clients.obj-code = ub.varianty-delivery-gds-obj.obj-code
               no-error .
    if not available buf_clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ОБЪЕКТ ДОСТАВКИ" skip
      "тип" ub.varianty-delivery-gds-obj.obj-type    skip
      "код" ub.varianty-delivery-gds-obj.obj-code   skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_deliv-type-cond-keep no-lock where
               buf_deliv-type-cond-keep.deliv-type-code = ub.varianty-delivery-gds-obj.deliv-type-code
           AND buf_deliv-type-cond-keep.cond-keep-code  = ub.varianty-delivery-gds-obj.cond-keep-code
               no-error .
    if not available buf_deliv-type-cond-keep then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ТИП ДОСТАВКИ ПО УСЛОВИЯ ХРАНЕНИЯ" skip
      "код типа доставки" ub.varianty-delivery-gds-obj.deliv-type-code skip
      "код условий хранения" ub.varianty-delivery-gds-obj.cond-keep-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_var-deliv-gr-per-val no-lock where
               buf_var-deliv-gr-per-val.deliv-type-code = ub.varianty-delivery-gds-obj.deliv-type-code
           AND buf_var-deliv-gr-per-val.deliv-subj-code = ub.varianty-delivery-gds-obj.deliv-subj-code
           AND buf_var-deliv-gr-per-val.obj-type        = ub.varianty-delivery-gds-obj.obj-type
           AND buf_var-deliv-gr-per-val.obj-code        = ub.varianty-delivery-gds-obj.obj-code
           AND buf_var-deliv-gr-per-val.gr-per-val-code = ub.varianty-delivery-gds-obj.gr-per-val-code
               no-error .
    if not available buf_var-deliv-gr-per-val then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ВАРИАНТ ДОСТАВКИ" skip
      "код типа доставки" ub.varianty-delivery-gds-obj.deliv-type-code skip
      "код субъекта доставки" ub.varianty-delivery-gds-obj.deliv-subj-code skip
      "тип объекта доставки" ub.varianty-delivery-gds-obj.obj-type    skip
      "код объекта доставки" ub.varianty-delivery-gds-obj.obj-code   skip
      "код группы сроков годности" ub.varianty-delivery-gds-obj.gr-per-val-code   skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    {&table_varianty-delivery-gds-obj}
    0
    '':U
    0
    '':U
    '':U
    '':U
    0
    0
    0
    {&nws-to-hist}
    v-send
    no-error
    }
  end.
  if not g#news
  or v-send >= 0
  then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-varianty-delivery-gds-obj.
    buffer-copy old_varianty-delivery-gds-obj to buf_c-varianty-delivery-gds-obj
    assign
    buf_c-varianty-delivery-gds-obj.gds-code           = ub.varianty-delivery-gds-obj.gds-code
    buf_c-varianty-delivery-gds-obj.obj-type           = ub.varianty-delivery-gds-obj.obj-type
    buf_c-varianty-delivery-gds-obj.obj-code           = ub.varianty-delivery-gds-obj.obj-code
    buf_c-varianty-delivery-gds-obj.deliv-type-code    = ub.varianty-delivery-gds-obj.deliv-type-code
    buf_c-varianty-delivery-gds-obj.deliv-subj-code    = ub.varianty-delivery-gds-obj.deliv-subj-code
    buf_c-varianty-delivery-gds-obj.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-varianty-delivery-gds-obj.corr-time          = v-time
    buf_c-varianty-delivery-gds-obj.corr-user-db-num   = g#db-num
    buf_c-varianty-delivery-gds-obj.corr-user-name     = g#userid
    buf_c-varianty-delivery-gds-obj.corr-date          = v-date
    .
    { gbl/hostcode.i ub.varianty-delivery-gds-obj.obj-type ub.varianty-delivery-gds-obj.obj-code v-host-code }
    create buf_c-gds-hist.
    buffer-copy buf_c-varianty-delivery-gds-obj to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = (if new ub.varianty-delivery-gds-obj then integer({&hn-create}) else integer({&hn-update}))
    buf_c-gds-hist.subject = {&table_varianty-delivery-gds-obj}
    buf_c-gds-hist.host-code = v-host-code
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-gds-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
    .
  end.

  if not g#news
  or g#db-num > 0 then do:
    run str/callnews.p
      (input {&table_varianty-delivery-gds-obj}
      ,input (buffer ub.varianty-delivery-gds-obj:handle)
      ).
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_varianty-delivery-gds-obj}
        , input ( buffer ub.varianty-delivery-gds-obj:handle )
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