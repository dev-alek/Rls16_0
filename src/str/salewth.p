block-level on error undo, throw.
/*

$Revision: 9263cff4388a, 1753, rls $
$Author: SMMolotkov $
$Date: Thu Feb 07 16:50:10 2019 +0300 $
$Workfile: salewth.p $
$Archive: str/salewth.p $

Создание накладных на приход МЦ от клиента РЕАЛИЗАЦИЯ В МАГАЗИНЕ
на объект магазин, которому принадлежит продажа
на МХ МЦ сооответсвующие кассам


Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/21/05
Author: Bakhtadze Natalya
Creation date: 09/21/05

*/

define input parameter parparentproc as widget-handle no-undo .
define parameter buffer loc-inkas for ub.inkas.
/*контрагент релизация в магазине*/
define input parameter parcli-type like ub.wth-doc.cli-type no-undo .
define input parameter parcli-code like ub.wth-doc.cli-code no-undo .
/*номер накладной продажи*/
define input parameter pardoc-code1 like ub.wth-doc.source-ref no-undo .
/*номер накладной возврата*/
define input parameter pardoc-code2 like ub.wth-doc.source-ref no-undo .

define variable vss-revision    as character no-undo init "$Revision: 9263cff4388a, 1753, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 07 16:50:10 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: salewth.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/salewth.p $":U .
define variable vss-description as character no-undo init "Создание накладных на приход МЦ для продажи".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

DEFINE VARIABLE is-wth as logical no-undo .
DEFINE VARIABLE is-dtl as logical no-undo .
DEFINE VARIABLE conf-par as character no-undo .
DEFINE VARIABLE par-type as character no-undo .
DEFINE VARIABLE vardoc-rec as recid no-undo .
DEFINE VARIABLE varline-rec as recid no-undo .
DEFINE VARIABLE varpart-rec as recid no-undo .
DEFINE VARIABLE var-doc-code like ub.wth-doc.doc-code no-undo .
DEFINE VARIABLE var-mes as character no-undo .
DEFINE VARIABLE var-doc-sum like ub.wth-doc.doc-sum no-undo .
DEFINE VARIABLE var-w-p-code like ub.wth-line.w-p-code no-undo .
DEFINE VARIABLE var-wth-code like ub.wth-line.wth-code no-undo .
DEFINE VARIABLE ii as integer no-undo .
define variable v-cashier-psn-code like ub.person.psn-code no-undo .

define buffer locked_wth-doc  for ub.wth-doc .
define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_chk-doc     for ub.chk-doc.
define buffer buf_chk-pay     for ub.chk-pay.
define buffer buf_chk-pay-attr     for ub.chk-pay-attr .
define buffer buf_wth-par     for ub.wth-par.
DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
{ str/ttpardt0.i }
.
DEFINE TEMP-TABLE tt-dtl-line NO-UNDO LIKE ub.wth-par
{ str/ttpardt0.i }
.

define temp-table tt-wth-doc no-undo like ub.wth-doc .
define temp-table tt-wth-line no-undo like ub.wth-line .
define temp-table tt-wth-parts no-undo like ub.wth-parts .

define variable vidn-ser-code  as integer no-undo.
define variable vidn-db-num    like ub.wth-ser.db-num no-undo.
define variable vidn-stts      as integer no-undo.
define variable vidn-wth-code  like ub.wth-parts.wth-code no-undo.
define variable vidn-gds-code  like ub.wth-parts.gds-code no-undo.
define variable vidn-par-code  like ub.wth-parts.par-code no-undo.
define variable vidn-zone      as character no-undo.
define variable vidn-FromDate  as date no-undo.
define variable vidn-ToDate    as date no-undo.
define variable vidn-priceRubl like ub.wth-parts.price-rubl  no-undo.
define variable vidn-priceBase like ub.wth-parts.price-base  no-undo.
define variable vidn-range     like ub.wth-parts.fact-rangeFrom  no-undo.

{ gbl/gbclcode.i }
{ gbl/cur-time.i } /* 21/I-2019 - cur-time.i убрано из gbclcode.i */
{ str/wthparts.i }
/*проверим включены ли МЦ в системе*/

