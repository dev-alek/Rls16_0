block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице ИСТОРИЯ ВАРИАНТОВ ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕКТЕ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/06/04
Author: Bakhtadze Natalya
Creation date: 04/06/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-varianty-delivery-gds-obj.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице ИСТОРИЯ ВАРИАНТОВ ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕКТЕ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                                       , ub.c-varianty-delivery-gds-obj.gds-code
                                       , ub.c-varianty-delivery-gds-obj.obj-type
                                       , ub.c-varianty-delivery-gds-obj.obj-code
                                       , ub.c-varianty-delivery-gds-obj.deliv-type-code
                                       , ub.c-varianty-delivery-gds-obj.deliv-subj-code
                                       , ub.c-varianty-delivery-gds-obj.corr-user-db-num
                                       , ub.c-varianty-delivery-gds-obj.chip-num
                                        ) " }

{ cmp/trg-def.i }
define variable v-db-num like ub.db.db-num no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_varianty-delivery-gds-obj for ub.varianty-delivery-gds-obj.
define buffer buf_group-period-validity  for ub.group-period-validity.
define buffer buf_var-deliv-gr-per-val for ub.var-deliv-gr-per-val.
define buffer buf_deliv-type-cond-keep for ub.deliv-type-cond-keep.

define buffer buf_goods for ub.goods.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    find first buf_goods no-lock where
               buf_goods.gds-code = ub.c-varianty-delivery-gds-obj.gds-code  no-error .
    if not available buf_goods then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ТОВАР" skip
      "код товара" ub.c-varianty-delivery-gds-obj.gds-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_clients no-lock where
               buf_clients.obj-type = c-varianty-delivery-gds-obj.obj-type
           AND buf_clients.obj-code = c-varianty-delivery-gds-obj.obj-code
               no-error .
    if not available buf_clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ОБЪЕКТ ДОСТАВКИ" skip
      "тип" c-varianty-delivery-gds-obj.obj-type    skip
      "код" c-varianty-delivery-gds-obj.obj-code   skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_deliv-type-cond-keep no-lock where
               buf_deliv-type-cond-keep.deliv-type-code = ub.c-varianty-delivery-gds-obj.deliv-type-code
           AND buf_deliv-type-cond-keep.cond-keep-code  = ub.c-varianty-delivery-gds-obj.cond-keep-code
               no-error .
    if not available buf_deliv-type-cond-keep then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ТИП ДОСТАВКИ ПО УСЛОВИЯ ХРАНЕНИЯ" skip
      "код типа доставки" ub.c-varianty-delivery-gds-obj.deliv-type-code skip
      "код условий хранения" ub.c-varianty-delivery-gds-obj.cond-keep-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_var-deliv-gr-per-val no-lock where
               buf_var-deliv-gr-per-val.deliv-type-code = ub.c-varianty-delivery-gds-obj.deliv-type-code
           AND buf_var-deliv-gr-per-val.deliv-subj-code = ub.c-varianty-delivery-gds-obj.deliv-subj-code
           AND buf_var-deliv-gr-per-val.obj-type        = ub.c-varianty-delivery-gds-obj.obj-type
           AND buf_var-deliv-gr-per-val.obj-code        = ub.c-varianty-delivery-gds-obj.obj-code
           AND buf_var-deliv-gr-per-val.gr-per-val-code = ub.c-varianty-delivery-gds-obj.gr-per-val-code
               no-error .
    if not available buf_var-deliv-gr-per-val then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ВАРИАНТ ДОСТАВКИ ПО ГРУППЕ СРОКОВ ГОДНОСТИ" skip
      "код типа доставки" ub.c-varianty-delivery-gds-obj.deliv-type-code skip
      "код субъекта доставки" ub.c-varianty-delivery-gds-obj.deliv-subj-code skip
      "тип объекта доставки" ub.c-varianty-delivery-gds-obj.obj-type    skip
      "код объекта доставки" ub.c-varianty-delivery-gds-obj.obj-code   skip
      "код группы сроков годности" ub.c-varianty-delivery-gds-obj.gr-per-val-code   skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_varianty-delivery-gds-obj no-lock where
               buf_varianty-delivery-gds-obj.gds-code        = c-varianty-delivery-gds-obj.gds-code
           AND buf_varianty-delivery-gds-obj.obj-type        = c-varianty-delivery-gds-obj.obj-type
           AND buf_varianty-delivery-gds-obj.obj-code        = c-varianty-delivery-gds-obj.obj-code
           AND buf_varianty-delivery-gds-obj.deliv-type-code = c-varianty-delivery-gds-obj.deliv-type-code
           AND buf_varianty-delivery-gds-obj.deliv-subj-code = c-varianty-delivery-gds-obj.deliv-subj-code
               no-error .
    if not available buf_varianty-delivery-gds-obj then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ВАРИАНТ ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕКТЕ" skip
      "код товара" c-varianty-delivery-gds-obj.gds-code skip
      "код типа доставки" c-varianty-delivery-gds-obj.deliv-type-code skip
      "код субъекта доставки" c-varianty-delivery-gds-obj.deliv-subj-code skip
      "тип объекта доставки" c-varianty-delivery-gds-obj.obj-type    skip
      "код объекта доставки" c-varianty-delivery-gds-obj.obj-code   skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    { gbl/objdbnum.i ub.c-varianty-delivery-gds-obj.obj-type ub.c-varianty-delivery-gds-obj.obj-code v-db-num }
    if g#db-num <> v-db-num then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории ВАРИАНТА ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕТКЕ для объекта другой БД" skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.

if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  OR (g#news
      and not ( g#db-num > 0 )
      and ub.c-varianty-delivery-gds-obj.corr-user-name <> {&nts-user}
      ) /*транзит из УБД1 через ГБД в УБД2*/
      /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-varianty-delivery-gds-obj.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then
  run str/callnews.p
    (input "c-varianty-delivery-gds-obj"
    ,input (buffer ub.c-varianty-delivery-gds-obj:handle)
    ).


    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-varianty-delivery-gds-obj}
        , input ( buffer ub.c-varianty-delivery-gds-obj:handle )
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