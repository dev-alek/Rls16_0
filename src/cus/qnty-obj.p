block-level on error undo, throw.
/*

$Revision: 2a79bf27b012, 291, rls $
$Author: ASMorozov $
$Date: Tue Dec 01 19:11:26 2015 +0300 $
$Workfile: qnty-obj.p $
$Archive: cus/qnty-obj.p $

Предпологанмое значение заказа - interface по объектам  .

Автор: Чернова Светлана Александровна
Дата создания: 02/01/02
Author: Svetlana Chernova
Creation date: 02/01/02


раздельный подсчет заказа по obj-list для ФП

*/
define temp-table temp-dates no-undo
field exch-date as date
index pi is unique primary   exch-date
.
define temp-table temp-abc-day no-undo
field abc-type as character
field gar-day  as decimal
index pi abc-type
.

define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-round-m       as character no-undo .
define input parameter p-round-base    as decimal   no-undo .
define input  parameter p-e-method    as character no-undo .
define input  parameter p-mode-calc as character no-undo .
define input  parameter p-ord-doc   as character no-undo .
define input  parameter xdate-1     as date no-undo .      /* Период расчета темпа продаж */
define input  parameter xdate-2     as date no-undo .
define input  parameter t-action    as character no-undo . /* if t-action = "calc":u then есть вопрос об изменении qnty */
define input  parameter var#import  as logical  no-undo .  /* var#import = да -  если был импорт пересчитывать не надо */
define input  parameter p-r-algoritm as integer no-undo . /* Метод расчета 1 2 3 */
define input  parameter p-type-qnty-day as integer no-undo . /* количество дней 1 2 3  */
define input  parameter p-r-min-rest as integer no-undo . /* Параметры товара 1  */
define input  parameter p-r-min-rest3 as logical no-undo . /* Тип минимального остатка  = сезонный */
define input  parameter p-code     as character no-undo  .   /* Номер списка готовых темпов продаж */
define input  parameter p-t-rv     as logical no-undo .   /* что входит в продажу */
define input  parameter p-t-rvz    as logical no-undo .
define input  parameter p-t-rvc    as logical no-undo .
define input  parameter p-t-rvzc   as logical no-undo .
define input  parameter p-t-sp     as logical no-undo .
define input  parameter p-t-sppv   as logical no-undo .
define input  parameter p-t-sppv-2 as logical no-undo .
define input  parameter p-t-sppv-3 as logical no-undo .
define input  parameter p-t-sppv-4 as logical no-undo .
define input  parameter p-t-way    as logical no-undo .
define input  parameter p-t-rcv    as logical no-undo .
define input  parameter p-t-clos    as logical no-undo .
define input  parameter table for  temp-dates.
define input  parameter table for  temp-abc-day.            /* таблица с днями продаж по АВС  */
define input  parameter p-neg-sale as logical no-undo .
define input  parameter p-t-gar       as logical no-undo .       /* остаток > гар.запаса */
define input  parameter p-t-min-zapas as logical no-undo . /* заказ < мин.заказа */
define input  parameter p-t-min-ost  as logical no-undo .  /* остаток > мин остатка */
define input  parameter p-t-deadline  as logical no-undo .  /* заказ и срок хранения */
define input  parameter store-type    as character no-undo .
define input  parameter store-code    as integer   no-undo .
define input  parameter g#type        as character no-undo .
define input  parameter p-tog-det-prizn as logical no-undo .     /* детализировать по признакам */


define variable vss-revision    as character no-undo init "$Revision: 2a79bf27b012, 291, rls $":u .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":u .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:26 2015 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: qnty-obj.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/qnty-obj.p $":u .
define variable vss-description as character no-undo init "Предпологаемое значение заказа" .
{ cmp/vssrevis.i   }
{ cmp/trg-def.i    }
{ cmp/r-page1.i    }
{ cus/df-zakaz.i   }
{ cus/z-qnty.i def }
{ ref/gdsoattr.i   }
{ gbl/normobr.i    }
{ trg/prdoclib.i   }
{ gbl/dtm.i        }
{ cus/qnty-lib.i   }
{ cus/df-ex-za.i   }
{ cmp/library.i    }
{ ref/gdspoatr.i   }

define variable g#log as logical   no-undo .
define variable  fact-order-1   like ub.stk-tot.fact-order no-undo.
define variable  fact-order-2   like ub.stk-tot.fact-order no-undo.
define variable  fact-order-today   like ub.stk-tot.fact-order no-undo.
define variable v-ex-date as date   no-undo .
define variable i-date    as integer   no-undo .
define variable i-date-start as integer   no-undo .
define variable i-date-to    as integer   no-undo .
define variable ret-day as date no-undo .

define variable  ostatok-goods  like ub.stk-tot.fact-qnty  init 0 no-undo.
define variable  coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r     like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v     like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  prih        like ub.stk-tot.sum-rubl   no-undo.
define variable  rash        like ub.stk-tot.sum-rubl   no-undo.
define variable  kassa       like ub.stk-tot.sum-rubl   no-undo.
define variable l-new-zakaz as decimal init 0 no-undo .
define variable l-action    as logical no-undo init false .
define variable sum-qnty    like  ub.doc-line.fact-qnty init 0 no-undo.
define variable sum-ost     like  ub.doc-line.fact-qnty init 0 no-undo.
define variable all-day     as int init 0 no-undo.
define variable l-qnty-qnty as integer no-undo .
define variable date-today as date no-undo .