{ gbl/conf-rd.i
"'is-wth'"
0
"''"
0
"''"
"''"
"''"
yes
conf-par
par-type
no-error
}
IF not error-status:error then
assign
is-wth = (conf-par = "yes":U).
if not is-wth then return.

if loc-inkas.obj-type = {&stock} then do:
  var-mes = substitute("&1 &2 &3&4Попытка закрыть продажу на объекте типа склад &5"
                       ,vss-workfile
                       ,vss-revision
                       ,vss-description
                       ,{&new-line}
                       ,loc-inkas.obj-code
                       )
            .
  return error var-mes.
end.

for each tt-wth-doc:
  delete tt-wth-doc.
end.
for each tt-wth-line:
  delete tt-wth-line.
end.

/*проверим реляционные связи и создадим временные таблицы*/
_inkas-pay-desk:
for each ub.inkas-pay-desk no-lock where
         ub.inkas-pay-desk.inkas-code = loc-inkas.inkas-code
BREAK
BY ub.inkas-pay-desk.pay-desk
BY ub.inkas-pay-desk.doc-type
BY ub.inkas-pay-desk.cashier
BY ub.inkas-pay-desk.pay-code
BY ub.inkas-pay-desk.curr-code
        :
  assign var-doc-sum = 0.

  if first-of(ub.inkas-pay-desk.pay-desk) then do:
    /*проверим что касса = это МХ для МЦ*/
    FIND FIRST ub.wth-place No-LOCK WHERE
              ub.wth-place.obj-type = loc-inkas.obj-type AND
              ub.wth-place.obj-code = loc-inkas.obj-code AND
              ub.wth-place.cash-desk = ub.inkas-pay-desk.pay-desk NO-ERROR.
    if not available ub.wth-place then do:
      var-mes = substitute("Не определено МХ МЦ для кассы N &1 &2&3"
                           ,ub.inkas-pay-desk.pay-desk
                           ,loc-inkas.obj-type
                           ,loc-inkas.obj-code).
      return error var-mes.
    end.
    assign
    var-w-p-code = ub.wth-place.w-p-code.
  end. /*first-of(ub.inkas-pay-desk.pay-dec)*/


  /*убедимся что тип кассового платежа есть - на всякий случай*/
  FIND FIRST ub.cash-pay No-LOCK where
            ub.cash-pay.cdpay-code = ub.inkas-pay-desk.pay-code AND
            ub.cash-pay.curr-code = ub.inkas-pay-desk.curr-code No-ERROR.
  if not available ub.cash-pay then do:
    var-mes = substitute("Неверный тип кассового платежа: &1" +
                         "код кассового платежа &2 код валюты &3"
                        ,{&new-line}
                        ,ub.inkas-pay-desk.pay-code
                        ,ub.inkas-pay-desk.curr-code).
    return error var-mes.
  end.

  /*проверим что связь с МЦ правильная*/
  if ub.cash-pay.wth-code <> 0 then do:
    FIND FIRST ub.wealth No-LOCK where
              ub.wealth.wth-code = ub.cash-pay.wth-code No-ERROR.
    if not available ub.wealth then do:
      var-mes = substitute("Неверный код МЦ &1", ub.cash-pay.wth-code).
      return error var-mes.
    end.
    assign
    var-wth-code = ub.cash-pay.wth-code
    .

  end.       /*wth-code <> 0*/

  if first-of(ub.inkas-pay-desk.cashier) then do:
    v-cashier-psn-code = 0.
    assign
    v-cashier-psn-code = gbclcode-is-this-db-role (
                                                   input {&role-cashier}
                                                  ,input g#db-num
                                                  ,input ub.inkas-pay-desk.cashier
                                                  ,input loc-inkas.doc-date
                                                  )
    no-error .
    if v-cashier-psn-code = 0 then do:
        var-mes = substitute("Неверный код кассира &1", ub.inkas-pay-desk.cashier).
        return error var-mes.
    end.
  end. /* if first-of(ub.inkas-pay-desk.cashier) */
  if ub.cash-pay.wth-code = 0 then next _inkas-pay-desk.

  if first-of(ub.inkas-pay-desk.pay-code) then do:
    find first tt-wth-doc where     tt-wth-doc.host-code = loc-inkas.host-code
           and tt-wth-doc.obj-type = loc-inkas.obj-type
           and tt-wth-doc.obj-code = loc-inkas.obj-code
           and tt-wth-doc.cli-type = parcli-type
           and tt-wth-doc.cli-code = parcli-code
           and tt-wth-doc.doc-date = loc-inkas.doc-date
           and tt-wth-doc.fact-date = loc-inkas.fact-date
           and  tt-wth-doc.shift-num = loc-inkas.shift-num
           and  tt-wth-doc.shift-date = (if loc-inkas.shift-num = 0
                                      then ?
                                      else loc-inkas.shift-date)
           and tt-wth-doc.operator = v-cashier-psn-code
           and tt-wth-doc.deliver  = v-cashier-psn-code
           and tt-wth-doc.receiver = v-cashier-psn-code
           and tt-wth-doc.exter_ = yes
           and tt-wth-doc.inter_ = no
           and tt-wth-doc.doc-type = ub.inkas-pay-desk.doc-type
           and tt-wth-doc.source-ref = loc-inkas.inkas-code
           and tt-wth-doc.source-type = {&wthd-cash-desk}
           and tt-wth-doc.ext-doc-type = (if  available ub.wealth and ub.wealth.is-ser = 1 and  tt-wth-doc.doc-type = {&income}
                                        then {&WDEDT_Put_Cash}
                                        else (if  tt-wth-doc.doc-type = {&income}  then  {&wdedt_cas_inc} else {&wdedt_cas_exp}) )

    no-error.
    if available tt-wth-doc and can-find( first tt-wth-line where tt-wth-line.doc-code = tt-wth-doc.doc-code
                          and  tt-wth-line.w-p-code = var-w-p-code)  then do:
      var-doc-code = tt-wth-doc.doc-code.
    end.
    else  do:
      assign
      ii = ii + 1
      var-doc-code = string(ii)
      .

    create tt-wth-doc.
    assign
    tt-wth-doc.doc-code = var-doc-code
    tt-wth-doc.host-code = loc-inkas.host-code
    tt-wth-doc.obj-type = loc-inkas.obj-type
    tt-wth-doc.obj-code = loc-inkas.obj-code
    tt-wth-doc.cli-type = parcli-type
    tt-wth-doc.cli-code = parcli-code
    tt-wth-doc.doc-date = loc-inkas.doc-date
    tt-wth-doc.fact-date = (if  available ub.wealth and ub.wealth.is-ser = 1 and loc-inkas.shift-num <> 0 then loc-inkas.shift-date else loc-inkas.fact-date )  /*Такой костыль вводится для правильного формирования отчетности на сменных объектах*/
    tt-wth-doc.shift-num = loc-inkas.shift-num
    tt-wth-doc.shift-name = loc-inkas.shift-name
    tt-wth-doc.shift-date = (if loc-inkas.shift-num = 0
                             then ?
                             else loc-inkas.shift-date)

    tt-wth-doc.operator = v-cashier-psn-code
    tt-wth-doc.deliver  = v-cashier-psn-code
    tt-wth-doc.receiver = v-cashier-psn-code
    tt-wth-doc.exter_ = yes
    tt-wth-doc.inter_ = no
    tt-wth-doc.doc-type = ub.inkas-pay-desk.doc-type
    tt-wth-doc.source-ref = loc-inkas.inkas-code
    tt-wth-doc.source-type = {&wthd-cash-desk}
    tt-wth-doc.auto-fill = yes
    tt-wth-doc.ps = "@":U + "Накладная" + {&space-char} +
                    (
                    if ub.inkas-pay-desk.doc-type = {&income}
                    then pardoc-code1 /*продажа*/
                    else pardoc-code2 /*возврат*/
                    )
    tt-wth-doc.status_ = {&permitted}
    tt-wth-doc.doc-sum = 0
    tt-wth-doc.fact-sum = 0
    tt-wth-doc.ext-doc-type = (if  available ub.wealth and ub.wealth.is-ser = 1 and  tt-wth-doc.doc-type = {&income}
                               then {&WDEDT_Put_Cash}
                               else (if  tt-wth-doc.doc-type = {&income}  then  {&wdedt_cas_inc} else {&wdedt_cas_exp}) )
    .
       /*   ВОЗВРАТ ТАЛОНОВ ???????????????????????????????????????????????????????????????????????*/
    end.
  end. /* if first-of(ub.inkas-pay-desk.cashier) */
 /* message ii var-doc-code ub.wealth.is-ser tt-wth-doc.ext-doc-type tt-wth-doc.doc-type . */

  find first tt-wth-line no-lock where
             tt-wth-line.doc-code = var-doc-code and
             tt-wth-line.wth-code = var-wth-code and
             tt-wth-line.w-p-code = var-w-p-code no-error .
  if not avail tt-wth-line then do:
    create tt-wth-line.
    assign
    tt-wth-line.doc-code = var-doc-code
    tt-wth-line.wth-code = ub.cash-pay.wth-code
    tt-wth-line.w-p-code = var-w-p-code
    tt-wth-line.out-code = 0
    .
  end.
  if not ub.wealth.is-ser = 1 then
  do:
    assign
     tt-wth-line.doc-sum = tt-wth-line.doc-sum + abs(ub.inkas-pay-desk.tot-sum)
     tt-wth-line.fact-sum = tt-wth-line.fact-sum + abs(ub.inkas-pay-desk.tot-sum)
     var-doc-sum = var-doc-sum + abs(ub.inkas-pay-desk.tot-sum)
     .
     FOR EACH buf_chk-doc NO-LOCK where buf_chk-doc.out-code = ub.inkas-pay-desk.inkas-code
                                       AND buf_chk-doc.pay-desk = ub.inkas-pay-desk.pay-desk
                                       AND buf_chk-doc.cashier  = ub.inkas-pay-desk.cashier,
         EACH buf_chk-pay NO-LOCK where buf_chk-pay.doc-code = buf_chk-doc.doc-code
                               AND  buf_chk-pay.pay-code = ub.inkas-pay-desk.pay-code
                               AND  buf_chk-pay.curr-code = ub.inkas-pay-desk.curr-code,
         FIRST buf_chk-pay-attr NO-LOCK WHERE buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
                                 AND buf_chk-pay-attr.line-num = buf_chk-pay.line-num
                                 AND buf_chk-pay-attr.attr-code = "autotank-sum-return":
     assign
      tt-wth-line.doc-sum = tt-wth-line.doc-sum - deci(buf_chk-pay-attr.attr-value)
      tt-wth-line.fact-sum = tt-wth-line.fact-sum - deci(buf_chk-pay-attr.attr-value)
      var-doc-sum = var-doc-sum - deci(buf_chk-pay-attr.attr-value)
      .
    end.

  end.
   /* Если МЦ серийная то  создаем temp-table для wth-dtl и  партий для указанного талона */

  if ub.wealth.is-ser = 1 then do:
    if not (ub.inkas-pay-desk.doc-type = {&income}  or ub.inkas-pay-desk.doc-type = {&expense}) then next _inkas-pay-desk.
    /*Код талонов определяется из чеков*/
    for each buf_chk-pay no-lock where
              buf_chk-pay.out-code = loc-inkas.inkas-code
              and buf_chk-pay.pay-code = ub.cash-pay.cdpay-code
              and buf_chk-pay.curr-code = ub.cash-pay.curr-code
      , each buf_chk-doc no-lock where
        buf_chk-doc.doc-code = buf_chk-pay.doc-code
        and buf_chk-doc.cashier = ub.inkas-pay-desk.cashier
        and buf_chk-doc.chk-type = (if ub.inkas-pay-desk.doc-type = {&income} then {&bef-rcpt-sale} else int({&rcpt-return}))
            :

          /*  идентифицируем талон */
           var-mes =   substitute("Не удалось идентифицировать штрих-код &4 в продаже &1&2" +
                          "Код кассового платежа &3. Чек № &5. "
                          ,loc-inkas.inkas-code
                          ,{&new-line}
                          ,ub.inkas-pay-desk.pay-code
                          ,buf_chk-pay.pay-card /*"КОД ТАЛОНА"*/
                          ,buf_chk-doc.doc-code
                            ).
          run str/wthidnt.p ( input buf_chk-pay.pay-card /*  "КОД ТАЛОНА" */
                    ,output vidn-ser-code
                    ,output vidn-db-num
                    ,output vidn-stts
                    ,output vidn-wth-code
                    ,output vidn-gds-code
                    ,output vidn-par-code
                    ,output vidn-zone
                    ,output vidn-FromDate
                    ,output vidn-ToDate
    /*                ,output vidn-priceRubl
                    ,output vidn-priceBase   */
                    ,output vidn-range
                    ) no-error.


          if error-status:error then do:
              var-mes = var-mes +  {&new-line} + error-status:get-message(1) + {&space-char} + return-value.
              return error var-mes.
          end.
          if vidn-wth-code <> ub.wealth.wth-code then do:
            var-mes = var-mes + {&new-line} + substitute("Код МЦ &1, идентифицируемый по штрих-коду, не соответствует коду МЦ &2 для указанного типа оплаты",vidn-wth-code,ub.wealth.wth-code).
            return error var-mes.
          end.
          if vidn-zone <> {&cli-zone} then do:
            var-mes = var-mes + {&new-line} + substitute("Зона &1 идентифицируемого штрих-кода не соотвествует зоне {&cli-zone}", vidn-zone).
            return error var-mes.
          end.
          /*после благополучной идентификации создаем врем. таблицы */
                 find first tt-par-dtl no-lock where
                    tt-par-dtl.doc-code = var-doc-code and
                    tt-par-dtl.wth-code = var-wth-code and
                    tt-par-dtl.w-p-code = var-w-p-code and
                    tt-par-dtl.par-code = vidn-par-code no-error .
          if not avail tt-par-dtl then do:
            create tt-par-dtl.
            assign
            tt-par-dtl.doc-code = var-doc-code
            tt-par-dtl.wth-code = ub.cash-pay.wth-code
            tt-par-dtl.w-p-code = var-w-p-code
            tt-par-dtl.par-code = vidn-par-code
            .
            for first buf_wth-par no-lock where buf_wth-par.wth-code = tt-par-dtl.wth-code
                                    and buf_wth-par.par-code = tt-par-dtl.par-code:
              buffer-copy buf_wth-par using par-val
                                            par-unit
                                            par-feat
                                            par-rate
                        to tt-par-dtl.
            end.
          end.

          find first tt-wth-parts where
                    tt-wth-parts.out-code = var-doc-code
                and tt-wth-parts.wth-code = ub.cash-pay.wth-code
                and tt-wth-parts.w-p-code = var-w-p-code
                and tt-wth-parts.par-code = vidn-par-code
                and tt-wth-parts.ser-code = vidn-ser-code
                and tt-wth-parts.db-num   = vidn-db-num
                and tt-wth-parts.fact-rangeFrom = vidn-range
                and tt-wth-parts.fact-rangeTo   = vidn-range   no-error.
          if available tt-wth-parts then do:
                      var-mes = substitute("Обработка платежа серийными МЦ со штрих-кодом &1 в чеке &2.",
                                        buf_chk-pay.pay-card,
                                        buf_chk-doc.doc-code
                                       ) +
                             substitute("&2Данная партия уже существует в документе:&2" +
                            "МЦ &3, Номинал &8, Серия &4-&5, Диапазон: &6-&7."
                            ,loc-inkas.inkas-code
                            ,{&new-line}
                            ,ub.wealth.wth-name
                            ,tt-wth-parts.ser-code
                            ,tt-wth-parts.db-num
                            ,tt-wth-parts.fact-rangeFrom
                            ,tt-wth-parts.fact-rangeTo
                            ,tt-par-dtl.par-val
                            ).

              return error var-mes.
          end.
          create tt-wth-parts.
          assign
          tt-wth-parts.out-code = var-doc-code
          tt-wth-parts.wth-code = ub.cash-pay.wth-code
          tt-wth-parts.w-p-code = var-w-p-code
          tt-wth-parts.par-code = vidn-par-code
          tt-wth-parts.ser-code = vidn-ser-code
          tt-wth-parts.db-num   = vidn-db-num
          tt-wth-parts.fact-rangeFrom = vidn-range
          tt-wth-parts.fact-rangeTo   = vidn-range
          tt-wth-parts.gds-code = vidn-gds-code
          .

    end. /*for each buf_chk-doc*/
  end.   /*is-ser*/
