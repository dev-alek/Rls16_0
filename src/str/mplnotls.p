block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mplnotls.p $
$Archive: str/mplnotls.p $

проверка, что ни одна из старых цен в множественном прайс-листе не потеряна

Автор: Чернова Светлана Александровна
Дата создания: 08/07/06
Author: Svetlana Chernova
Creation date: 08/07/06


*/
define input  parameter parParentProc as handle no-undo .
define input  parameter p-pdf-id as integer   no-undo .
define input  parameter p-pdf-db as integer   no-undo .
define input  parameter p-plt-id as integer   no-undo .
define input  parameter p-plt-db as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mplnotls.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/mplnotls.p $":U .
define variable vss-description as character no-undo init "проверка, что ни одна из старых цен в переоценке не потеряна".

{ cmp/vssrevis.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/xobjgrp.i  }  /* список объектов  */
{ gbl/getsect.i def }

define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.price-list.b-code     no-undo.

define buffer buf-price-list-type    for ub.price-list-type  .
define buffer main-list  for ub.price-doc-forming-gds.
define buffer main-list2 for ub.price-doc-forming-gds.
define buffer sub-list   for ub.price-doc-forming-gds.
define buffer old-list   for ub.price-list.
define buffer temp-price-doc for ub.price-doc.
/* Сохранять имеющиеся цены */
define variable par-pr-notls as character no-undo.    /* для чтения параметра конфигурации */
/* Сообщать при изменении скидки */
define variable par-pr-dscnt as character no-undo.    /* для чтения параметра конфигурации */
define variable par-pr-equ-dq as integer no-undo.     /* для чтения параметра конфигурации */
define variable ok-dscnt     as logical  no-undo.    /* чтоб только 1 раз спрашивать об изменившейся скидке */
define variable v-gds-code as integer   no-undo .
define variable v-b-code   as integer   no-undo .
define variable v-str1 as character no-undo .

define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_parts for ub.parts  .

/* проверка на главный основной код */
for each main-list no-lock where
         main-list.pdf-id = p-pdf-id and
         main-list.pdf-db = p-pdf-db and
         main-list.plt-id = p-plt-id and
         main-list.plt-db = p-plt-db
         :
         find first buf_goods no-lock where
                    buf_goods.artic     = main-list.artic     and
                    buf_goods.prod-type = main-list.prod-type and
                    buf_goods.prod-code = main-list.prod-code no-error .
         if error-status :error then do:
            return error substitute("Нет товара &1 &2&3 в справочнике товаров." , main-list.artic , main-list.prod-type , main-list.prod-code ).
         end.

         { gbl/gdsbcode.i
           buf_goods.gds-code
           ?
           v-b-code
           no-error }
          if error-status :error then do:
             return error return-value + error-status :get-message(1) .
          end.
         find first main-list2 no-lock where
                    main-list2.pdf-id = p-pdf-id and
                    main-list2.pdf-db = p-pdf-db and
                    main-list2.plt-id = p-plt-id and
                    main-list2.plt-db-num = p-plt-db and
                    main-list2.b-code = v-b-code
                    no-error .
        if not available main-list2 then do:
          /*
          return error substitute("Нет цены по главному основному коду &1 для баркода &2. &3 &4 &5 &6 &7" , v-b-code , main-list.b-code
          ,p-pdf-id
          ,p-pdf-db
          ,p-plt-id
          ,p-plt-db
          , error-status :get-message(1)
          ).
          */
        end.
end.

/* Получим из секции переоценок нужные переменные */
{ gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-overval}  }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-dscnt}  then par-pr-dscnt  = string( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-notls}  then par-pr-notls  = string( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-equ-dq} then par-pr-equ-dq = thbjattr_thbj-attr.property-value-integer .
end.
empty temp-table thbjattr_thbj-attr.


if par-pr-notls <> "yes" then
  /* проверять не требуется, все ОК */
  return.

ok-dscnt = false  .