define variable v-prih like ub.stk-tot.sum-rubl   no-undo.
define variable v-rash like ub.stk-tot.sum-rubl   no-undo.
define variable v-kassa like ub.stk-tot.sum-rubl   no-undo.
define variable d-prih like ub.stk-tot.sum-rubl   no-undo.
define variable d-rash like ub.stk-tot.sum-rubl   no-undo.
define variable d-kassa like ub.stk-tot.sum-rubl   no-undo.

define variable loc-sum-min as decimal no-undo .
define variable t-type as character no-undo .

define variable v-gds-way as decimal no-undo .
define variable v-gds-way-all as decimal no-undo .

define variable sum-kv-raz as decimal no-undo .
define temp-table temp-rash no-undo
field tt-ostatok as decimal
field tt-rash as decimal
field tt-date as date
index by-date tt-date
.
define variable v-grop-max-stock as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-obj-AssMin as logical   no-undo .
define variable v-obj-igt     as character no-undo .
define variable loc-obj-type  as character no-undo .
define variable loc-obj-code  as integer   no-undo .
define variable loc-host-code  as integer   no-undo .

define variable v-code       like ub.gds-obj-prop-attr.attr-code  no-undo .
define variable v-obj-type   like ub.gds-obj-prop-attr.obj-type   no-undo .
define variable v-obj-code   like ub.gds-obj-prop-attr.obj-code   no-undo .
define variable v-value      like ub.gds-obj-prop-attr.attr-value no-undo .
define variable v-type       as character no-undo .
define variable v-corr-coeff as decimal   no-undo .

define variable old-pay-day as integer   no-undo .
old-pay-day = pay-day.

define variable v-sum-qnty-prt as decimal no-undo .

define buffer buf_season for ub.season.
define buffer buf_season-attr for ub.season-attr.
define buffer buf_gds-season for ub.gds-season.
define buffer buf_gds-season-attr for ub.gds-season-attr.

if p-mode-calc = ? then p-mode-calc = "" .
for each temp-rash :  delete temp-rash. end.

{ cus/obqntypr.i  }
{ cmp/df-sub.i pr }

 date-today = to-day .
 l-qnty-qnty = (loc-date-ship - date-today).
if l-qnty-qnty = ? then l-qnty-qnty  = 0 .

 run qnty-lib-clear-tt in this-procedure .
if not can-find (first obj-list) then do:
message "Не задан ни один объект для расчета" view-as alert-box error .
return.
end.

 if l-qnty-qnty < 0  then do:
    message "Заказ не может быть рассчитан. Разница Даты заказа и текущей даты " l-qnty-qnty " дней !" view-as alert-box error .
    return.
 end.

assign l-action = true .
if p-mode-calc = ""  then do: /*  расчет */
    if  var#import = true   then do:
      message "Данные были введены через ИМПОРТ , делать изменения количества заказа ?" view-as alert-box question
        buttons
        ok-cancel update g#log.
        if g#log = false then return.
        var#import = false.
        end.

    if t-action = "calc":u then do:
      message
       "Пересчитать заказ в соответствии с новыми параметрами расчета ?" skip
       "В результате пересчета количество заказа может измениться."
        view-as alert-box question
        buttons
        ok-cancel update g#log.
        l-action = g#log .
        end.
end.
else do:
  var#import = false  .
  l-action = true .
end.

if  var#import = false  then do:

  IF p-type-qnty-day = 1 Then do:
    all-day = xdate-2 - xdate-1  + 1.
  end.

  IF p-type-qnty-day = 3 Then do:
    all-day = 0 .
    for each temp-dates :
        all-day = all-day  + 1.
    end.
  end.

run calcitog in this-procedure no-error .


define variable kk as integer no-undo .
define variable Quantity  as decimal no-undo .
/*-----------------------------------------------------------------------------------------------------------------------*/
for each export-ras :
 delete export-ras.
end.
for each tmp#zakaz :
    /*  Остатки на today  */
      assign
          prih  = 0
          rash  = 0
          kassa = 0
          ostatok-goods = 0
          loc-sum-min = 0
          v-gds-way-all       = 0
          l-null-day = 0
        .

    if p-mode-calc = ""  then do: /*  расчет */
      assign
          tmp#zakaz.min-stock = 0
          tmp#zakaz.qnty      = 0
          .
         if not can-find (first temp-abc-day) then tmp#zakaz.temp-rash = 0 .
    end.

/*-----------------------------------------------------------------------------------------------------------------------*/
for each obj-list :
run qnty-lib-clear-tt in this-procedure .
{ gbl/hostcode.i obj-list.obj-type obj-list.obj-code loc-host-code }
      assign
          prih  = 0
          rash  = 0
          kassa = 0
          ostatok-goods = 0
          loc-sum-min = 0
          v-gds-way = 0
          .
  if p-mode-calc <> ""  then do: /*  расчет */
    create export-ras.
    BUFFER-COPY tmp#zakaz to export-ras
    assign
        export-ras.obj-code = obj-list.obj-code
        export-ras.obj-type = obj-list.obj-type
        export-ras.min-stock = 0
        export-ras.qnty      = 0

    .
  end.
  else do:
   assign
    tmp#zakaz.min-stock = 0
   no-error .
   if not can-find (first temp-abc-day) then tmp#zakaz.temp-rash = 0 .
  end.
  /* товар заказан и в пути */
  run goods-way in this-procedure  ( input obj-list.obj-type , input obj-list.obj-code , output  v-gds-way ) .
  v-gds-way-all = v-gds-way-all + v-gds-way .
  rash  = 0 .
  kassa = 0 .
  prih = 0 .

  IF p-type-qnty-day = 2 Then do:
    all-day = xdate-2 - xdate-1  + 1 .
    l-null-day = 0 .
        run qnty-lib-clear-tt in this-procedure .
        run qnty-lib-create-tt in this-procedure
            ( input  integer(xdate-1)   ,
              input  fact-order-2       ,
              input  tmp#zakaz.gds-code ,
              input  obj-list.obj-type  ,
              input  obj-list.obj-code  )
              .
    run qnty-lib-2 in this-procedure .
    run calc-null-day in this-procedure .
    if p-r-algoritm <> 1 then  run calc-sale in this-procedure .
