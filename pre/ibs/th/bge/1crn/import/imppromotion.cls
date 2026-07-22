using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects.
using ibs.th.bge.1crn.subjects.promotion.
using ibs.th.ref.promo.enum-type-discount .
using ibs.th.ref.promo.enum-promo-status .
using ibs.th.ref.promo.enum-sched-status .
block-level on error undo, throw.
class ibs.th.bge.1crn.import.imppromotion implements ibs.th.bge.1crn.import.iimpsubject:
  // &h-create, &delim-key, &delim-par
  define property Msg as character no-undo
    get.
    set.
  define private variable parparentproc   as handle no-undo .
  define private variable p-parent-handle as handle no-undo .
  define private variable p-log-handle    as handle no-undo .
  method public void setParent (
  input parparentproc   as handle
, input p-parent-handle as handle
, input p-log-handle    as handle
  ) :
    assign
      this-object:parparentproc   = parparentproc
      this-object:p-parent-handle = p-parent-handle
      this-object:p-log-handle    = p-log-handle
    .
  end method .
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objImp   as class promotion no-undo.
    define variable v-retfl  as logical no-undo .
    define variable v-i-num          as integer no-undo .
    define variable v-i-counter      as integer no-undo .
    define variable v-j-num          as integer no-undo .
    define variable v-j-counter      as integer no-undo .
    define variable v-stub           as integer no-undo .
    define variable v-schedule       as class ibs.th.bge.1crn.subjects.promotion_schedule no-undo .
    define variable v-objlist1       as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:schedule:sched-lines[]
    define variable v-sched-line     as class ibs.th.bge.1crn.subjects.promotion_schedule-line no-undo .
    define variable v-objlist2       as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:thresholds[]
    define variable v-threshold      as class ibs.th.bge.1crn.subjects.promotion_threshold no-undo .
    define variable v-objlist3       as class ibs.th.bge.1crn.subjects.subjects no-undo . // :gifts[{gd-code,gd-qnty}]
    define variable v-gift-gd        as class ibs.th.bge.1crn.subjects.promotion_gift-gd no-undo .
    define variable v-objlist4       as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:gds[]
    define variable v-gds-gd         as class ibs.th.bge.1crn.subjects.promotion_gds-gd no-undo .
    define variable v-objlist5       as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:gds-addcond[]
    define variable v-addcond-gd     as class ibs.th.bge.1crn.subjects.promotion_gd no-undo .
    define variable v-promoset       as class ibs.th.bge.1crn.subjects.promotion_promoset no-undo .
 // define variable v-objlist6       as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp: запасной
    define variable v-objlist7       as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:promoset:ps-sections[]
    define variable v-ps-section     as class ibs.th.bge.1crn.subjects.promotion_ps-section no-undo .
    define variable v-objlist8       as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:promoset:ps-sections:ps-section:gds[]
    define variable v-promoset-gd    as class ibs.th.bge.1crn.subjects.promotion_gd no-undo .
    define variable v-objlist9       as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:gifts[]
    define variable v-PaymentSystems as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:payment-systems[]
    define variable v-PaymentSystem  as class ibs.th.bge.1crn.subjects.payment-system no-undo . // imp:payment-systems:payment-system[]
    define variable v-bins-tokens    as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:payment-systems:payment-system:bins-tokens[]
    define variable v-bin-token      as class ibs.th.bge.1crn.subjects.bin-token no-undo . // imp:payment-systems:payment-system:bins-tokens:bin-token[]
    define variable v-promotion-code as character no-undo .
    define variable v-schedule-code  as character no-undo .
    define variable v-promo-delete   as class ibs.th.ref.promo.promoactionsub no-undo .
    define variable v-promo-action   as class ibs.th.ref.promo.promoactionsub no-undo .
    define variable v-promo-sched    as class ibs.th.ref.promo.promoSchedsub no-undo .
    define variable v-promo-schdws   as class ibs.th.ref.promo.promoSchedwsubs no-undo .
    define variable v-promo-schdw    as class ibs.th.ref.promo.promoSchedwsub no-undo .
    define variable v-promo-crits    as class ibs.th.ref.promo.promoCriterionsubs no-undo .
    define variable v-promo-crit     as class ibs.th.ref.promo.promoCriterionsub no-undo .
    define variable v-promo-gifts    as class ibs.th.ref.promo.promoGiftsubs no-undo .
    define variable v-promo-gift     as class ibs.th.ref.promo.promoGiftsub no-undo .
    define variable v-promo-goods    as class ibs.th.ref.promo.promogoodssubs no-undo .
    define variable v-pssec-goods    as class ibs.th.ref.promo.promogoodssubs no-undo .
    define variable v-promo-good     as class ibs.th.ref.promo.promogoodssub no-undo .
    define variable v-pssec-good     as class ibs.th.ref.promo.promogoodssub no-undo .
    define variable v-promo-objs     as class ibs.th.ref.promo.promoObjectsubs no-undo .
    define variable v-promo-obj      as class ibs.th.ref.promo.promoObjectsub no-undo .
    define variable v-gds-code as integer no-undo .
    define variable v-obj-type as character no-undo .
    define variable v-obj-code as integer no-undo .
    define variable v-db-num   as integer no-undo .
    define variable v-message  as logical no-undo .
    define variable v-storage        as class ibs.th.gbl.storage.promoactionstorage no-undo .
    define buffer buf_PromoAction for ub.PromoAction .
    define buffer buf_PromoSched  for ub.promo-schedule .
    define buffer buf_goods       for ub.goods .
    define buffer buf_clients     for ub.clients .
    define buffer buf_goods-attr  for ub.goods-attr .
    define buffer buf_PromoAttr   for ub.PromoAttr .
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
    define variable v-ban-recipes as logical no-undo init false.
    objImp = cast (subjectObj, promotion).
    assign
      v-promotion-code = objImp:code_
      Msg              = "":U
    .
    if v-promotion-code > "" then . else undo, throw new Progress.Lang.AppError("Не задан ид. промо-акции") .
    if objImp:del-f > 0 then do:
      Msg = "физическое удаление промо-акций не предусмотрено".
      v-retfl = false .
      return false.
    end.
    if objImp:del-l > 0 then do:
      Msg = "Логическое удаление промо-акций не предусмотрено. Акцию завершает досрочное погашение.".
      v-retfl = false .
      return false.
    end.
    v-promo-action = new ibs.th.ref.promo.promoactionsub () .
    v-promo-action:refreshChildObj(). // - создаёт пустые экземпляры всех дочерних объектов
    v-promo-action:ext-code = v-promotion-code .