find first  buf-price-list-type no-lock where
            buf-price-list-type.plt-id     = p-plt-id and
            buf-price-list-type.plt-db-num = p-plt-db no-error .
run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf-price-list-type.gop-id , buf-price-list-type.gop-db-num) .

for each x_obj-group :
for each main-list where
         main-list.pdf-id = p-pdf-id and
         main-list.pdf-db = p-pdf-db and
         main-list.plt-id = p-plt-id and
         main-list.plt-db = p-plt-db
         /*main-list.main-price = yes */ :
  /* находим цену главного кода */
  { gbl/bcodeprc.i
    x_obj-group.obj-type
    x_obj-group.obj-code
    main-list.b-code
    0
    0
    gp-doc-num
    gp-price-sale
    gp-road-tax
    gp-excise
    no-error }
    if error-status :error then do:
      return error "Ошибка поиска цены главного кода " + error-status :get-message(1) + return-value .
    end.
  /* цикл по всем спец и неосновным ценам найденной переоценки */
  for each  old-list no-lock where
            old-list.doc-num    = gp-doc-num and
            old-list.artic      = main-list.artic and
            old-list.prod-type  = main-list.prod-type and
            old-list.prod-code  = main-list.prod-code and
            old-list.main-price = no:
    /* ищем такой же код в заполняемой переоценке */
    find sub-list where
         sub-list.pdf-id = p-pdf-id and
         sub-list.pdf-db = p-pdf-db and
         sub-list.plt-id = p-plt-id and
         sub-list.plt-db = p-plt-db and
         sub-list.b-code  = old-list.b-code  no-error.
    if not available sub-list then do:
      if par-pr-equ-dq = 1  then do:
         find first buf_bar-code no-lock where
                    buf_bar-code.b-code = old-list.b-code and
                    buf_bar-code.in-code <> "" no-error .
          find first buf_parts no-lock where
                buf_parts.out-code    = {&free-code}           and
                buf_parts.obj-type    = x_obj-group.obj-type   and
                buf_parts.obj-code    = x_obj-group.obj-code   and
                buf_parts.rsrv-free   = true                   and
                buf_parts.status_     = false                  and
                buf_parts.artic       = old-list.artic         and
                buf_parts.prod-type   = old-list.prod-type     and
                buf_parts.prod-code   = old-list.prod-code     and
                buf_parts.part-code   = buf_bar-code.part-code and
                buf_parts.in-code     = buf_bar-code.in-code
                no-error .

      if available buf_bar-code then do:
         if buf_bar-code.in-code <> "" and not available buf_parts then next.
      end.


        return error substitute( "Потеряна по крайней мере одна существующая цена, &1
                     что запрещено настройкой pr-notls. &1
                     Код:&2  &1
                     Номер предыдущей переоценки: &3" ,
                     {&new-line} , old-list.b-code ,  gp-doc-num ).
      end.
      else next.
    end.
    /* проверяем изменение скидок */
    if par-pr-dscnt = "yes" then do:
          if not ok-dscnt and
            sub-list.d-pcnt <> old-list.d-pcnt then do:
              find first buf_goods no-lock where
                          buf_goods.artic     = sub-list.artic     and
                          buf_goods.prod-type = sub-list.prod-type and
                          buf_goods.prod-code = sub-list.prod-code no-error .
                v-str1 = substitute("ДНЦ. Изменилась по крайней мере одна скидка&4 Товар &5 &6&4 Код: &1&4 Старая скидка: &2 % (переоценка &7)&4 Новая скидка: &3 %" ,
                                      old-list.b-code,
                                      old-list.d-pcnt,
                                      sub-list.d-pcnt,
                                      {&new-line},
                                      buf_goods.artic,
                                      buf_goods.gds-name,
                                      old-list.doc-num
                                      ).

                message
                  v-str1 skip (2)
                  "Продолжать?"
                  view-as alert-box question buttons OK-Cancel update ok-dscnt.
              if not ok-dscnt then
                 return error  v-str1.
          end.
    end.
  end.
end.
end.