block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-notls.p $
$Archive: str/pr-notls.p $

проверка, что ни одна из старых цен в переоценке не потеряна

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06


*/

define input param d-num like ub.price-doc.doc-num no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-notls.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pr-notls.p $":U .
define variable vss-description as character no-undo init "проверка, что ни одна из старых цен в переоценке не потеряна".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getsect.i def }

define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.price-list.b-code     no-undo.

define buffer main-list      for ub.price-list.
define buffer sub-list       for ub.price-list.
define buffer old-list       for ub.price-list.
define buffer temp-price-doc for ub.price-doc.
define buffer buf_bar-code   for ub.bar-code  .
define buffer buf_parts      for ub.parts  .
define buffer buf_goods      for ub.goods  .
define variable v-str1        as character  no-undo .
/* Сохранять имеющиеся цены */
define variable par-pr-notls  as character  no-undo .    /* для чтения параметра конфигурации */
/* Сообщать при изменении скидки */
define variable par-pr-dscnt  as character  no-undo .    /* для чтения параметра конфигурации */
define variable par-pr-equ-dq as integer    no-undo .    /* для чтения параметра конфигурации */
define variable ok-dscnt      as logical    no-undo .    /* чтоб только 1 раз спрашивать об изменившейся скидке */

find first temp-price-doc where temp-price-doc.doc-num =  d-num no-lock .
/* Получим из секции переоценок нужные переменные */
{ gbl/getsect.i run temp-price-doc.obj-type temp-price-doc.obj-code {&attr-overval}  }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-dscnt}  then par-pr-dscnt  =  string( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-notls}  then par-pr-notls  =  string( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-equ-dq} then par-pr-equ-dq =  thbjattr_thbj-attr.property-value-integer .
end.

if par-pr-notls <> "yes" then
  /* проверять не требуется, все ОК */
  return.

ok-dscnt = false  .
for each main-list where
         main-list.doc-num    = d-num and
         main-list.main-price = yes:
  /* находим цену главного кода */
  { gbl/bcodeprc.i
    main-list.obj-type
    main-list.obj-code
    main-list.b-code
    0
    0
    gp-doc-num
    gp-price-sale
    gp-road-tax
    gp-excise
    no-error }
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
      error-status :get-message(1)
      "Ошибка поиска цены главного кода "
      .
      return.

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
         sub-list.doc-num = d-num and
         sub-list.b-code  = old-list.b-code and
         sub-list.price-type = "" no-error.
    if not available sub-list then do:
      if par-pr-equ-dq = 1  then do:
         find first buf_bar-code no-lock where
                    buf_bar-code.b-code = old-list.b-code and
                    buf_bar-code.in-code <> "" no-error .
         find first buf_parts no-lock where
              buf_parts.out-code  = {&free-code} and
              buf_parts.rsrv-free = true  and
              buf_parts.status_   = false and
              buf_parts.obj-type  = main-list.obj-type and
              buf_parts.obj-code  = main-list.obj-code and
              buf_parts.artic     = old-list.artic and
              buf_parts.prod-type = old-list.prod-type and
              buf_parts.prod-code = old-list.prod-code and
              buf_parts.in-code   = buf_bar-code.in-code and
              buf_parts.part-code = buf_bar-code.part-code
              no-error .


      if available buf_bar-code then do:
         if buf_bar-code.in-code <> "" and not available buf_parts then next.
      end.

      message
        "Потеряна по крайней мере одна существующая цена," skip
        "что запрещено настройкой pr-notls." skip (2)
        "Код:" old-list.b-code skip
        "Номер предыдущей переоценки:" gp-doc-num
        view-as alert-box error.
      return error.
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
                v-str1 = substitute("Переоценка. Изменилась по крайней мере одна скидка&4 Товар &5 &6&4 Код: &1&4 Старая скидка: &2 % (переоценка &7)&4 Новая скидка: &3 %" ,
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
                return error v-str1.
          end.
    end.
  end.
end.