do: // заголок промо-акции
    find first buf_PromoAction no-lock where buf_PromoAction.ext-code = v-promotion-code no-error .
    if available buf_PromoAction then do:
      v-promo-delete = new ibs.th.ref.promo.promoactionsub () .
      assign
        v-promo-delete:ID     = buf_PromoAction.id
        v-promo-delete:db-num = buf_PromoAction.db-num
        v-promo-delete:promosched-id = buf_PromoAction.promosched-id
        v-promo-action:ID     = buf_PromoAction.id
      .
    end .
    else do:
      assign
        // v-promo-action:Mode        = {&h-create}
      .
    end .
      assign
        v-promo-action:beg-date    = objImp:strt-date
        v-promo-action:end-date    = objImp:end-date
        v-promo-action:changeDate  = objImp:earlyend-day
        v-promo-action:NameAction  = objImp:name_
     // обработка enum при взаимодействии со справочниками реализована в обход
     // v-promo-action:TypeDiscont = objImp:dscnt-type
        v-promo-action:TypeDiscontenum = if objImp:dscnt-value-type eq 8 then enum-type-discount:enVISA else objImp:dscnt-type
        v-promo-action:methodCalc      = if objImp:dscnt-value-type eq 8 then 7                         else objImp:dscnt-value-type
     // v-promo-action:status_     = getPromoStatus(objImp:status_)
        v-promo-action:status_enum = getPromoStatus(objImp:status_)
        v-promo-action:priority    = objImp:priority
        v-promo-action:comment     = objImp:comment
        v-promo-action:description = objImp:description_
     // v-promo-action:paymenttype = objImp:pmnt-types
        v-promo-action:paymenttype = replace(objImp:pmnt-types, ",",chr(3) + "0" + chr(4)) +  chr(3)+ "0"
        .
      if available (buf_PromoAction) and (buf_PromoAction.beg-date <> v-promo-action:beg-date or buf_PromoAction.end-date <> v-promo-action:end-date) then do:
         v-message = true .
      end.