end.

        assign
          loc-obj-type = obj-list.obj-type
          loc-obj-code = obj-list.obj-code
        .
            { gbl/gdsobjpr.i
                  loc-obj-type
                  loc-obj-code
                  ?
                  ?
                  ?
                  tmp#zakaz.gds-code
                  v-obj-AssMin
                  v-obj-igt
                  loc-sum-min
                  v-grop-max-stock
                  v-grop-level-always-presence
                  v-grop-min-order
                  no-error
                  }
                    if error-status :error then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      ""
                      view-as alert-box error
                    .
                    end.
                 if loc-sum-min                  = ? then  loc-sum-min                   = 0 .
                 if v-grop-max-stock             = ? then  v-grop-max-stock              = 0 .
                 if v-grop-level-always-presence = ? then  v-grop-level-always-presence  = 0 .
                 if v-grop-min-order             = ? then  v-grop-min-order              = 0 .

                if p-R-min-rest3 = false  then do:  /* не сезон */
                    /* МИНИМАЛЬНЫЙ ЗАПАС */
                    if p-mode-calc = ""  then do: /*  расчет */
                      tmp#zakaz.min-stock =   loc-sum-min  .
                    end.
                    else do:
                      export-ras.min-stock =  loc-sum-min .
                    end.
                end.
                else do:
                  if p-mode-calc = ""  then do: /*  расчет */
                     loc-sum-min = 0 .
                     tmp#zakaz.min-stock = 0 .
                  end.
                  else do:
                    loc-sum-min = 0 .
                    export-ras.min-stock = 0 .
                  end.
                end.

                /* Максимальный остаток */
                if p-mode-calc = ""  then do: /*  расчет */
                   tmp#zakaz.max-stock =  (if  v-grop-max-stock <> ? then  v-grop-max-stock else 0 ) .
                end.
                else do:
                   export-ras.max-stock =  (if  v-grop-max-stock <> ? then  v-grop-max-stock else 0 ) .
                end.

              /* уровень прис */
              if p-mode-calc = ""  then do: /*  расчет */
                 tmp#zakaz.service-order = v-grop-level-always-presence .
              end.
              else do:
                 export-ras.service-order = v-grop-level-always-presence .
              end.

              /* Минимальный заказ */
              if p-mode-calc = ""  then do: /*  расчет */
                tmp#zakaz.min-order = v-grop-min-order.
              end.
              else do:
                export-ras.min-order =v-grop-min-order.
              end.


    if p-R-min-rest3 then do:  /* сезон */

      for each buf_season no-lock where 
                  buf_season.sea-month-1 <= integer (DATE-sale-2) and
                  buf_season.sea-month-2 >= integer (DATE-sale-1):
        find first buf_season-attr where buf_season-attr.sea-code = buf_season.sea-code
          and buf_season-attr.db-num = buf_season.db-num
          and buf_season-attr.attr-code = {&seaattr-obj}
          and buf_season-attr.attr-value = obj-list.obj-type + string (obj-list.obj-code) no-error.

        find first buf_gds-season no-lock where
          buf_gds-season.gds-code = tmp#zakaz.gds-code and
          buf_gds-season.sea-code = buf_season.sea-code and
          buf_gds-season.db-num   = buf_season.db-num
            no-error .
        if available buf_season-attr and available buf_gds-season 
        then do:
          find first buf_gds-season-attr no-lock where buf_gds-season-attr.sea-code = buf_gds-season.sea-code
            and buf_gds-season-attr.db-num = buf_gds-season.db-num
            and buf_gds-season-attr.gds-code = buf_gds-season.gds-code
            and buf_gds-season-attr.attr-code = {&gdsseaattr-season-coef}
              no-error .
          if available buf_gds-season-attr then tmp#zakaz.season-coef = decimal (buf_gds-season-attr.attr-value).
          if p-mode-calc = ""  then tmp#zakaz.min-stock = buf_gds-season.min-stock .
                     else export-ras.min-stock = buf_gds-season.min-stock .
          leave.
              end.
        else do:
          if available buf_gds-season then do:
            find first buf_gds-season-attr no-lock where buf_gds-season-attr.sea-code = buf_gds-season.sea-code
              and buf_gds-season-attr.db-num = buf_gds-season.db-num
              and buf_gds-season-attr.gds-code = buf_gds-season.gds-code
              and buf_gds-season-attr.attr-code = {&gdsseaattr-season-coef}
              no-error.
            if available buf_gds-season-attr then tmp#zakaz.season-coef = decimal (buf_gds-season-attr.attr-value).
            if p-mode-calc = ""  then tmp#zakaz.min-stock = buf_gds-season.min-stock .
               else export-ras.min-stock = buf_gds-season.min-stock .
          end.
        end.
      end.
      if tmp#zakaz.season-coef = ? or tmp#zakaz.season-coef = 0 then assign tmp#zakaz.season-coef = 1.
      
    end.

/* ОСТАТОК НА СЕГОДНЯ */
      for each gds-obj no-lock where gds-obj.artic     = tmp#zakaz.artic      and
                                    gds-obj.prod-code = tmp#zakaz.prod-code   and
                                    gds-obj.prod-type = tmp#zakaz.prod-type   and
                                    gds-obj.obj-code  = obj-list.obj-code     and
                                    gds-obj.obj-type  = obj-list.obj-type     :
          ostatok-goods = ostatok-goods + gds-obj.fact-qnty  .
      end.