/*  if last-of(ub.inkas-pay-desk.cashier) then do:  */
    find first tt-wth-doc where
               tt-wth-doc.doc-code = var-doc-code.
    assign
    tt-wth-doc.doc-sum = tt-wth-doc.doc-sum + var-doc-sum
    tt-wth-doc.fact-sum = tt-wth-doc.fact-sum + var-doc-sum
    .
    release tt-wth-doc.
 /* end. /*if last-of(ub.inkas-pay-desk.cashier)*/  */

end. /*for each ub.inkas-pay-desk*/

/*пишем в базу согласно временным таблицам*/


_Main-block:
DO ON ERROR UNDO _main-block, return error var-mes:
  _tt-wth-doc:
  for each tt-wth-doc:
    var-mes = substitute("Не удалось создать документ МЦ к продаже &1&2" +
                         "код кассового платежа&3&2код валюты &4&2Касса &5&2&6&2Кассир &7"
                          ,loc-inkas.inkas-code
                         ,{&new-line}
                         ,ub.inkas-pay-desk.pay-code
                         ,ub.inkas-pay-desk.curr-code
                         ,ub.inkas-pay-desk.pay-desk
                         ,(if ub.inkas-pay-desk.doc-type = {&income} then "продажа" else "возврат")
                         ,ub.inkas-pay-desk.cashier).

    /*все строчки лежат во временной таблице tt-wth-line*/
    /*документ лежит во времнной таблице tt-wth-doc*/
    /*создаем в БД*/
    var-doc-code = '':U.
    find first tt-wth-line no-lock where
               tt-wth-line.doc-code = tt-wth-doc.doc-code no-error .
    if not avail tt-wth-line then next _tt-wth-doc.

    run str/wth-inc1.p (  input yes  /*silent*/
                  ,input-output vardoc-rec
                  ,input {&add-def}
                  ,input var-doc-code
                  ,input tt-wth-doc.host-code
                  ,input tt-wth-doc.obj-type
                  ,input tt-wth-doc.obj-code
                  ,input tt-wth-doc.cli-type
                  ,input tt-wth-doc.cli-code
                  ,input tt-wth-doc.doc-date
                  ,input tt-wth-doc.fact-date
                  ,input tt-wth-doc.shift-date
                  ,input tt-wth-doc.shift-num
                  ,input tt-wth-doc.shift-name
                  ,input tt-wth-doc.operator
                  ,input tt-wth-doc.deliver
                  ,input tt-wth-doc.receiver
                  ,input tt-wth-doc.doc-type
                  ,input tt-wth-doc.auto-fill
                  ,input tt-wth-doc.exter_
                  ,input tt-wth-doc.inter_
                  ,input tt-wth-doc.source-ref
                  ,input tt-wth-doc.source-type
                  ,input tt-wth-doc.borned
                  ,input /*tt-wth-doc.doc-sum*/  0
                  ,input /*tt-wth-doc.fact-sum*/ 0
                  ,input tt-wth-doc.ps
                  ,input {&doc-froze}
                  ,input no /*parlines-exist*/
                  ,input tt-wth-doc.ext-doc-type
                  ) no-error .
    if error-status:error then do:
      var-mes = substitute("&1&2&3&2&4"
                          ,var-mes
                          ,{&new-line}
                          ,error-status:get-message(1)
                          ,return-value ).
      return error var-mes.
    end.
    find first ub.wth-doc no-LOCK WHERE
               recid(ub.wth-doc) = vardoc-rec No-ERROR.
    if not avail ub.wth-doc then do:
      return error var-mes.
    end.
    assign
    var-doc-code = ub.wth-doc.doc-code
    .

    for each tt-wth-line where
             tt-wth-line.doc-code = tt-wth-doc.doc-code:
      tt-wth-line.doc-code =  var-doc-code.
      empty temp-table tt-dtl-line.
      is-dtl = no.
      for each tt-par-dtl where           /*Резервирование партий*/
              tt-par-dtl.doc-code = tt-wth-doc.doc-code
          and tt-par-dtl.wth-code = tt-wth-line.wth-code:
          create tt-dtl-line.
          buffer-copy tt-par-dtl to tt-dtl-line
          assign tt-dtl-line.doc-code = var-doc-code.
          for each tt-wth-parts where
                tt-wth-parts.out-code = tt-wth-doc.doc-code and
                tt-wth-parts.wth-code = tt-par-dtl.wth-code and
                tt-wth-parts.w-p-code = tt-par-dtl.w-p-code and
                tt-wth-parts.par-code = tt-par-dtl.par-code:

                var-mes = substitute("Не удалось зарезервировать партию  в продаже &1&2" +
                          "Код МЦ &3 Серия: код &4 №БД &5 Диапазон: &6-&7"
                          ,loc-inkas.inkas-code
                          ,{&new-line}
                          ,tt-wth-parts.wth-code
                          ,tt-wth-parts.ser-code
                          ,tt-wth-parts.db-num
                          ,tt-wth-parts.fact-rangeFrom
                          ,tt-wth-parts.fact-rangeTo
                          ).
                varpart-rec = ?.
                RUN wth-parts-rezerv ( no
                            ,tt-wth-parts.fact-rangeFrom
                            , tt-wth-parts.fact-RangeTo
                            , ?
                            , ?
                            , tt-wth-parts.ser-code
                            , tt-wth-parts.db-num
                            , 0
                            , 0
                            , 0
                            , ub.wth-doc.host-code
                            , ub.wth-doc.obj-type
                            , ub.wth-doc.obj-code
                            , tt-wth-parts.w-p-code
                            , tt-wth-parts.wth-code
                            , tt-wth-parts.par-code
                            , '':U
                            , var-doc-code
                            , '':U
                            , 0
                            , ub.wth-doc.ext-doc-type
                            , tt-wth-parts.gds-code
                            , ub.wth-doc.doc-type
                            ,INPUT-OUTPUT varpart-rec
                            ) no-error .
                if error-status:error then do:
                  var-mes = var-mes + {&new-line} + error-status:get-message(1) + {&space-char} + return-value.
                  undo _main-block, return error var-mes.
                end.
          end.
        { str/dtlsum.i tt-dtl-line buf_wth-parts }  /* расчет сумм */


        is-dtl = yes.
      end.
      if is-dtl then do:
        { str/wthlnsum.i tt-wth-line tt-dtl-line}
      end.
      run str/wth-lnc1.p (
                    input-output varline-rec,
                    input  {&add-def},
                    no,
                    var-doc-code,
                    tt-wth-line.wth-code,
                    tt-wth-line.w-p-code,
                    0,
                    tt-wth-line.doc-sum,
                    tt-wth-line.fact-sum,
                    input table tt-dtl-line,
                    no, /*par-log*/
                    input tt-wth-doc.ext-doc-type
                    ,tt-wth-line.sum-gds-rubl
                    ,tt-wth-line.sum-gds-base
                    ) no-error .
      if error-status:error then do:
        var-mes = var-mes + {&new-line} + error-status:get-message(1) + {&space-char} + return-value.
        undo _main-block, return error var-mes.
      end.
    end.
    find first locked_wth-doc EXCLUSIVE-LOCK WHERE
               recid(locked_wth-doc) = vardoc-rec No-ERROR.
    if not avail locked_wth-doc then do:
      undo _main-block, return error var-mes.
    end.
    find first locked_wth-doc exclusive-LOCK WHERE
               recid(locked_wth-doc) = vardoc-rec No-ERROR.
    if not avail locked_wth-doc then do:
      return error var-mes.
    end.
    assign
    locked_wth-doc.status_ = {&permitted}
    .
    run str/wth-stts.p ( input parparentproc,
                   BUFFER locked_wth-doc,
                   INPUT "+":U,
                   INPUT no,
                   INPUT tt-wth-doc.obj-type,
                   INPUT tt-wth-doc.obj-code,
                   input 'clswdoc.txt':U  ) NO-ERROR.
    if error-status:error then do:
      var-mes = var-mes + {&new-line} + error-status:get-message(1) + {&space-char} + return-value.
      undo _main-block, return error var-mes.
    end.
    release locked_wth-doc no-error.
    if error-status:error then do:
      var-mes = var-mes + {&new-line} + error-status:get-message(1) + {&space-char} + return-value.
      undo _main-block, return error var-mes.
    end.
  end. /*for each tt-wht-doc*/
END. /*DO IN ERROR   */