define variable v-txt-typedisc      as character extent 2 no-undo initial ["временная скидка", "промо-набор"] .
define variable v-txt-method-calc   as character extent 7 no-undo initial ["Скидка процентом", "Абсолютная (скидка суммой от цены)", "Скидка количеством", "Скидка процентом за количество", "Фиксированная цена", "Выдача сообщения", "Подарок"] .
define variable v-txt-dscnt-type    as character extent 7 no-undo initial ["процентная", "абсолютная", "натуральная", "процентная за количество", "фиксированная цена", "Выдача сообщения,подарок"] .
define variable v-txt-thresholdtype as character extent 4 no-undo initial ["Количество по строке", "Сумма по строке", "Итог чека", "Скидка по ШК"] .
// "Количество по строке,Сумма по строке[,Сумма в документе]"
define variable v-txt-error         as character no-undo .
    v-txt-error = "" .
    case v-promo-action:TypeDiscontenum :
      when enum-type-discount:ensolo then do:
        case v-promo-action:methodCalc:
          when 1 then do: // 1 – процентная
            if not can-do("1,2,3,4", string(objImp:threshold-type)) then
              v-txt-error = substitute(
              "Для типа скидки [&1] и значения [&2] вид условия должен быть [&3], [&4], [&5] или [&6]",
              v-txt-typedisc[v-promo-action:TypeDiscontenum:GetValue()],
              v-txt-method-calc[v-promo-action:methodCalc],
              v-txt-thresholdtype[1],
              v-txt-thresholdtype[2],
              v-txt-thresholdtype[3],
              v-txt-thresholdtype[4]
            ) .
          end .
          when 2 then do: // 2 – абсолютная
            if not can-do("1,2,4", string(objImp:threshold-type)) then
              v-txt-error = substitute(
              "Для типа скидки [&1] и значения [&2] вид условия должен быть [&3], [&4] или [&5]",
              v-txt-typedisc[v-promo-action:TypeDiscontenum:GetValue()],
              v-txt-method-calc[v-promo-action:methodCalc],
              v-txt-thresholdtype[1],
              v-txt-thresholdtype[2],
              v-txt-thresholdtype[4]
            ) .
          end .
          when 5 then do: // 5 – фиксированная
            if not can-do("4", string(objImp:threshold-type)) then
              v-txt-error = substitute(
              "Для типа скидки [&1] и значения [&2] вид условия должен быть [&3]",
              v-txt-typedisc[v-promo-action:TypeDiscontenum:GetValue()],
              v-txt-method-calc[v-promo-action:methodCalc],
              v-txt-thresholdtype[4]
            ) .
          end .
          when 6 or when 7 then do: // 1 – процентная, 6 – Выдача сообщения, 7 – подарок
            if not can-do("1,2,3", string(objImp:threshold-type)) then
              v-txt-error = substitute(
              "Для типа скидки [&1] и значения [&2] вид условия должен быть [&3], [&4] или [&5]",
              v-txt-typedisc[v-promo-action:TypeDiscontenum:GetValue()],
              v-txt-method-calc[v-promo-action:methodCalc],
              v-txt-thresholdtype[1],
              v-txt-thresholdtype[2],
              v-txt-thresholdtype[3]
            ) .
          end .
          otherwise do:
            if objImp:threshold-type > 0 then
              v-txt-error = substitute(
              "Для типа скидки [&1] и значения [&2] вид условия не применяется",
              v-txt-typedisc[v-promo-action:TypeDiscontenum:GetValue()],
              v-txt-method-calc[v-promo-action:methodCalc]
            ) .
          end.
        end case .
      end . // end_of_ensolo
      when enum-type-discount:encombo then do:
        if objImp:threshold-type > 0 then
          v-txt-error = substitute(
          "Для типа скидки [&1] вид условия не применяется",
          v-txt-typedisc[v-promo-action:TypeDiscontenum:GetValue()]
        ) .
      end. // end_of_encombo
      when enum-type-discount:enVISA then do:
      END.
      otherwise v-txt-error = substitute("Тип скидки [&1] не поддерживается.", v-promo-action:TypeDiscontenum:GetValue()) .
    end case .
     v-promo-action:typecond = objImp:threshold-type .