/* РАСЧЕТ ТЕМПА */
  v-rash  = 0 .
  v-kassa = 0 .
 /* 555 */

  if p-r-algoritm = 3 then do:
  /* методы расчета  3  */
          d-rash  = 0 .
          d-kassa = 0 .
          IF p-type-qnty-day = 1  Then do:
                run qnty-lib-clear-tt.
                    run qnty-lib-create-tt
                        ( input  integer(xdate-1)   ,
                          input  fact-order-2       ,
                          input  tmp#zakaz.gds-code ,
                          input  obj-list.obj-type  ,
                          input  obj-list.obj-code  )
                          .
                run qnty-lib-2.
                run calc-sale
                .
          end.
          IF p-type-qnty-day = 3   then do :
              run qnty-lib-clear-tt.
              for each temp-dates no-lock :
                d-rash  = 0 .
                d-kassa = 0 .
                  run ob-line (
                      input   obj-list.obj-code   ,
                      input   obj-list.obj-type   ,
                      input   tmp#zakaz.artic       ,
                      input   tmp#zakaz.prod-code   ,
                      input   tmp#zakaz.prod-type   ,
                      input    integer(temp-dates.exch-date)    ,
                      input    integer(temp-dates.exch-date)  + 0.99  ,
                      input   {&arh-cost}    ,
                      input   {&root-cat-id} ,
                      input   ""    ,
                      input   false ,
                      input   false ,
                      output v-prih ,
                      output v-rash ,
                      output v-kassa
                      )  no-error .
                    assign
                      d-rash  = d-rash  + v-rash
                      d-kassa = d-kassa + v-kassa
                      prih    = prih    + v-prih
                      rash    = rash    + v-rash
                      kassa   = kassa   + v-kassa
                    .
                    if  d-rash + d-kassa <> 0  then
                        run create-temp-rash ( temp-dates.exch-date , d-rash + d-kassa ) .
              end.
          end.
  end. /* 3 */

  if p-r-algoritm = 4 then do:
  /* методы расчета  ПО МАКС ПРОДАЖЕ  */
          d-rash  = 0 .
          d-kassa = 0 .

          if p-type-qnty-day = 1  then do:
              i-date-start = integer(xdate-1) .
              i-date-to    = integer(xdate-2) .
              run qnty-lib-clear-tt.
              repeat  i-date = i-date-start to i-date-to :
                d-rash  = 0 .
                d-kassa = 0 .
                  run ob-line (
                      input   obj-list.obj-code   ,
                      input   obj-list.obj-type   ,
                      input   tmp#zakaz.artic       ,
                      input   tmp#zakaz.prod-code   ,
                      input   tmp#zakaz.prod-type   ,
                      input   i-date    ,
                      input   i-date  + 0.99  ,
                      input   {&arh-cost}    ,
                      input   {&root-cat-id} ,
                      input   ""    ,
                      input   false ,
                      input   false ,
                      output v-prih ,
                      output v-rash ,
                      output v-kassa
                      )  no-error .
                    assign
                      d-rash  = d-rash  + v-rash
                      d-kassa = d-kassa + v-kassa
                      prih    = prih    + v-prih
                      rash    = rash    + v-rash
                      kassa   = kassa   + v-kassa
                    .
                    if  d-rash + d-kassa <> 0  then
                        run create-temp-rash ( date(i-date) , d-rash + d-kassa ) .
              end.
          end.

          IF p-type-qnty-day = 3   then do :
              run qnty-lib-clear-tt.
              for each temp-dates no-lock :
                  d-rash  = 0 .
                  d-kassa = 0 .
                  run ob-line (
                      input   obj-list.obj-code   ,
                      input   obj-list.obj-type   ,
                      input   tmp#zakaz.artic       ,
                      input   tmp#zakaz.prod-code   ,
                      input   tmp#zakaz.prod-type   ,
                      input    integer(temp-dates.exch-date)    ,
                      input    integer(temp-dates.exch-date)  + 0.99  ,
                      input   {&arh-cost}    ,
                      input   {&root-cat-id} ,
                      input   ""    ,
                      input   false ,
                      input   false ,
                      output v-prih ,
                      output v-rash ,
                      output v-kassa
                      )  no-error .
                    assign
                      d-rash  = d-rash  + v-rash
                      d-kassa = d-kassa + v-kassa
                      prih    = prih    + v-prih
                      rash    = rash    + v-rash
                      kassa   = kassa   + v-kassa
                    .
                    if  d-rash + d-kassa <> 0  then
                        run create-temp-rash ( temp-dates.exch-date , d-rash + d-kassa ) .
              end.
          end.
  end. /* 4 */

 IF p-r-algoritm = 1  Then do:
      IF p-type-qnty-day <> 3  Then do:
        /* Приход  Расход  за период */
          run ob-line in this-procedure (
              input   obj-list.obj-code   ,
              input   obj-list.obj-type   ,
              input   tmp#zakaz.artic       ,
              input   tmp#zakaz.prod-code   ,
              input   tmp#zakaz.prod-type   ,
              input   fact-order-1   ,
              input   fact-order-2   ,
              input   {&arh-cost}    ,
              input   {&root-cat-id} ,
              input   ""    ,
              input   false ,
              input  p-tog-det-prizn ,
              output v-prih ,
              output v-rash ,
              output v-kassa
              )  no-error .
            assign
              rash  = rash  + v-rash
              kassa = kassa + v-kassa
              prih = prih + v-prih
            .
      end.
      IF p-type-qnty-day = 3 Then do:
                    /* Приход  Расход  за интервалы */
                     run qnty-lib-clear-tt.
                    for each temp-dates no-lock :
                          run ob-line in this-procedure (
                              input   obj-list.obj-code   ,
                              input   obj-list.obj-type   ,
                              input tmp#zakaz.artic     ,
                              input tmp#zakaz.prod-code ,
                              input tmp#zakaz.prod-type ,
                              input integer(temp-dates.exch-date)         ,
                              input integer(temp-dates.exch-date) + 0.99  ,
                              input {&arh-cost}    ,
                              input {&root-cat-id} ,
                              input ""    ,
                              input false ,
                              input  p-tog-det-prizn ,
                              output v-prih ,
                              output v-rash ,
                              output v-kassa
                              )          no-error .
                            assign
                              rash  = rash  + v-rash
                              kassa = kassa + v-kassa
                              prih  = prih  + v-prih
                            .
                        run create-temp-rash in this-procedure ( temp-dates.exch-date , v-rash + v-kassa ) .
                    end.
      end.
