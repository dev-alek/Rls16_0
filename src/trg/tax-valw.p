block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись для таблицы значение ставки налога

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.tax-rate-value OLD old-tax-rate-value.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись для таблицы значение ставки налога".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                         , ub.tax-rate-value.tax-code
                         , ub.tax-rate-value.rate-code
                         , ub.tax-rate-value.corr-user-db-num
                         , ub.tax-rate-value.chip-num
                         , ub.tax-rate-value.host-code
                         , ub.tax-rate-value.obj-type
                         , ub.tax-rate-value.obj-code
                         ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.


DEFINE buffer b_sysconf for ub.sysconf.
DEFINE buffer b_shop    for ub.shop.
DEFINE buffer b_store   for ub.store.
DEFINE buffer b_clients   for ub.clients.
define buffer b_tax-rate-value for ub.tax-rate-value .
define buffer buf_c-tax-hist for ub.c-tax-hist.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

    if not g#news and
    ( g#db-num > 0 ) and
    (ub.tax-rate-value.host-code = 0 OR
    (ub.tax-rate-value.obj-type = '':U AND
      ub.tax-rate-value.obj-code = 0)
    ) then do:
      message
      "Нельзя заводить значения налога по фирме и/или" skip
      "глобальное значение налога в УБД"
      view-as alert-box error .
      undo main-block, return error .

    end.


 if (ub.tax-rate-value.host-code = 0 and
     (ub.tax-rate-value.obj-type  <> "":U OR
      ub.tax-rate-value.obj-code  <> 0)
    ) OR
    (ub.tax-rate-value.obj-type = "":U  AND
     ub.tax-rate-value.obj-code  <> 0) OR
    (ub.tax-rate-value.obj-type <> "":U  AND
     ub.tax-rate-value.obj-code  = 0)  then do:


   message
      vss-workfile vss-revision vss-description skip
      "Ошибка при задании кода фирмы и/или объекта при записи значения ставки налога" skip
      "Код налога" ub.tax-rate-value.tax-code skip
      "Код ставки" ub.tax-rate-value.rate-code skip
      "Код фирмы" ub.tax-rate-value.host-code skip
      "Тип объекта" ub.tax-rate-value.obj-type skip
      "Код объекта" ub.tax-rate-value.obj-code skip
      "Факт. дата" ub.tax-rate-value.fact-date skip
      "Статус" ub.tax-rate-value.status_
      view-as alert-box error .
    undo main-block, return error .
 end.

 if ub.tax-rate-value.host-code <> 0 then do:
  find first b_sysconf No-LOCK WHERe
             b_sysconf.host-code = ub.tax-rate-value.host-code No-ERROR.
  if not avail b_sysconf then dO:
   message
      vss-workfile vss-revision vss-description skip
      "Не найдена фирма при записи значения ставки налога" skip
      "Код налога" ub.tax-rate-value.tax-code skip
      "Код ставки" ub.tax-rate-value.rate-code skip
      "Код фирмы" ub.tax-rate-value.host-code skip
      "Тип объекта" ub.tax-rate-value.obj-type skip
      "Код объекта" ub.tax-rate-value.obj-code skip
      "Факт. дата" ub.tax-rate-value.fact-date skip
      "Статус" ub.tax-rate-value.status_
      view-as alert-box error .
    undo main-block, return error .
  end.
 end.
 if ub.tax-rate-value.obj-code <> 0 then do:
  FIND FIRST b_clients No-LOCK WHERE
             b_clients.obj-type = ub.tax-rate-value.obj-type AND
             b_clients.obj-code = ub.tax-rate-value.obj-code No-ERROR.
  if not avail b_clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден объект при записи значения ставки налога" skip
      "Код налога" ub.tax-rate-value.tax-code skip
      "Код ставки" ub.tax-rate-value.rate-code skip
      "Код фирмы" ub.tax-rate-value.host-code skip
      "Тип объекта" ub.tax-rate-value.obj-type skip
      "Код объекта" ub.tax-rate-value.obj-code skip
      "Факт. дата" ub.tax-rate-value.fact-date skip
      "Статус" ub.tax-rate-value.status_ skip
      "Номер БД для объекта" b_clients.db-num skip
      "Номер текущей БД" g#db-num
      view-as alert-box error .
    undo main-block, return error .

  end.
  CASE ub.tax-rate-value.obj-type:
    when {&shop} then do:
      fiND FIRST B_SHOP NO-lock where
                  B_SHOP.OBJ-CODE = UB.TAX-RATE-value.obj-code No-ERROR.
      if not avail b_shop then do:
        message
            vss-workfile vss-revision vss-description skip
            "Не найден магазин при записи значения ставки налога" skip
            "Код налога" ub.tax-rate-value.tax-code skip
            "Код ставки" ub.tax-rate-value.rate-code skip
            "Код фирмы" ub.tax-rate-value.host-code skip
            "Тип объекта" ub.tax-rate-value.obj-type skip
            "Код объекта" ub.tax-rate-value.obj-code skip
            "Факт. дата" ub.tax-rate-value.fact-date skip
            "Статус" ub.tax-rate-value.status_
         view-as alert-box error .
         undo main-block, return error .
      end.
    end.
    when {&stock} then do:
      fiND FIRST B_Store NO-lock where
                  B_Store.OBJ-CODE = UB.TAX-RATE-value.obj-code No-ERROR.
      if not avail b_store then do:
        message
            vss-workfile vss-revision vss-description skip
            "Не найден склад при записи значения ставки налога" skip
            "Код налога" ub.tax-rate-value.tax-code skip
            "Код ставки" ub.tax-rate-value.rate-code skip
            "Код фирмы" ub.tax-rate-value.host-code skip
            "Тип объекта" ub.tax-rate-value.obj-type skip
            "Код объекта" ub.tax-rate-value.obj-code skip
            "Факт. дата" ub.tax-rate-value.fact-date skip
            "Статус" ub.tax-rate-value.status_
         view-as alert-box error .
         undo main-block, return error .

      end.
    end.
  end CASE.
  /*если значение по объекту то вводить его можно только в ГБД или в той базе где этот объект*/
  if not g#news then do:
    if ( g#db-num > 0 ) = yes and g#db-num <> b_clients.db-num then do:
        message
            vss-workfile vss-revision vss-description skip
            "Попытка определеить значения ставки налога на объекте в чужой БД" skip
            "Код налога" ub.tax-rate-value.tax-code skip
            "Код ставки" ub.tax-rate-value.rate-code skip
            "Код фирмы" ub.tax-rate-value.host-code skip
            "Тип объекта" ub.tax-rate-value.obj-type skip
            "Код объекта" ub.tax-rate-value.obj-code skip
            "Факт. дата" ub.tax-rate-value.fact-date skip
            "Статус" ub.tax-rate-value.status_
         view-as alert-box error .
         undo main-block, return error .

    end.
  end.
 end.

 find first ub.tax No-LOCK WHERE
            ub.tax.tax-code = ub.tax-rate-value.tax-code No-ERROR.
 if not avail ub.tax then do:
    message
        vss-workfile vss-revision vss-description skip
        "Не найден налог при записи значения ставки налога" skip
        "Код налога" ub.tax-rate-value.tax-code skip
        "Код ставки" ub.tax-rate-value.rate-code skip
        "Код фирмы" ub.tax-rate-value.host-code skip
        "Тип объекта" ub.tax-rate-value.obj-type skip
        "Код объекта" ub.tax-rate-value.obj-code skip
        "Факт. дата" ub.tax-rate-value.fact-date skip
        "Статус" ub.tax-rate-value.status_
        view-as alert-box error .
      undo main-block, return error .
 end.

 find first ub.tax-rate Exclusive-LOCK WHERE
            ub.tax-rate.tax-code = ub.tax-rate-value.tax-code AND
            ub.tax-rate.rate-code = ub.tax-rate-value.rate-code No-WAIT No-ERROR.
 if locked ub.tax-rate then do:
    message
        vss-workfile vss-revision vss-description skip
        "Занята запись ставки при записи значения ставки налога" skip
        "Код налога" ub.tax-rate-value.tax-code skip
        "Код ставки" ub.tax-rate-value.rate-code skip
        "Код фирмы" ub.tax-rate-value.host-code skip
        "Тип объекта" ub.tax-rate-value.obj-type skip
        "Код объекта" ub.tax-rate-value.obj-code skip
        "Факт. дата" ub.tax-rate-value.fact-date skip
        "Статус" ub.tax-rate-value.status_
        view-as alert-box error .
      undo main-block, return error .
 end.
 if not avail ub.tax then do:
    message
        vss-workfile vss-revision vss-description skip
        "Не найдена ставка при записи значения ставки налога" skip
        "Код налога" ub.tax-rate-value.tax-code skip
        "Код ставки" ub.tax-rate-value.rate-code skip
        "Код фирмы" ub.tax-rate-value.host-code skip
        "Тип объекта" ub.tax-rate-value.obj-type skip
        "Код объекта" ub.tax-rate-value.obj-code skip
        "Факт. дата" ub.tax-rate-value.fact-date skip
        "Статус" ub.tax-rate-value.status_
        view-as alert-box error .
      undo main-block, return error .
 end.

if ub.tax-rate.status_ = {&deleted-status} and
   not g#news and
   ub.tax-rate-value.status_ <> {&deleted-status} then do:
   message
    vss-workfile vss-revision vss-description skip
    "Нельзя добавлять/или изменятьзначение ставки налога для удаленной ставки" skip
    "Код налога" ub.tax-rate-value.tax-code skip
    "Код ставки" ub.tax-rate-value.rate-code skip
    "Код фирмы" ub.tax-rate-value.host-code skip
    "Тип объекта" ub.tax-rate-value.obj-type skip
    "Код объекта" ub.tax-rate-value.obj-code skip
    "Факт. дата" ub.tax-rate-value.fact-date SKIP
    "Статус" ub.tax-rate-value.status_
    "Значение" ub.tax-rate-value.rate-value
    view-as alert-box error .
  undo main-block, return error .
end.

 /* не будем генерить дубли !! но только если это не G#news*/
if not g#news then do:

  FIND LAST  b_tax-rate-value No-LOCK WHERE
              b_tax-rate-value.tax-code = ub.tax-rate-value.tax-code AND
              b_tax-rate-value.rate-code = ub.tax-rate-value.rate-code AND
              b_tax-rate-value.host-code = ub.tax-rate-value.host-code AND
              b_tax-rate-value.obj-type =  ub.tax-rate-value.obj-type AND
              b_tax-rate-value.obj-code =  ub.tax-rate-value.obj-code AND
              b_tax-rate-value.fact-order <=  ub.tax-rate-value.fact-order AND
              b_tax-rate-value.status_ =  ub.tax-rate-value.status_ AND
              ub.tax-rate-value.status_ = {&current-status} AND
              recid(b_tax-rate-value) <> recid(ub.tax-rate-value) NO-ERROR.
  if avail b_tax-rate-value and b_tax-rate-value.rate-value = ub.tax-rate-value.rate-value then do:
      message
          vss-workfile vss-revision vss-description skip
          "На выбранную дату уже есть такое же значение ставки налога" skip
          "Код налога" ub.tax-rate-value.tax-code skip
          "Код ставки" ub.tax-rate-value.rate-code skip
          "Код фирмы" ub.tax-rate-value.host-code skip
          "Тип объекта" ub.tax-rate-value.obj-type skip
          "Код объекта" ub.tax-rate-value.obj-code skip
          "Факт. дата" ub.tax-rate-value.fact-date SKIP
          "Статус" ub.tax-rate-value.status_
          "Значение" ub.tax-rate-value.rate-value
          view-as alert-box error .
        undo main-block, return error .


  end.
end. /* if not g#news*/

  assign
  ub.tax-rate-value.status_ = (if ub.tax-rate.status_ = {&deleted-status} and g#news
                               then {&deleted-status}
                               else ub.tax-rate-value.status_
                              )
  .
  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    assign
    ub.tax-rate-value.chip-num           = next-value(s-corr-chip, {&db-name_schema})
    ub.tax-rate-value.corr-time          = v-time
    ub.tax-rate-value.corr-user-db-num   = g#db-num
    ub.tax-rate-value.corr-user-name     = g#userid
    ub.tax-rate-value.corr-date          = v-date
    .
    create buf_c-tax-hist.
    buffer-copy tax-rate-value to buf_c-tax-hist
    assign
    buf_c-tax-hist.action = (if new (ub.tax-rate-value )
                            then integer({&hn-create})
                            else integer({&hn-update}))
    buf_c-tax-hist.subject = {&table_tax-rate-value}
    buf_c-tax-hist.is-news = no
    .
  end.
  run str/callnews.p
    (input {&table_tax-rate-value}
    ,input (buffer ub.tax-rate-value:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_tax-rate-value}
        , input ( buffer ub.tax-rate-value:handle )
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