end. // end_of заголовок_промоакции
    // вложенные объекты &impclass
    assign
      v-schedule = objImp:schedule
      v-objlist2 = objImp:thresholds
      v-objlist4 = objImp:gds
      v-objlist5 = objImp:gds-addcond
      v-promoset = objImp:promoset
      v-objlist9 = objImp:gifts
      v-PaymentSystems = objImp:Payment-Systems
    .
do: // объекты
    v-obj-type = 'маг':U.
    v-db-num   = ibs.th.gbl.gbl-var:g#db-num .
    find first buf_clients no-lock
         where buf_clients.db-num   = v-db-num
           and buf_clients.obj-type = v-obj-type no-error .
    v-obj-code = if available buf_clients then buf_clients.obj-code else v-db-num .
    v-promo-obj  = new ibs.th.ref.promo.promoObjectsub () .
    assign
      v-promo-obj:obj-type = v-obj-type
      v-promo-obj:obj-code = v-obj-code
      v-promo-obj:end-date = v-promo-action:end-date
      v-promo-obj:Mode     = 'с':U
    .
    v-promo-objs = v-promo-action:Objects .
    v-promo-objs:AddItem (v-promo-obj) .
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-obj-type, v-obj-code):IsBanRecipes then v-ban-recipes = true .
end . // end_of объекты
if valid-object (v-schedule) then do: // schedule - расписание
    v-promo-sched  = new ibs.th.ref.promo.promoSchedsub () .
    assign
      v-schedule-code            = v-schedule:sch-code
      v-promo-sched:Mode         = 'с':U
      v-promo-sched:extCodeSched = v-schedule-code
   // v-promo-sched:status_      = getSchedStatus (v-promo-action:status_)
      v-promo-sched:status_      = getSchedStatus (v-promo-action:status_enum) // обработка enum при взаимодействии со справочниками реализована в обход
    .
        assign
          v-promo-sched:dispname  = v-schedule:sch-name
          v-promo-sched:schedType = integer(v-schedule:Sch-type)
          v-objlist1              = v-schedule:schedule-lines
        .
    v-promo-action:Schedule     = v-promo-sched .
    if valid-object(v-objlist1) then do : // schedule-lines - дни расписания
      v-promo-schdws = v-promo-action:ScheduleWeek . // создаётся пустая коллекция дней расписания
      v-i-counter = v-objlist1:iCounter .
      do v-i-num = 1 to v-i-counter :
        v-stub = v-objlist1:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
        v-sched-line = cast(v-objlist1:SubjectObjCurr, ibs.th.bge.1crn.subjects.promotion_schedule-line) .
        v-promo-schdw = new ibs.th.ref.promo.promoSchedwsub () .
        assign
          v-promo-schdw:wdaylist = v-sched-line:day_
          v-promo-schdw:timebeg  = parseTime(v-sched-line:strt-time)
          v-promo-schdw:timeend  = parseTime(v-sched-line:end-time)
          v-promo-schdw:Mode     = v-promo-sched:Mode
        .
        v-promo-schdws:AddItem (v-promo-schdw) .
      end. // end_of_objImp:schedule:sched-lines[]
    end . // end_of дни расписания
end. // end_of расписание
else do :
    v-promo-sched  = new ibs.th.ref.promo.promoSchedsub () .
    assign
      v-promo-sched:Mode         = 'с':U
      v-promo-sched:status_      = getSchedStatus (v-promo-action:status_enum) // обработка enum при взаимодействии со справочниками реализована в обход
      v-promo-sched:dispname     = "Расписание для акции " + string(v-promo-action:ID)
      v-promo-sched:schedType    = 0
    .
    v-promo-action:Schedule     = v-promo-sched .
    v-promo-schdws = v-promo-action:ScheduleWeek . // создаётся пустая коллекция дней расписания
    v-promo-schdw = new ibs.th.ref.promo.promoSchedwsub () .
    assign
       v-promo-schdw:wdaylist = "0"
       v-promo-schdw:timebeg  = 0
       v-promo-schdw:timeend  = 86399
       v-promo-schdw:Mode     = 'с':U
    .
    v-promo-schdws:AddItem (v-promo-schdw) .