end.
   if p-mode-calc = ""  then do: /*  расчет */
    assign
        tmp#zakaz.qnty-kassa  = kassa
        tmp#zakaz.qnty-prih   = prih
        tmp#zakaz.qnty-rash   = rash
        tmp#zakaz.qnty-stk    = ostatok-goods                /* остаток на today for obj-list */
        tmp#zakaz.qnty-sale   = (rash + kassa)              /* объем продаж за период    */
      .
   end.
   else do:
    assign
        export-ras.qnty-kassa  = kassa
        export-ras.qnty-prih   = prih
        export-ras.qnty-rash   = rash
        export-ras.qnty-stk    = ostatok-goods                /* остаток на today for obj-list */
        export-ras.qnty-sale   = (rash + kassa)              /* объем продаж за период    */
      .

   end.


/* темп расхода в день       */
    IF p-r-algoritm <> 2 Then do :
        if p-mode-calc = ""  then do:
              assign
                  tmp#zakaz.temp-rash       = (rash + kassa) / ( all-day - l-null-day)
                  tmp#zakaz.all-day       =  ( all-day - l-null-day)
                  tmp#zakaz.zero-day       =   l-null-day
                  .
                  if tmp#zakaz.temp-rash = ? then tmp#zakaz.temp-rash = 0 .
        end.
        else do:
        assign
            export-ras.temp-rash  = (rash + kassa) / ( all-day - l-null-day)
            export-ras.all-day  =  ( all-day - l-null-day)
            export-ras.zero-day  =  l-null-day
            .
            if export-ras.temp-rash = ? then export-ras.temp-rash = 0 .
        end.
    end.

    else do: /* 2  из списка */
            if can-find (first temp-abc-day) then do: /*  Значит это ABC */
              if p-mode-calc <> ""  then assign  export-ras.temp-rash = tmp#zakaz.temp-rash.
        end.
        else do:
            find first ub.tmp-sale-gds where
                      ub.tmp-sale-gds.artic     = tmp#zakaz.artic     and
                      ub.tmp-sale-gds.prod-code = tmp#zakaz.prod-code and
                      ub.tmp-sale-gds.prod-type = tmp#zakaz.prod-type and
                      ub.tmp-sale-gds.tmp-code  = p-code no-lock no-error .
            if available ub.tmp-sale-gds then do:
                if p-mode-calc = ""  then assign  tmp#zakaz.temp-rash  = ub.tmp-sale-gds.tmp-value .
                                     else assign  export-ras.temp-rash = ub.tmp-sale-gds.tmp-value .
            end.
      end.
    end.
/*    run gdspoatr-value in this-procedure ( input  {&attr-corrcoeff-po}*/
/*                                          ,input  tmp#zakaz.gds-code  */
/*                                          ,input  obj-list.obj-type   */
/*                                          ,input  obj-list.obj-code   */
/*                                          ,output v-value             */
/*                                          ,output v-type              */
/*                                          ) no-error .                */
    assign v-corr-coeff = tmp#zakaz.season-coef.
    if v-corr-coeff = 0 then v-corr-coeff = 1.