end.
if valid-object(v-objlist2) then do: // threshold - пороговые значения
    define variable valueupto as decimal no-undo init 0 .
    define variable logupto as logical no-undo .
    define variable valuemin  as decimal no-undo init 0 .
    v-promo-crits = v-promo-action:Criterion .
    v-i-counter = v-objlist2:iCounter .
    do v-i-num = 1 to v-i-counter :
      if logupto then leave .
      else do:
      v-stub = v-objlist2:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
      v-threshold = cast(v-objlist2:SubjectObjCurr, ibs.th.bge.1crn.subjects.promotion_threshold) .
      v-promo-crit = new ibs.th.ref.promo.promoCriterionsub () .
      v-promo-crit:refreshChildObj().
      if v-threshold:value_ = ? then valuemin = 0 .
      else valuemin = v-threshold:value_ .
      valueupto = v-threshold:valueupto .
      assign
        v-promo-crit:mincrit = valuemin
        v-promo-crit:maxcrit = v-threshold:valueupto
        v-promo-crit:discont = v-threshold:dscnt
        v-promo-crit:Mode    = 'с':U
        v-promo-gifts        = v-promo-crit:Gifts
      .
      if v-threshold:message_ <> ? then do:
        v-promo-gift = new ibs.th.ref.promo.promoGiftsub () .
        assign
          v-promo-gift:mess = v-threshold:message_
          v-promo-gift:Mode = v-promo-crit:Mode
        .
        v-promo-gifts:AddItem (v-promo-gift) .
      end .
      if v-threshold:message-gks <> ? then do:
        v-promo-gift = new ibs.th.ref.promo.promoGiftsub () .
        assign
          v-promo-gift:mess-gks = v-threshold:message-gks
          v-promo-gift:Mode = v-promo-crit:Mode
        .
        v-promo-gifts:AddItem (v-promo-gift) .
      end .
      v-objlist3 = v-threshold:Gifts .
      if valid-object(v-objlist3) then do :
        v-j-counter = v-objlist3:iCounter .
        do v-j-num = 1 to v-j-counter :
          v-stub = v-objlist3:Get(v-j-num) .
          v-gift-gd = cast(v-objlist3:SubjectObjCurr, ibs.th.bge.1crn.subjects.promotion_gift-gd) .
          assign
            v-promo-gift = new ibs.th.ref.promo.promoGiftsub ()
            v-gds-code   = integer(v-gift-gd:gd-code)
          .
          if not can-find (first buf_goods where buf_goods.gds-code = v-gds-code) then
          undo, throw new Progress.Lang.AppError( substitute(
            "Код товара [&1] из промо-акции [&2] отсутствует в справочнике товаров."
            , v-gds-code, objImp:name_
          ) ) .
          assign
            v-promo-gift:GdsCode = v-gds-code
            v-promo-gift:qnty    = v-gift-gd:gd-qnty
            v-promo-gift:Mode    = v-promo-crit:Mode
          .
          if v-ban-recipes then do:
            if can-find (first buf_goods-attr no-lock where buf_goods-attr.gds-code = v-promo-gift:GdsCode and
               buf_goods-attr.attr-code = 'mark-type':U and buf_goods-attr.attr-value <> "not-type" and
               buf_goods-attr.attr-value <> "") then
            do:
               v-promo-action:end-date = today - 1 .
               v-promo-action:status_ = 2 .
            end.
          end.
          v-promo-gifts:AddItem (v-promo-gift) .
        end . // end_of_threshold:gifts[]
      end .
      v-promo-crits:AddItem (v-promo-crit) .
      end.
   end. // end_of_objImp:thresholds[]
//    v-promo-action:Criterion = v-promo-crits .
end. // end_of_threshold
if valid-object(v-objlist4) then do: // gds - объекты акции
    v-promo-goods = v-promo-action:GoodsAppl .
    v-i-counter = v-objlist4:iCounter .
    do v-i-num = 1 to v-i-counter :
      v-stub = v-objlist4:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
      v-gds-gd = cast(v-objlist4:SubjectObjCurr, ibs.th.bge.1crn.subjects.promotion_gds-gd) .
      assign
        v-promo-good = new ibs.th.ref.promo.promogoodssub ()
        v-gds-code   = integer(v-gds-gd:gd-code)
      .
      if not can-find (first buf_goods where buf_goods.gds-code = v-gds-code) then
      undo, throw new Progress.Lang.AppError( substitute(
        "Код товара [&1] из промо-акции [&2] отсутствует в справочнике товаров."
        , v-gds-code, objImp:name_
      ) ) .
      assign
        v-promo-good:GdsCode = v-gds-code
        v-promo-good:price   = v-gds-gd:gd-price
        v-promo-good:promotion-code = v-gds-gd:promotion-code
        v-promo-good:Mode    = 'с':U
      .
      v-promo-goods:AddItem (v-promo-good) .
    end . // end_of_objImp:gds[]
end. // end_of_gds
if valid-object(v-objlist5) then do: // gds-addcond - товары для независимых условий
   v-promo-goods = v-promo-action:GoodsCrits .
   v-i-counter = v-objlist5:iCounter .
   do v-i-num = 1 to v-i-counter :
      v-stub = v-objlist5:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
      v-addcond-gd = cast(v-objlist5:SubjectObjCurr, ibs.th.bge.1crn.subjects.promotion_gd) .
      assign
         v-promo-good = new ibs.th.ref.promo.promogoodssub ()
         v-gds-code   = integer(v-addcond-gd:gd-code)
      .
      if not can-find (first buf_goods where buf_goods.gds-code = v-gds-code) then
         undo, throw new Progress.Lang.AppError( substitute(
           "Код товара [&1] из промо-акции [&2] отсутствует в справочнике товаров."
           , v-gds-code, objImp:name_
        ) ) .
      assign
         v-promo-good:GdsCode = v-gds-code
         v-promo-good:Mode    = 'с':U
      .
      v-promo-goods:AddItem (v-promo-good) .
   end . // end_of_objImp:gds-addcond[]
end. // end_of_gds-addcond
if valid-object(v-paymentsystems) then do: // gds-addcond - товары для независимых условий
   v-promo-goods = v-promo-action:CardsBin.
   v-i-counter = v-paymentsystems:iCounter .
   do v-i-num = 1 to v-i-counter :
      v-stub = v-paymentsystems:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
      v-paymentsystem = cast(v-paymentsystems:SubjectObjCurr, ibs.th.bge.1crn.subjects.payment-system) .
      v-bins-tokens = v-paymentsystem:bins-tokens.
      v-j-counter = v-bins-tokens:iCounter .
      do v-j-num = 1 to v-j-counter :
         v-stub = v-bins-tokens:Get(v-j-num) .
         v-bin-token = cast(v-bins-tokens:SubjectObjCurr, ibs.th.bge.1crn.subjects.bin-token) .
         assign
           v-promo-good = new ibs.th.ref.promo.promogoodssub ()
           v-promo-good:NameSet = v-bin-token:code_
           v-promo-good:Mode    = 'с':U
         .
         v-promo-goods:AddItem (v-promo-good) .
      end . // end_of_objImp:gds-addcond[]
   end.