/* Изменение количества дней продаж по АВС, если он есть------------------------------------------------------------ */
find first temp-abc-day where
           temp-abc-day.abc-type  = chr(int(tmp#zakaz.add-cli-qnty)) no-error .
if available  temp-abc-day then do:
   pay-day = temp-abc-day.gar-day .
end.
else  pay-day = old-pay-day .

/*  Предполагаемое значение заказа  --------------------------------------------------------------------------------*/
define variable p-l-max0   as decimal no-undo . /* пустышка */
define variable p-l-max    as decimal no-undo .
define variable t-cli-qnty as decimal   no-undo .
define variable t-sum-cli  as decimal   no-undo .
define variable t-sum-rubl as decimal   no-undo .
define variable t-sum-base as decimal   no-undo .


          if l-action = true  then do :
             if p-mode-calc = ""  then do:
                if tmp#zakaz.temp-rash = ? then tmp#zakaz.temp-rash = 0 .
                end.
             else do:
                if export-ras.temp-rash = ? then export-ras.temp-rash = 0 .
                end.

             case  p-r-algoritm :
               when 1  or when 2 then do : /* Метод расчета заказа базовый  */
                   run z-qnty in this-procedure .
                   run z-qnty-e in this-procedure .
               end.
               when 3 then do :            /* Метод расчета заказа вероятностный  */
                   run v-qnty in this-procedure .
                   run v-qnty-e in this-procedure .
               end.

               when 4 then do :             /* Метод расчета по мак продажам  */
                   run m-qnty   in this-procedure  (output p-l-max0).
                   run m-qnty-e in this-procedure  (output p-l-max).
               end.
               when 5 then do :            /* Довести до максимального остатка  */
                   run u-qnty in this-procedure .
                   run u-qnty-e in this-procedure .
               end.


             end case.



            if p-mode-calc = ""  then do:
                 assign
                    t-cli-qnty  =  l-new-zakaz / tmp#zakaz.cli-base-rate
                    t-sum-cli   =  tmp#zakaz.price-cli  * t-cli-qnty
                    t-sum-rubl  =  tmp#zakaz.price-rubl * l-new-zakaz
                    t-sum-base  =  tmp#zakaz.price-base * l-new-zakaz
                  .
                      run recalc-cli-qnty (
                           input        tmp#zakaz.gds-code
                          ,input        p-round-m
                          ,input        p-round-base
                          ,input        tmp#zakaz.unit-cli
                          ,input        tmp#zakaz.cli-base-rate
                          ,input        tmp#zakaz.price-cli
                          ,input        tmp#zakaz.price-rubl
                          ,input        tmp#zakaz.price-base
                          ,input-output t-cli-qnty
                          ,input-output l-new-zakaz
                          ,input-output t-sum-cli
                          ,input-output t-sum-rubl
                          ,input-output t-sum-base ) .

            assign
                tmp#zakaz.qnty     = tmp#zakaz.qnty +  l-new-zakaz
                tmp#zakaz.cli-qnty = tmp#zakaz.qnty / tmp#zakaz.cli-base-rate
                tmp#zakaz.sum-cli  = tmp#zakaz.price-cli * tmp#zakaz.cli-qnty
                tmp#zakaz.sum-rubl = tmp#zakaz.price-rubl * tmp#zakaz.qnty
                tmp#zakaz.sum-base = tmp#zakaz.price-base * tmp#zakaz.qnty
            .
            run create-obj-temp in this-procedure (
                    input p-ord-doc ,
                    input tmp#zakaz.gds-code ,
                    input obj-list.obj-type ,
                    input obj-list.obj-code ,
                    input l-new-zakaz
                    ) .
            end .
            else do:
                 assign
                    t-cli-qnty  =  l-new-zakaz / tmp#zakaz.cli-base-rate
                    t-sum-cli   =  export-ras.price-cli  * t-cli-qnty
                    t-sum-rubl  =  export-ras.price-rubl * l-new-zakaz
                    t-sum-base  =  export-ras.price-base * l-new-zakaz
                  .
                      run recalc-cli-qnty (
                           input        export-ras.gds-code
                          ,input        p-round-m
                          ,input        p-round-base
                          ,input        export-ras.unit-cli
                          ,input        export-ras.cli-base-rate
                          ,input        export-ras.price-cli
                          ,input        export-ras.price-rubl
                          ,input        export-ras.price-base
                          ,input-output t-cli-qnty
                          ,input-output l-new-zakaz
                          ,input-output t-sum-cli
                          ,input-output t-sum-rubl
                          ,input-output t-sum-base
                          ).

            assign
                export-ras.qnty     = if l-new-zakaz <> ? then l-new-zakaz else 0
                export-ras.cli-qnty = export-ras.qnty / export-ras.cli-base-rate
                export-ras.sum-cli  = export-ras.price-cli  * export-ras.cli-qnty
                export-ras.sum-rubl = export-ras.price-rubl * export-ras.qnty
                export-ras.sum-base = export-ras.price-base * export-ras.qnty
                export-ras.ostatok-today = export-ras.qnty-stk
                export-ras.gds-way-all   = v-gds-way
                export-ras.Temp-rash = ( if export-ras.Temp-rash <> ?  then export-ras.Temp-rash
                                                                                 else 0 )
            .
            end.
            run create-protocol in this-procedure
            (  input p-ord-doc
              ,input tmp#zakaz.gds-code
              ,input v-protocol-date
              ,input v-protocol-time
              ,input obj-list.obj-type
              ,input obj-list.obj-code
              ,input v-stroka-protocol
              ).
            if p-mode-calc = ""  then do:
              tmp#zakaz.order-qnty = tmp#zakaz.qnty.
              tmp#zakaz.initial-qnty = tmp#zakaz.qnty.
              end.
              else do:
              /*export-ras.order-qnty = tmp#zakaz.qnty.*/
              export-ras.initial-qnty = tmp#zakaz.qnty.
              export-ras.Temp-rash = ( if export-ras.Temp-rash <> ?  then export-ras.Temp-rash  else 0 )  .
              if p-r-algoritm = 4 then  export-ras.temp-rash = p-l-max .
              end.
              for each temp-rash :  delete temp-rash. end.
          end.
    end.

    if p-tog-det-prizn then do :
      for each export-ras :
        v-sum-qnty-prt = 0.
        for each tmp#zakaz-prn where tmp#zakaz-prn.artic     = export-ras.artic     and
                                     tmp#zakaz-prn.prod-type = export-ras.prod-type and
                                     tmp#zakaz-prn.prod-code = export-ras.prod-code and
                                     tmp#zakaz-prn.obj-type  = export-ras.obj-type  and
                                     tmp#zakaz-prn.obj-code  = export-ras.obj-code  no-lock
        :
          assign
            tmp#zakaz-prn.qnty-ord = round((export-ras.qnty * (tmp#zakaz-prn.qnty-sale / export-ras.qnty-sale)), 0)
            v-sum-qnty-prt = v-sum-qnty-prt + tmp#zakaz-prn.qnty-ord
          .
          if tmp#zakaz-prn.qnty-ord = ? then tmp#zakaz-prn.qnty-ord = 0 .
        end.  /*   for each tmp#zakaz-prn  */
        for each tmp#zakaz-prn where tmp#zakaz-prn.artic     = export-ras.artic     and
                                     tmp#zakaz-prn.prod-type = export-ras.prod-type and
                                     tmp#zakaz-prn.prod-code = export-ras.prod-code and
                                     tmp#zakaz-prn.obj-type  = export-ras.obj-type  and
                                     tmp#zakaz-prn.obj-code  = export-ras.obj-code  no-lock break by tmp#zakaz-prn.prt-code descending
        :
            if v-sum-qnty-prt > export-ras.qnty then
              assign
                tmp#zakaz-prn.qnty-ord = tmp#zakaz-prn.qnty-ord - 1
                v-sum-qnty-prt         = v-sum-qnty-prt         - 1
              .
            if v-sum-qnty-prt < export-ras.qnty then
              assign
                tmp#zakaz-prn.qnty-ord = tmp#zakaz-prn.qnty-ord + 1
                v-sum-qnty-prt         = v-sum-qnty-prt         + 1
              .
        end.  /*   for each tmp#zakaz-prn  */
      end.
    end.  /*   if p-tog-det-prizn  */

 end. /* for each tmp#zakaz */
  if p-mode-calc <> "" and p-mode-calc <> "all-ord":U  and  p-mode-calc <> "rcv-ord":U then do: /*  расчет */
      run cus/z-tot5.p ( parParentProc ,  input table export-ras , input p-ord-doc , input p-e-method , input v-show-all-goods) .
  end.

  if  p-mode-calc = "all-ord":U  then do: /*  расчет */
     run cus/z-tot6.p ( parParentProc , input table export-ras , input table tmp#zakaz-prn , g#type ) .
  end.

  if  p-mode-calc = "rcv-ord":U  then do: /*  расчет */
      run cus/maketrcv.p ( input table export-ras ) .
  end.

end.

/*-----------------------------------------------------------------------------------------------------------------------*/

procedure calcitog :
   assign
     fact-order-1 = integer(xdate-1 - 1 ) + 0.99
     fact-order-2 = integer(xdate-2) + 0.99
     fact-order-today = integer(date-today) + 0.99
   .

end procedure.



procedure goods-way :
 define input parameter p-obj-type like ub.clients.obj-type no-undo .
 define input parameter p-obj-code like ub.clients.obj-code no-undo .
 define output parameter p-qnty as decimal no-undo .

 define buffer later_ord-doc for ub.ord-doc.
 define buffer later_ord-line for ub.ord-line.

 do
 on error undo, return error return-value
 :
 p-qnty = 0 .
 if p-t-way = true then do:
   for each later_ord-line no-lock where
            later_ord-line.artic     = tmp#zakaz.artic       and
            later_ord-line.prod-code = tmp#zakaz.prod-code   and
            later_ord-line.prod-type = tmp#zakaz.prod-type  ,
       each later_ord-doc  no-lock where
            later_ord-doc.doc-code  = later_ord-line.doc-code and
            later_ord-doc.ship-date <= loc-date-ship          and
            later_ord-doc.obj-type = p-obj-type    and
            later_ord-doc.obj-code = p-obj-code    and
            later_ord-doc.status_   <>  {&g___new} and
            later_ord-doc.status_   <>  {&fact}
            :
                if ( p-t-rcv  and  later_ord-doc.status_   =  {&ord-rcv})
                  OR
                  ( p-t-clos  and  later_ord-doc.status_ = {&ord-close} ) then do:
                      p-qnty = p-qnty +  ( if  later_ord-line.qnty <> ? then later_ord-line.qnty
                                                                            else 0  ) .
                      end.
     end.

 end.
 end. /* do */
end procedure. /* goods-way */


procedure z-qnty :
 do
 on error undo, return error return-value
 :
 if p-mode-calc = ""  then do:
{ cus/z-qnty.i
calc
tmp#zakaz.qnty-stk
tmp#zakaz.negative-rest
l-qnty-qnty
pay-day
tmp#zakaz.temp-rash
tmp#zakaz.min-stock
l-new-zakaz
p-neg-sale
v-gds-way
p-t-min-zapas
tmp#zakaz.min-order
tmp#zakaz.unit-base
p-t-min-ost
p-t-deadline
tmp#zakaz.deadline
p-e-method
v-media-qnty
v-corr-coeff
}
end.

 end. /* do */
end procedure. /* z-qnty */
procedure z-qnty-e :
 do
 on error undo, return error return-value
 :
 if p-mode-calc <> ""  then do:
{ cus/z-qnty.i
calc
export-ras.qnty-stk
export-ras.negative-rest
l-qnty-qnty
pay-day
export-ras.temp-rash
export-ras.min-stock
l-new-zakaz
p-neg-sale
v-gds-way
p-t-min-zapas
export-ras.min-order
export-ras.unit-base
p-t-min-ost
p-t-deadline
export-ras.deadline
p-e-method
export-ras.order-qnty
v-corr-coeff
}
end.

 end. /* do */
end procedure. /* z-qnty */

procedure v-qnty :
 do
 on error undo, return error return-value
 :
 if p-mode-calc = ""  then do:
{ cus/v-qnty.i
calc
tmp#zakaz.qnty-stk
tmp#zakaz.negative-rest
l-qnty-qnty
pay-day
tmp#zakaz.temp-rash
tmp#zakaz.min-stock
l-new-zakaz
p-neg-sale
v-gds-way
tmp#zakaz.service-order
p-t-gar
p-t-min-zapas
tmp#zakaz.min-order
tmp#zakaz.unit-base
p-t-min-ost
p-t-deadline
tmp#zakaz.deadline
v-media-qnty
v-corr-coeff
}
end.
 end. /* do */
end procedure. /* z-qnty */
procedure v-qnty-e :
 do
 on error undo, return error return-value
 :
 if p-mode-calc <> ""  then do:
{ cus/v-qnty.i
calc
export-ras.qnty-stk
export-ras.negative-rest
l-qnty-qnty
pay-day
export-ras.temp-rash
export-ras.min-stock
l-new-zakaz
p-neg-sale
v-gds-way
export-ras.service-order
p-t-gar
p-t-min-zapas
export-ras.min-order
export-ras.unit-base
p-t-min-ost
p-t-deadline
export-ras.deadline
export-ras.order-qnty
v-corr-coeff
}
end.


 end. /* do */
end procedure. /* z-qnty */


procedure m-qnty :
 do
 on error undo, return error return-value
 :
 if p-mode-calc = ""  then do:
{ cus/m-qnty.i
calc
tmp#zakaz.qnty-stk
tmp#zakaz.negative-rest
l-qnty-qnty
pay-day
tmp#zakaz.temp-rash
tmp#zakaz.min-stock
l-new-zakaz
p-neg-sale
v-gds-way
tmp#zakaz.service-order
p-t-gar
p-t-min-zapas
tmp#zakaz.min-order
tmp#zakaz.unit-base
p-t-min-ost
p-t-deadline
tmp#zakaz.deadline
v-media-qnty
}
end.
 end. /* do */
end procedure. /* m-qnty */

procedure m-qnty-e :
 do
 on error undo, return error return-value
 :
 if p-mode-calc <> ""  then do:
{ cus/m-qnty.i
calc
export-ras.qnty-stk
export-ras.negative-rest
l-qnty-qnty
pay-day
export-ras.temp-rash
export-ras.min-stock
l-new-zakaz
p-neg-sale
v-gds-way
export-ras.service-order
p-t-gar
p-t-min-zapas
export-ras.min-order
export-ras.unit-base
p-t-min-ost
p-t-deadline
export-ras.deadline
export-ras.order-qnty
}

end.
 end. /* do */
end procedure. /* m-qnty */



procedure calc-null-day :
 do
 on error undo, return error return-value
 :
 l-null-day = 0 .
 IF p-type-qnty-day = 2   then do :
    for each temp-gds-qnty  :
       if  temp-gds-qnty.rash = 0  and  temp-gds-qnty.ost = 0 then do:
          l-null-day = l-null-day + temp-gds-qnty.qnty-day  .
          end.

     end.
  end.
  end. /* do */
end procedure. /* calc-null-day. */


procedure calc-sale :
 do
 on error undo, return error return-value
 :
          run ob-line in this-procedure  (
              input   obj-list.obj-code   ,
              input   obj-list.obj-type   ,
              input   tmp#zakaz.artic       ,
              input   tmp#zakaz.prod-code   ,
              input   tmp#zakaz.prod-type   ,
              input   fact-order-1   ,
              input   fact-order-2   ,
              input   {&arh-cost}    ,
              input   {&root-cat-id} ,
              input   ""    ,
              input   false ,
              input   false ,
              output v-prih ,
              output v-rash ,
              output v-kassa
              )  no-error .
            assign
              rash  = rash  + v-rash
              kassa = kassa + v-kassa
              prih = prih + v-prih
            .

 end. /* do */
end procedure. /* calc-sale */

procedure create-temp-rash :
 do
 on error undo, return error return-value
 :
  define input parameter p-date as date   no-undo .
  define input parameter p-val as decimal no-undo .


  find first temp-gds-qnty where
        temp-gds-qnty.day = p-date no-error
        .
  if not available temp-gds-qnty then do:
     create temp-gds-qnty.
     assign
        temp-gds-qnty.day = p-date
        temp-gds-qnty.rash = p-val
        temp-gds-qnty.qnty-day = 1
        .

  end.
  else do:
     assign
        temp-gds-qnty.rash = temp-gds-qnty.rash  + p-val
        temp-gds-qnty.qnty-day = 1
        .
  end.
 end. /* do */
end procedure. /* create-temp-rash */



procedure u-qnty :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

 if p-mode-calc = ""  then do:
{ cus/u-qnty.i
tmp#zakaz.max-stock
tmp#zakaz.qnty-stk
tmp#zakaz.negative-rest
tmp#zakaz.min-stock
p-neg-sale
v-gds-way
p-t-min-zapas
l-new-zakaz
tmp#zakaz.min-order
tmp#zakaz.unit-base
p-t-min-ost
p-t-deadline
tmp#zakaz.deadline
tmp#zakaz.temp-rash
v-media-qnty
v-corr-coeff
}
end.


 end. /* do */
end procedure. /* u-qnty */



procedure u-qnty-e :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

if p-mode-calc <> ""  then do:
{ cus/u-qnty.i
  export-ras.max-stock
  export-ras.qnty-stk
  export-ras.negative-rest
  export-ras.min-stock
  p-neg-sale
  v-gds-way
  p-t-min-zapas
  l-new-zakaz
  export-ras.min-order
  export-ras.unit-base
  p-t-min-ost
  p-t-deadline
  export-ras.deadline
  export-ras.temp-rash
  export-ras.order-qnty
  v-corr-coeff
}
end.


 end. /* do */
end procedure. /* u-qnty-e */