end.
if valid-object(v-promoset) then do: // promoset - промо-набор
    v-promo-crits = v-promo-action:Criterion .
    v-promo-crit = new ibs.th.ref.promo.promoCriterionsub () .
    assign
      v-promo-crit:discont = v-promoset:ps-Price
      v-promo-crit:Mode    = 'с':U
    .
    v-promo-crits:AddItem (v-promo-crit) .
    v-promo-goods = v-promo-action:PromoSet .
    v-objlist7 = v-promoset:ps-sections .
    v-i-counter = v-objlist7:iCounter .
    do v-i-num = 1 to v-i-counter :
      v-stub = v-objlist7:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
      v-ps-section = cast(v-objlist7:SubjectObjCurr, ibs.th.bge.1crn.subjects.promotion_ps-section) .
      v-promo-good = new ibs.th.ref.promo.promogoodssub () .
      v-objlist8 = v-ps-section:gds .
      if valid-object(v-objlist8) then do:
        v-promo-good:refreshChildObj() .
        v-pssec-goods = v-promo-good:promoSetGoods. // ibs.th.ref.promo.promogoodssubs = пустая коллекция для промо-набора
        v-j-counter = v-objlist8:iCounter .
        do v-j-num = 1 to v-j-counter :
          v-stub = v-objlist8:Get(v-j-num) .
          v-promoset-gd = cast(v-objlist8:SubjectObjCurr, ibs.th.bge.1crn.subjects.promotion_gd) .
          assign
            v-pssec-good = new ibs.th.ref.promo.promogoodssub ()
            v-gds-code   = integer(v-promoset-gd:gd-code)
          .
          if not can-find (first buf_goods where buf_goods.gds-code = v-gds-code) then
          undo, throw new Progress.Lang.AppError( substitute(
            "Код товара [&1] из промо-акции [&2] отсутствует в справочнике товаров."
            , v-gds-code, objImp:name_
          ) ) .
          assign
            v-pssec-good:GdsCode = v-gds-code
            v-pssec-good:Mode    = v-promo-crit:Mode
          .
          v-pssec-goods:AddItem (v-pssec-good) .
        end . // end_of_promoset:ps-section:gds[]
      end .
      assign
        v-promo-good:NameSet = v-ps-section:ps-name
        v-promo-good:qnty    = v-ps-section:ps-amount
        v-promo-good:price   = v-ps-section:ps-discount
        v-promo-good:Mode    = v-promo-crit:Mode
      .
      v-promo-goods:AddItem (v-promo-good) .
    end. // end_of_objImp:Promoset[]
end. // end_of_promoset
if valid-object (v-objlist9) then do: // gifts - подарки на всю акцию
    v-promo-gifts = v-promo-action:gifts .
    v-i-counter = v-objlist9:iCounter .
    do v-i-num = 1 to v-i-counter :
      v-stub = v-objlist9:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
      v-gift-gd = cast(v-objlist9:SubjectObjCurr, ibs.th.bge.1crn.subjects.promotion_gift-gd) .
      assign
        v-promo-gift = new ibs.th.ref.promo.promoGiftsub ()
        v-gds-code   = integer(v-gift-gd:gd-code)
      .
      if not can-find (first buf_goods where buf_goods.gds-code = v-gds-code) then
      undo, throw new Progress.Lang.AppError( substitute(
        "Код товара [&1] из промо-акции [&2] отсутствует в справочнике товаров."
        , v-gds-code, objImp:name_
      ) ) .
      assign
        v-promo-gift:GdsCode = v-gds-code
        v-promo-gift:qnty    = v-gift-gd:gd-qnty
        v-promo-gift:Mode    = 'с':U
      .
   if v-ban-recipes then do:
   if can-find (first buf_goods-attr no-lock where buf_goods-attr.gds-code = v-promo-gift:GdsCode and
      buf_goods-attr.attr-code = 'mark-type':U and buf_goods-attr.attr-value <> "not-type" and
      buf_goods-attr.attr-value <> "") then
   do:
      v-promo-action:end-date = today - 1 .
      v-promo-action:status_ = 2 .
   end.
   end.
      v-promo-gifts:AddItem (v-promo-gift) .
    end . // end_of_gifts[]
end. // end_of_gifts
    v-storage = new ibs.th.gbl.storage.promoactionstorage () .
    // если прочитанная акция ранее присутствовала в БД - сначала удаляем её, затем - создаём;
    // если прочитанная акция пришла впервые - создаём её как новую
    if valid-object(v-promo-delete)
    then do:
       define variable mStorsed as class ibs.th.gbl.storage.promoSchedstorage NO-UNDO.
       mstorsed = new ibs.th.gbl.storage.promoSchedstorage().
       v-promo-delete:refreshChildObj().
       mstorsed:deleteDB(v-promo-delete:Schedule) .
       delete object  mStorsed.
       v-storage:deleteDB(v-promo-delete) .
    end.
    v-storage:insertDB(v-promo-action) .
        find first buf_PromoAttr exclusive-lock  where
        buf_PromoAttr.attr-code = "charge-BL" and
        buf_promoAttr.tablename = "PromoPay" and
        v-promo-action:ID = int64(entry(1,buf_PromoAttr.p-key,chr(3))) and
        v-db-num = integer(entry(2,buf_PromoAttr.p-key,chr(3))) no-error .
        if not available (buf_PromoAttr) then do:
    create buf_promoAttr.
    assign
      buf_promoAttr.attr-code  = "charge-BL"
      buf_promoAttr.tablename  = "PromoPay"
      buf_promoAttr.p-key      = string(v-promo-action:ID) + chr(3) +
                          string(v-db-num)
    no-error .
        end.
        buf_PromoAttr.attr-value  = if objImp:prohibition-charge-BL = 1 then string(true) else string(false)
        .
    define variable mDelCd as logical no-undo.
    mDelCd =
              (v-promo-action:changeDate <> ?
           and v-promo-action:changeDate <= today)
            or  v-promo-action:end-date  < today
            or  v-promo-action:status_enum = enum-promo-status:encompleted.
    if v-message then
    do:
       create ub.PromoAttr .
       assign
           ub.PromoAttr.tablename  = "PromoAction"
           ub.PromoAttr.p-key      = string(v-promo-action:ID) + chr(3) + string(v-promo-action:db-num)
           ub.PromoAttr.attr-code  = "promo-message"
           ub.PromoAttr.attr-value = "Внимание!!! Перезагрузите кассу, для обновления промоакций!"
           .
    end.
    define variable mImp2CdH as handle no-undo.
    run str/imp2cdgeth.p(output mImp2CdH).
    if v-promo-action:status_enum = enum-promo-status:encompleted or (v-promo-action:status_enum = enum-promo-status:enactive and v-promo-action:changeDate <> ?) then
    do:
      run fill-PromoAction in mImp2CdH (v-promo-action:ID, v-promo-action:db-num).
    end.
    v-retfl = true .
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg = "" then Msg = exAppErrors:GetMessage(1) .
      v-retfl = false.
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) .
      v-retfl = false.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error occurred..." .
      v-retfl = false.
      undo, throw exAnyErrors .
    end catch .
    finally :
      if valid-object(v-storage)      then delete object v-storage .
      if valid-object(v-promo-delete) then delete object v-promo-delete .
      if valid-object(v-promo-action) then delete object v-promo-action .
      return v-retfl.
    end finally .
  end method.
  method private enum-promo-status getPromoStatus (input p-status as integer):
    define variable v-promo-status as enum-promo-status no-undo .
    case p-status:
      when 0 then // 0 – настройки в работе. Присылать из 1С если акция была сохранена, но потом опять переведена в настройки
        v-promo-status = enum-promo-status:ensetting .
      when 1 then // 1 – настройки выполнены
        v-promo-status = enum-promo-status:enactive .
      when 2 then // 2 – акция заблокирована (при досрочном погашении или другом виде удаления\блокировки акции)
        v-promo-status = enum-promo-status:encompleted .
    end case .
    return v-promo-status .
  end method. // end_of getPromoStatus
  method private enum-sched-status getSchedStatus (input p-promo-status as enum-promo-status) :
    define variable v-sched-status as enum-sched-status no-undo .
    case p-promo-status:
      when enum-promo-status:ensetting then
        v-sched-status = enum-sched-status:ensetting .
      when enum-promo-status:enactive or
      when enum-promo-status:encompleted then
        v-sched-status = enum-sched-status:enactive .
    end case .
    return v-sched-status .
  end method. // end_of getSchedStatus
  method private integer parseTime (input p-time-str as character):
    define variable v-time as integer no-undo .
      v-time = integer(substring(p-time-str, 1, 2)) * 3600 +
               integer(substring(p-time-str, 4, 2)) * 60 +
               integer(substring(p-time-str, 7, 2)) .
    return v-time.
  end method. // end_of parseTime
end class.
