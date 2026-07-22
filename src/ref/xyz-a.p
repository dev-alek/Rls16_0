block-level on error undo, throw.
/*
$Revision: c5e125f9f735, 902, rls $
$Author: EShklyar $
$Date: Tue Dec 06 17:15:45 2016 +0300 $
$Workfile: xyz-a.p $
$Archive: ref/xyz-a.p $

Формирование таблицы с оборотами и прибылями для ABC XYZ анализов

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 05/12/05
*/

define variable vss-revision    as character no-undo init "$Revision: c5e125f9f735, 902, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 06 17:15:45 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xyz-a.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/xyz-a.p $":U .
define variable vss-description as character no-undo init "Формирование таблицы с оборотами и прибылями для ABC XYZ анализов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/factord.i  }
{ ref/def-abct.i }
{ gbl/waitfram.i }
{ cmp/gds-list.i gds-list def shared }
DEFINE TEMP-TABLE x-analysis        no-undo  LIKE ub.xyz-analysis
field r-goods as integer.
DEFINE TEMP-TABLE x-analysis-doc    no-undo  LIKE ub.xyz-analysis-doc.
DEFINE TEMP-TABLE x-analysis-obj    no-undo  LIKE ub.xyz-analysis-obj.
DEFINE TEMP-TABLE x-analysis-period no-undo  LIKE ub.xyz-analysis-period.


define temp-table tt-aht-ot-line no-undo like ub.aht-ot-line
field num-per as integer
.

define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-type as character no-undo .
define input  parameter p-id     as integer   no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  PARAMETER TABLE FOR    x-analysis.
define input  PARAMETER TABLE FOR    x-analysis-doc.
define input  PARAMETER TABLE FOR    x-analysis-obj.
define input  PARAMETER TABLE FOR    x-analysis-period.

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }


define variable p-ver-aht as logical   no-undo .
define variable i as integer   no-undo .
define variable v-i as character no-undo EXTENT 5.
define variable v-day as integer   no-undo .
define variable v-date-1  as date   no-undo .
define variable v-date-2  as date   no-undo .

run ver-aht (output p-ver-aht) no-error .
    if error-status :error or p-ver-aht = false  then do:
      message "Архивы не рассчитаны , результаты анализа  строятся на их основе !"
              view-as alert-box error .
    end.

 for each temp-oborot : delete temp-oborot . end.

 find first x-analysis no-error .


assign
  v-i[1] = {&aht-repayment}
  v-i[2] = {&aht-cons_acc}
  v-i[3] = {&aht-cons_benf}
  v-i[4] = {&aht-resp_stor}
  v-i[5] = {&aht-old_cons}
.

 run make-tt .
    run ref/func-xyz.p
        ( input table x-analysis
        , input table x-analysis-period
        , input-output table temp-oborot
        , input-output table temp-xyz
        , output table temp-goods )
    .
    run save-table-xyz.

/*++       end      ++*/


procedure make-tt :
/* заполнение таблицы с оборотами */
  do
  on error undo, return error return-value
  :
define buffer buf_gds-obj for ub.gds-obj.
define variable v-sum-crit      as decimal   no-undo .
define variable v-sum-qnty      as decimal   no-undo .
define variable v-price-crc     as decimal   no-undo .
define variable v-reserve-day   as decimal   no-undo .
define variable v-stock-qnty    as decimal   no-undo .
define variable v-sum-acc       as decimal   no-undo .
define variable v-sum-cur       as decimal   no-undo .
define variable v-sum-doc       as decimal   no-undo .
define variable v-vat-acc       as decimal   no-undo .
define variable v-vat-cur       as decimal   no-undo .
define variable v-vat-doc       as decimal   no-undo .
define variable v-transport-acc as decimal   no-undo .
define variable v-transport-cur as decimal   no-undo .
define variable v-transport-doc as decimal   no-undo .
define variable v-other-acc     as decimal   no-undo .
define variable v-other-cur     as decimal   no-undo .
define variable v-other-doc     as decimal   no-undo .
define variable v-road-tax-acc  as decimal   no-undo .
define variable v-road-tax-cur  as decimal   no-undo .
define variable v-road-tax-doc  as decimal   no-undo .
define variable v-slt-acc       as decimal   no-undo .
define variable v-slt-cur       as decimal   no-undo .
define variable v-slt-doc       as decimal   no-undo .

run waitfram-show ("Формирование таблицы оборотов...").
    for each x-analysis-obj :
      run waitfram-show ("Формирование таблицы оборотов...По объекту " + x-analysis-obj.obj-type + " " + string(x-analysis-obj.obj-code)).
        for each buf_gds-obj no-lock where
            buf_gds-obj.obj-type = x-analysis-obj.obj-type and
            buf_gds-obj.obj-code = x-analysis-obj.obj-code
            :
              if x-analysis.r-goods = 2 then do:
                   if not can-find( first gds-list where buf_gds-obj.gds-code = gds-list.gds-code) then next .
                end.
            run def-sum (
               input  x-analysis-obj.obj-type
              ,input  x-analysis-obj.obj-code
              ,input  buf_gds-obj.gds-code
              ,output v-sum-crit
              ,output v-sum-qnty
              ,output v-price-crc
              ,output v-reserve-day
              ,output v-stock-qnty
              ,output v-sum-acc
              ,output v-sum-cur
              ,output v-sum-doc
              ,output v-vat-acc
              ,output v-vat-cur
              ,output v-vat-doc
              ,output v-transport-acc
              ,output v-transport-cur
              ,output v-transport-doc
              ,output v-other-acc
              ,output v-other-cur
              ,output v-other-doc
              ,output v-road-tax-acc
              ,output v-road-tax-cur
              ,output v-road-tax-doc
              ,output v-slt-acc
              ,output v-slt-cur
              ,output v-slt-doc ) .

              if v-sum-crit <> 0 then do:
              find first  temp-oborot where
                  temp-oborot.obj-type = buf_gds-obj.obj-type and
                  temp-oborot.obj-code = buf_gds-obj.obj-code and
                  temp-oborot.gds-code = buf_gds-obj.gds-code
                  no-error .
                  if not available temp-oborot then do:
                    create temp-oborot.
                  end.
                  assign
                      temp-oborot.obj-type      = buf_gds-obj.obj-type
                      temp-oborot.obj-code      = buf_gds-obj.obj-code
                      temp-oborot.gds-code      = buf_gds-obj.gds-code
                      temp-oborot.sum-crit      = v-sum-crit
                      temp-oborot.qnty          = v-sum-qnty
                      temp-oborot.price-crc     = buf_gds-obj.price-sale
                      temp-oborot.reserve-day   = v-reserve-day
                      temp-oborot.stock-qnty    = buf_gds-obj.fact-qnty
                      temp-oborot.sum-acc       = v-sum-acc
                      temp-oborot.sum-cur       = v-sum-cur
                      temp-oborot.sum-doc       = v-sum-doc
                      temp-oborot.vat-acc       = v-vat-acc
                      temp-oborot.vat-cur       = v-vat-cur
                      temp-oborot.vat-doc       = v-vat-doc
                      temp-oborot.transport-acc = v-transport-acc
                      temp-oborot.transport-cur = v-transport-cur
                      temp-oborot.transport-doc = v-transport-doc
                      temp-oborot.other-acc     = v-other-acc
                      temp-oborot.other-cur     = v-other-cur
                      temp-oborot.other-doc     = v-other-doc
                      temp-oborot.road-tax-acc  = v-road-tax-acc
                      temp-oborot.road-tax-cur  = v-road-tax-cur
                      temp-oborot.road-tax-doc  = v-road-tax-doc
                      temp-oborot.slt-acc       = v-slt-acc
                      temp-oborot.slt-cur       = v-slt-cur
                      temp-oborot.slt-doc       = v-slt-doc
                  .
                if lookup(string(x-analysis.cral-id) ,"5,6,7,9,11,13,15") = 0 then
                          temp-oborot.price-cost    = buf_gds-obj.fact-rubl .
                     else temp-oborot.price-cost    = buf_gds-obj.fact-base .
                  run def-order (
                       input  buf_gds-obj.obj-type
                      ,input  buf_gds-obj.obj-code
                      ,input  buf_gds-obj.artic
                      ,input  buf_gds-obj.prod-type
                      ,input  buf_gds-obj.prod-code
                      ,output temp-oborot.order-qnty  ) .
              end.
        end.
    end.

  end.
end procedure. /* make-tt */


procedure def-sum :
do
on error undo, return error return-value
:
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-gds-code as integer   no-undo .

define output parameter v-sum-crit       as decimal   no-undo .
define output parameter v-sum-qnty       as decimal   no-undo .
define output parameter v-price-crc      as decimal   no-undo .
define output parameter v-reserve-day    as decimal   no-undo .
define output parameter v-stock-qnty     as decimal   no-undo .
define output parameter v-sum-acc        as decimal   no-undo .
define output parameter v-sum-cur        as decimal   no-undo .
define output parameter v-sum-doc        as decimal   no-undo .
define output parameter v-vat-acc        as decimal   no-undo .
define output parameter v-vat-cur        as decimal   no-undo .
define output parameter v-vat-doc        as decimal   no-undo .
define output parameter v-transport-acc  as decimal   no-undo .
define output parameter v-transport-cur  as decimal   no-undo .
define output parameter v-transport-doc  as decimal   no-undo .
define output parameter v-other-acc      as decimal   no-undo .
define output parameter v-other-cur      as decimal   no-undo .
define output parameter v-other-doc      as decimal   no-undo .
define output parameter v-road-tax-acc   as decimal   no-undo .
define output parameter v-road-tax-cur   as decimal   no-undo .
define output parameter v-road-tax-doc   as decimal   no-undo .
define output parameter v-slt-acc        as decimal   no-undo .
define output parameter v-slt-cur        as decimal   no-undo .
define output parameter v-slt-doc        as decimal   no-undo .

define variable  p-date-1 as date   no-undo .
define variable  p-date-2 as date   no-undo .

define variable v-fact-order-1 as decimal   no-undo .
define variable v-fact-order-2 as decimal   no-undo .
define variable v-sum          as decimal   no-undo .


define buffer buf_aht-ot-line for ub.aht-ot-line.


find first x-analysis no-error .
if error-status :error then message error-status :get-message(1) "7770" view-as alert-box information .

for each tt-aht-ot-line : delete tt-aht-ot-line . end.
define variable v-p as integer   no-undo init 0.

    for each x-analysis-period :
      assign
        v-p = v-p + 1
        p-date-1 = x-analysis-period.xyzp-start
        p-date-2 = x-analysis-period.xyzp-end
      .
      run day-begin-fact-order (input p-date-1 , output  v-fact-order-1).
      run factord-end-day (input p-date-2 , output  v-fact-order-2).

      for each x-analysis-doc :
        repeat i = 1 to 5 :
            for each buf_aht-ot-line no-lock where
                    buf_aht-ot-line.ext-doc-type = x-analysis-doc.xyzd-ext-doc-type and
                    buf_aht-ot-line.gds-code     = p-gds-code                       and
                    buf_aht-ot-line.obj-code     = p-obj-code                       and
                    buf_aht-ot-line.obj-type     = p-obj-type                       and
                    buf_aht-ot-line.sum-type     = v-i[i]                           and
                    buf_aht-ot-line.fact-order   >= v-fact-order-1                  and
                    buf_aht-ot-line.fact-order   <= v-fact-order-2
            :
                create tt-aht-ot-line.
                buffer-copy buf_aht-ot-line to tt-aht-ot-line .
                assign
                  tt-aht-ot-line.num-per = v-p .
                .
                if buf_aht-ot-line.sum-type = {&aht-cons_benf} then do:   /* "b" - в количестве не учитывается (коммис.вознаграждение)*/
                   tt-aht-ot-line.fact-qnty  = 0 .
                end.
            end.
        end.
      end.
    end.

assign
  v-sum-crit        = 0
  v-sum-qnty        = 0
  v-price-crc       = 0
  v-reserve-day     = 0
  v-stock-qnty      = 0
  v-sum-acc         = 0
  v-sum-cur         = 0
  v-sum-doc         = 0
  v-vat-acc         = 0
  v-vat-cur         = 0
  v-vat-doc         = 0
  v-transport-acc   = 0
  v-transport-cur   = 0
  v-transport-doc   = 0
  v-other-acc       = 0
  v-other-cur       = 0
  v-other-doc       = 0
  v-road-tax-acc    = 0
  v-road-tax-cur    = 0
  v-road-tax-doc    = 0
  v-slt-acc         = 0
  v-slt-cur         = 0
  v-slt-doc         = 0
.


for each tt-aht-ot-line :
    v-sum-qnty          = v-sum-qnty         + tt-aht-ot-line.fact-qnty .
    if lookup(string(x-analysis.cral-id) ,"5,6,7,9,11,13,15") = 0 then
    assign
      v-sum-acc         = v-sum-acc         + tt-aht-ot-line.cost-sum-rubl
      v-sum-cur         = v-sum-cur         + tt-aht-ot-line.crsa-sum-rubl
      v-sum-doc         = v-sum-doc         + tt-aht-ot-line.sale-sum-rubl
      v-vat-acc         = v-vat-acc         + tt-aht-ot-line.cost-vat-rubl
      v-vat-cur         = v-vat-cur         + tt-aht-ot-line.crsa-vat-rubl
      v-vat-doc         = v-vat-doc         + tt-aht-ot-line.sale-vat-rubl
      v-transport-acc   = v-transport-acc   + tt-aht-ot-line.cost-transport-rubl
      v-transport-cur   = v-transport-cur   + tt-aht-ot-line.crsa-transport-rubl
      v-transport-doc   = v-transport-doc   + tt-aht-ot-line.sale-transport-rubl
      v-other-acc       = v-other-acc       + tt-aht-ot-line.cost-other-rubl
      v-other-cur       = v-other-cur       + tt-aht-ot-line.crsa-other-rubl
      v-other-doc       = v-other-doc       + tt-aht-ot-line.sale-other-rubl
      v-road-tax-acc    = v-road-tax-acc    + tt-aht-ot-line.cost-road-tax-rubl
      v-road-tax-cur    = v-road-tax-cur    + tt-aht-ot-line.crsa-road-tax-rubl
      v-road-tax-doc    = v-road-tax-doc    + tt-aht-ot-line.sale-road-tax-rubl
      v-slt-acc         = v-slt-acc         + tt-aht-ot-line.cost-slt-rubl
      v-slt-cur         = v-slt-cur         + tt-aht-ot-line.crsa-slt-rubl
      v-slt-doc         = v-slt-doc         + tt-aht-ot-line.sale-slt-rubl
    .
    else
    assign
      v-sum-acc         = v-sum-acc         + tt-aht-ot-line.cost-sum-base
      v-sum-cur         = v-sum-cur         + tt-aht-ot-line.crsa-sum-base
      v-sum-doc         = v-sum-doc         + tt-aht-ot-line.sale-sum-base
      v-vat-acc         = v-vat-acc         + tt-aht-ot-line.cost-vat-base
      v-vat-cur         = v-vat-cur         + tt-aht-ot-line.crsa-vat-base
      v-vat-doc         = v-vat-doc         + tt-aht-ot-line.sale-vat-base
      v-transport-acc   = v-transport-acc   + tt-aht-ot-line.cost-transport-base
      v-transport-cur   = v-transport-cur   + tt-aht-ot-line.crsa-transport-base
      v-transport-doc   = v-transport-doc   + tt-aht-ot-line.sale-transport-base
      v-other-acc       = v-other-acc       + tt-aht-ot-line.cost-other-base
      v-other-cur       = v-other-cur       + tt-aht-ot-line.crsa-other-base
      v-other-doc       = v-other-doc       + tt-aht-ot-line.sale-other-base
      v-road-tax-acc    = v-road-tax-acc    + tt-aht-ot-line.cost-road-tax-base
      v-road-tax-cur    = v-road-tax-cur    + tt-aht-ot-line.crsa-road-tax-base
      v-road-tax-doc    = v-road-tax-doc    + tt-aht-ot-line.sale-road-tax-base
      v-slt-acc         = v-slt-acc         + tt-aht-ot-line.cost-slt-base
      v-slt-cur         = v-slt-cur         + tt-aht-ot-line.crsa-slt-base
      v-slt-doc         = v-slt-doc         + tt-aht-ot-line.sale-slt-base
    .

      case x-analysis.cral-id :
        when 1
        /*  "Оборот в количестве"   */
        then do:
            run calc-qnty (output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
        when 2
      /*"Оборот в учетных ценах в нац.валюте"
      "Реализовано по ценам из партий в нац.валюте"*/
        then do:
            run calc-str-oborot ( "rubl" , "cost" , "with-vat" , output v-sum).
        end.
        when 3
      /*"Оборот в ценах документа в нац.валюте"
      "Реализовано товара по ценам документа в нац.валюте"*/
        then do:
            run calc-str-oborot ( "rubl" , "sale" , "with-vat" , output v-sum).
        end.
        when 4
      /*"Оборот в текущих продажных ценах в нац.валюте     "
      "Реализовано в текущих продажных ценах в нац.валюте "*/
        then do:
            run calc-str-oborot ( "rubl" , "crsa" , "with-vat" , output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
        when 5
      /*"Оборот в учетных ценах в базовой валюте        "
      "Реализовано по ценам из партий в базовой валюте "*/
        then do:
          run calc-str-oborot ( "base" , "cost" , "with-vat" , output v-sum).
        end.
        when 6
      /*"Оборот в ценах документа в баз.валюте"
      "Реализовано по ценам из документа в базовой валюте"*/
        then do:
            run calc-str-oborot ( "base" , "sale" , "with-vat" , output v-sum).
        end.
        when 7
      /*"Оборот в текущих продажных ценах в базовой валюте"
      "Реализовано в текущих продажных ценах в базовой валюте"*/
        then do:
            run calc-str-oborot ( "base" , "crsa" , "with-vat" , output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
        when 8
      /*"Прибыль с учетом налогов в нац.валюте"
      "Сумма реализ. товара в  ценах док. без налогов минус сумма в учетных ценах без налогов (нац.валюта)"*/
        then do:
          run calc-str-prib ( "rubl" , "sale" , "cost" , "without-vat" , output v-sum).
        end.
        when 9
      /*"Прибыль с учетом налогов в базовой валюте"
      "Сумма реализ. товара в  ценах док. без налогов минус сумма в учетных ценах без налогов (баз. вал.)"*/
        then do:
            run calc-str-prib ( "base" , "sale" , "cost" , "without-vat" , output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
        when 10
      /*"Прибыль в нац.валюте"
      "Сумма реализ. в  ценах док. минус сумма в учетных ценах (нац.валюта)"*/
        then do:
              run calc-str-prib ( "rubl" , "sale" , "cost" , "with-vat" , output v-sum).
        end.
        when 11
      /*"Прибыль в базовой валюте"
      "Сумма реализ. в  ценах док. минус сумма в учетных ценах (баз. вал.)"*/
        then do:
              run calc-str-prib ( "base" , "sale" , "cost" , "with-vat" , output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
        when 12
      /*"Потенциальная прибыль с учетом налогов в нац.валюте"
      "Сумма реализ. в  тек. прод ценах без налогов минус сумма в учетных ценах без налогов (нац.валюта)"*/
        then do:
              run calc-str-prib ( "rubl" , "crsa" , "cost" , "without-vat" , output v-sum).
        end.
        when 13
      /*"Потенциальная прибыль с учетом налогов в базовой валюте"
      "Сумма реализ. в  тек. прод. ценах  без налогов минус сумма в учетных ценах без налогов (баз. вал.)"*/
        then do:
              run calc-str-prib ( "base" , "crsa" , "cost" , "without-vat" , output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
        when 14
      /*"Потенциальная прибыль в нац.валюте"
      "Сумма реализ. товара в тек. прод. ценах  минус сумма в учетных ценах (нац.валюта)"*/
        then do:
              run calc-str-prib ( "rubl" , "crsa" , "cost" , "with-vat" , output v-sum).
        end.
        when 15
      /*"Потенциальная прибыль в базовой валюте"
      "Сумма реализ. товара в тек. прод. ценах  минус сумма в учетных ценах (баз. вал.)"*/
        then do:
                run calc-str-prib ( "base" , "crsa" , "cost" , "with-vat" , output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
      end case.

     v-sum-crit = v-sum-crit + v-sum .

  find first temp-xyz where
             temp-xyz.gds-code = p-gds-code and
             temp-xyz.num-per  = tt-aht-ot-line.num-per no-error .
       if not available  temp-xyz  then do:
          create temp-xyz.
          assign
            temp-xyz.gds-code   = p-gds-code
            temp-xyz.num-per    = tt-aht-ot-line.num-per
            temp-xyz.sum-crit-p = (-1) * v-sum
          .
       end.
       else
          assign
            temp-xyz.sum-crit-p = temp-xyz.sum-crit-p - v-sum
          .



end.
assign
  v-sum-crit      = (-1) * v-sum-crit
  v-sum-qnty      = (-1) * v-sum-qnty
  v-sum-acc       = (-1) * v-sum-acc
  v-sum-cur       = (-1) * v-sum-cur
  v-sum-doc       = (-1) * v-sum-doc
  v-vat-acc       = (-1) * v-vat-acc
  v-vat-cur       = (-1) * v-vat-cur
  v-vat-doc       = (-1) * v-vat-doc
  v-transport-acc = (-1) * v-transport-acc
  v-transport-cur = (-1) * v-transport-cur
  v-transport-doc = (-1) * v-transport-doc
  v-other-acc     = (-1) * v-other-acc
  v-other-cur     = (-1) * v-other-cur
  v-other-doc     = (-1) * v-other-doc
  v-road-tax-acc  = (-1) * v-road-tax-acc
  v-road-tax-cur  = (-1) * v-road-tax-cur
  v-road-tax-doc  = (-1) * v-road-tax-doc
  v-slt-acc       = (-1) * v-slt-acc
  v-slt-cur       = (-1) * v-slt-cur
  v-slt-doc       = (-1) * v-slt-doc
.

end.
end procedure. /* def-sum */


procedure calc-str-oborot :
  do
  on error undo, return error return-value
  :
define input  parameter p-val as character no-undo .
define input  parameter p-sum-type as character no-undo .
define input  parameter p-vat as character no-undo .
define output parameter p-sum as decimal   no-undo .

  case p-val :
     when "rubl" then do:
            case p-sum-type :
              when "crsa" then do:
                    p-sum = tt-aht-ot-line.crsa-sum-rubl.
              end.
              when "cost" then do:
                    p-sum = tt-aht-ot-line.cost-sum-rubl.
              end.
              when "sale" then do:
                    p-sum = tt-aht-ot-line.sale-sum-rubl.
              end.
            end case.
     end.
     when "base" then do:
            case p-sum-type :
              when "crsa" then do:
                    p-sum = tt-aht-ot-line.crsa-sum-base.
              end.
              when "cost" then do:
                    p-sum = tt-aht-ot-line.cost-sum-base.
              end.
              when "sale" then do:
                    p-sum = tt-aht-ot-line.sale-sum-base.
              end.
            end case.
     end.

  end case.

  end.
end procedure. /* calc-str-oborot */


procedure calc-str-prib :
  do
  on error undo, return error return-value
  :
define input  parameter p-val as character no-undo .
define input  parameter p-sum-type1 as character no-undo .
define input  parameter p-sum-type2 as character no-undo .
define input  parameter p-vat as character no-undo .
define output parameter p-sum as decimal   no-undo .
      if p-vat = "with-vat" then do:
        case p-val :
          when "rubl" then do:
                  case p-sum-type1 :
                    when "crsa" then do:
                          p-sum = tt-aht-ot-line.crsa-sum-rubl - tt-aht-ot-line.cost-sum-rubl.
                    end.
                    when "sale" then do:
                          p-sum = tt-aht-ot-line.sale-sum-rubl - tt-aht-ot-line.cost-sum-rubl.
                    end.
                  end case.
          end.
          when "base" then do:
                  case p-sum-type1 :
                    when "crsa" then do:
                          p-sum = tt-aht-ot-line.crsa-sum-base - tt-aht-ot-line.cost-sum-base.
                    end.
                    when "sale" then do:
                          p-sum = tt-aht-ot-line.sale-sum-base - tt-aht-ot-line.cost-sum-base.
                    end.
                  end case.
          end.
        end case.
      end.
      else do:
        case p-val :
          when "rubl" then do:
                  case p-sum-type1 :
                    when "crsa" then do:
                          p-sum = (tt-aht-ot-line.crsa-sum-rubl - tt-aht-ot-line.crsa-vat-rubl - tt-aht-ot-line.crsa-slt-rubl ) -
                                  (tt-aht-ot-line.cost-sum-rubl - tt-aht-ot-line.cost-vat-rubl - tt-aht-ot-line.cost-slt-rubl ) .
                    end.
                    when "sale" then do:
                          p-sum = ( tt-aht-ot-line.sale-sum-rubl - tt-aht-ot-line.sale-vat-rubl - tt-aht-ot-line.sale-slt-rubl ) -
                                  ( tt-aht-ot-line.cost-sum-rubl - tt-aht-ot-line.cost-vat-rubl - tt-aht-ot-line.cost-slt-rubl ).
                    end.
                  end case.
          end.
          when "base" then do:
                  case p-sum-type1 :
                    when "crsa" then do:
                          p-sum = (tt-aht-ot-line.crsa-sum-base - tt-aht-ot-line.crsa-vat-base - tt-aht-ot-line.crsa-slt-base ) -
                                  (tt-aht-ot-line.cost-sum-base - tt-aht-ot-line.cost-vat-base - tt-aht-ot-line.cost-slt-base ) .
                    end.
                    when "sale" then do:
                          p-sum = ( tt-aht-ot-line.sale-sum-base - tt-aht-ot-line.sale-vat-base - tt-aht-ot-line.sale-slt-base ) -
                                  ( tt-aht-ot-line.cost-sum-base - tt-aht-ot-line.cost-vat-base - tt-aht-ot-line.cost-slt-base ).
                    end.
                  end case.
          end.
        end case.
      end.
  end.
end procedure. /* calc-str-prib */


procedure calc-qnty :
do
on error undo, return error return-value
:
define output parameter p-sum as decimal   no-undo .
  p-sum = tt-aht-ot-line.fact-qnty.
end.
end procedure. /* calc-qnty */


procedure ver-aht :
/* проверка расчета архивов */
  do
  on error undo, return error return-value
  :
define output parameter v-total-archive-ok as logical   no-undo  .
define variable  v-archive-ok  as logical   no-undo .
define variable  v-comment    as character no-undo .
define variable  v-can-print  as logical   no-undo .

for each x-analysis-period break by x-analysis-period.xyzp-start desc :
 v-date-1 = x-analysis-period.xyzp-start.
end.

for each x-analysis-period break by x-analysis-period.xyzp-end  :
 v-date-2 = x-analysis-period.xyzp-end.
end.

for each x-analysis-period break by x-analysis-period.xyzp-start desc :
 v-day = v-day + ( x-analysis-period.xyzp-end -  x-analysis-period.xyzp-start + 1) .
end.
if v-day = 0 or v-day = ? then v-day = 1.


v-total-archive-ok =  true .

    for each x-analysis-obj :
      run rep/chk-ahz.p
        (input        x-analysis-obj.obj-type  /* p-obj-type          */
        ,input        x-analysis-obj.obj-code  /* p-obj-code          */
        ,input        false                    /* p-verify-detail     */
        ,input        false                    /* p-verify-arh        */
        ,input        false                    /* p-verify-ahsp       */
        ,input        true                     /* p-verify-aht        */
        ,input        true                     /* p-check-act         */
        ,input        v-cntxt-db-num           /* p-check-act-db-num  */
        ,input        v-cntxt-userid           /* p-check-act-user-id */
        ,input-output v-date-1                 /* p-date-start        */
        ,input-output v-date-2                 /* p-date-end          */
        ,output       v-archive-ok             /* p-archive-ok        */
        ,output       v-comment                /* p-comment           */
        ,output       v-can-print              /* p-can-print         */
        ) .



      if v-archive-ok = false  then
      do:
            if v-can-print = false
            then do:
              message
                "ВНИМАНИЕ !!!" skip
                "Анализ не может быть сформирован!" skip
                "На запрошенную дату нет архивов или они сжаты" skip
                v-date-1 v-date-2 skip
                v-comment skip
                view-as alert-box information .
                return error return-value .
            end.
            else do:
              assign
                v-total-archive-ok = false
              .
              leave .
            end.
      end.

    end.

    if v-total-archive-ok = false
    then do:
      define variable v-period-description as character no-undo .

        assign
          v-period-description = substitute("с начала дня &1 по конец дня &2"
                                           ,string(v-date-1, '99/99/9999':u)
                                           ,string(v-date-2,   '99/99/9999':u)
                                           )
        .

      message
        "ВНИМАНИЕ!" skip
        v-comment skip
        "" skip
        "Данные по выбранному периоду" v-period-description "могут быть неполными или некорректными." skip
        "Продолжить формирование анализа?" skip
        view-as alert-box question buttons yes-no update choice as logical  .
          if choice = false
          then do:
            assign
              v-archive-ok = false
            .
            return.
          end.
          else do:
            assign
              v-total-archive-ok = true
            .
          end.
    end.


  end.
end procedure. /* ver-aht */


procedure def-order :

  do
  on error undo, return error return-value
  :
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code  as integer   no-undo .
define input  parameter p-artic     as char   no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .
define output parameter v-qnty       as decimal   no-undo .

define buffer buf-ord-line for ub.ord-line.
define buffer buf-ord-doc  for ub.ord-doc.


      for each buf-ord-line no-lock where
              buf-ord-line.artic          =   p-artic     and
              buf-ord-line.prod-type      =   p-prod-type and
              buf-ord-line.prod-code      =   p-prod-code  ,
          first buf-ord-doc no-lock where
                buf-ord-doc.doc-code      =   buf-ord-line.doc-code and
                buf-ord-doc.obj-type      =   p-obj-type  and
                buf-ord-doc.obj-code      =   p-obj-code  and
                buf-ord-doc.status_       <>  {&fact}     and
                buf-ord-doc.status_       <>  {&g___new}  and
                buf-ord-doc.doc-date      <=   v-date-2   and
                buf-ord-doc.doc-date      >=   v-date-1
                :

          for each x-analysis-period :
            if buf-ord-doc.doc-date >= x-analysis-period.xyzp-start and
               buf-ord-doc.doc-date <= x-analysis-period.xyzp-end
                then do:
                  v-qnty =  v-qnty + buf-ord-line.qnty .
                end.
          end.
      end.
  end.

end procedure. /* def-order */


procedure save-table-xyz :

  do
  on error undo, return error return-value
  :
define variable v-all-sum as decimal   no-undo .
define variable v-all-qnty as decimal   no-undo .
define variable v-a-sum  as decimal   no-undo .
define variable v-a-qnty as decimal   no-undo .
define variable v-b-sum  as decimal   no-undo .
define variable v-b-qnty as decimal   no-undo .
define variable v-c-sum  as decimal   no-undo .
define variable v-c-qnty as decimal   no-undo .

run waitfram-show ("Сохранение результатов анализа по объектам в БД...").
for each temp-oborot ,
    first temp-goods where
          temp-goods.gds-code = temp-oborot.gds-code and
          temp-goods.sum-crit > 0
        :
        create ub.xyz-analysis-gds-obj.
        assign
          ub.xyz-analysis-gds-obj.xyz-id                  =  p-id
          ub.xyz-analysis-gds-obj.db-num                  =  p-db-num
          ub.xyz-analysis-gds-obj.gds-code                =  temp-oborot.gds-code
          ub.xyz-analysis-gds-obj.obj-code                =  temp-oborot.obj-code
          ub.xyz-analysis-gds-obj.obj-type                =  temp-oborot.obj-type
          ub.xyz-analysis-gds-obj.xyog-other-acc          =  temp-oborot.other-acc
          ub.xyz-analysis-gds-obj.xyog-other-cur          =  temp-oborot.other-cur
          ub.xyz-analysis-gds-obj.xyog-other-doc          =  temp-oborot.other-doc
          ub.xyz-analysis-gds-obj.xyog-qnty               =  temp-oborot.qnty
          ub.xyz-analysis-gds-obj.xyog-price-crc          =  temp-oborot.price-crc
          ub.xyz-analysis-gds-obj.xyog-reserve-day        =  temp-oborot.reserve-day
          ub.xyz-analysis-gds-obj.xyog-road-tax-acc       =  temp-oborot.road-tax-acc
          ub.xyz-analysis-gds-obj.xyog-road-tax-cur       =  temp-oborot.road-tax-cur
          ub.xyz-analysis-gds-obj.xyog-road-tax-doc       =  temp-oborot.road-tax-doc
          ub.xyz-analysis-gds-obj.xyog-slt-acc            =  temp-oborot.slt-acc
          ub.xyz-analysis-gds-obj.xyog-slt-cur            =  temp-oborot.slt-cur
          ub.xyz-analysis-gds-obj.xyog-slt-doc            =  temp-oborot.slt-doc
          ub.xyz-analysis-gds-obj.xyog-stock-qnty         =  temp-oborot.stock-qnty
          ub.xyz-analysis-gds-obj.xyog-sum-acc            =  temp-oborot.sum-acc
          ub.xyz-analysis-gds-obj.xyog-sum-cur            =  temp-oborot.sum-cur
          ub.xyz-analysis-gds-obj.xyog-sum-doc            =  temp-oborot.sum-doc
          ub.xyz-analysis-gds-obj.xyog-transport-acc      =  temp-oborot.transport-acc
          ub.xyz-analysis-gds-obj.xyog-transport-cur      =  temp-oborot.transport-cur
          ub.xyz-analysis-gds-obj.xyog-transport-doc      =  temp-oborot.transport-doc
          ub.xyz-analysis-gds-obj.xyog-vat-acc            =  temp-oborot.vat-acc
          ub.xyz-analysis-gds-obj.xyog-vat-cur            =  temp-oborot.vat-cur
          ub.xyz-analysis-gds-obj.xyog-vat-doc            =  temp-oborot.vat-doc
          ub.xyz-analysis-gds-obj.xyog-temp-sale-goods    =  temp-oborot.qnty / v-day
        .
end.
run waitfram-show ("Сохранение результатов анализа по товарам в БД...") .


for each temp-goods where temp-goods.sum-crit > 0 :
    v-all-sum  = v-all-sum  + temp-goods.sum-crit .
    v-all-qnty = v-all-qnty + 1.

    case temp-goods.crit :
       when "X"
       then do:
            v-a-sum  = v-a-sum  + temp-goods.sum-crit .
            v-a-qnty = v-a-qnty + 1.
       end.
       when "Y"
       then do:
            v-b-sum  = v-b-sum  + temp-goods.sum-crit .
            v-b-qnty = v-b-qnty + 1.
       end.
       when "Z"
       then do:
            v-c-sum  = v-c-sum  + temp-goods.sum-crit .
            v-c-qnty = v-c-qnty + 1.
       end.
    end case.

    create ub.xyz-analysis-goods.
    assign
      ub.xyz-analysis-goods.xyz-id                  = p-id
      ub.xyz-analysis-goods.db-num                  = p-db-num
      ub.xyz-analysis-goods.gds-code                = temp-goods.gds-code
      ub.xyz-analysis-goods.xyzg-xyz                = temp-goods.crit
      ub.xyz-analysis-goods.xyzg-order-qnty         = temp-goods.order-qnty
      ub.xyz-analysis-goods.xyzg-other-acc          = temp-goods.other-acc
      ub.xyz-analysis-goods.xyzg-other-cur          = temp-goods.other-cur
      ub.xyz-analysis-goods.xyzg-other-doc          = temp-goods.other-doc
      ub.xyz-analysis-goods.xyzg-prcnt-for-estimate = temp-goods.crit-pr
      ub.xyz-analysis-goods.xyzg-qnty               = temp-goods.qnty
      ub.xyz-analysis-goods.xyzg-road-tax-acc       = temp-goods.road-tax-acc
      ub.xyz-analysis-goods.xyzg-road-tax-cur       = temp-goods.road-tax-cur
      ub.xyz-analysis-goods.xyzg-road-tax-doc       = temp-goods.road-tax-doc
      ub.xyz-analysis-goods.xyzg-slt-acc            = temp-goods.slt-acc
      ub.xyz-analysis-goods.xyzg-slt-cur            = temp-goods.slt-cur
      ub.xyz-analysis-goods.xyzg-slt-doc            = temp-goods.slt-doc
      ub.xyz-analysis-goods.xyzg-stock-qnty         = temp-goods.stock-qnty
      ub.xyz-analysis-goods.xyzg-stock-price-acc    = temp-goods.stock-price-acc
      ub.xyz-analysis-goods.xyzg-stock-price-sale   = temp-goods.stock-price-sale
      ub.xyz-analysis-goods.xyzg-sum-acc            = temp-goods.sum-acc
      ub.xyz-analysis-goods.xyzg-sum-cur            = temp-goods.sum-cur
      ub.xyz-analysis-goods.xyzg-sum-doc            = temp-goods.sum-doc
      ub.xyz-analysis-goods.xyzg-sum-for-estimate   = temp-goods.sum-crit
      ub.xyz-analysis-goods.xyzg-temp-sale-goods    = temp-goods.qnty / v-day
      ub.xyz-analysis-goods.xyzg-transport-acc      = temp-goods.transport-acc
      ub.xyz-analysis-goods.xyzg-transport-cur      = temp-goods.transport-cur
      ub.xyz-analysis-goods.xyzg-transport-doc      = temp-goods.transport-doc
      ub.xyz-analysis-goods.xyzg-vat-acc            = temp-goods.vat-acc
      ub.xyz-analysis-goods.xyzg-vat-cur            = temp-goods.vat-cur
      ub.xyz-analysis-goods.xyzg-vat-doc            = temp-goods.vat-doc
      ub.xyz-analysis-goods.kol-period              = temp-goods.kol-period
      ub.xyz-analysis-goods.average-qnty            = temp-goods.average-qnty
      ub.xyz-analysis-goods.sigma                   = temp-goods.sigma
      .
end.

find current x-analysis  no-error .
assign
x-analysis.xyz-x-prc-qnty   = v-a-qnty * 100 / v-all-qnty
x-analysis.xyz-x-qnty       = v-a-qnty
x-analysis.xyz-x-sum-prc    = v-a-sum * 100 / v-all-sum
x-analysis.xyz-x-sum        = v-a-sum
x-analysis.xyz-y-prc-qnty   = v-b-qnty * 100 / v-all-qnty
x-analysis.xyz-y-qnty       = v-b-qnty
x-analysis.xyz-y-sum-prc    = v-b-sum * 100 / v-all-sum
x-analysis.xyz-y-sum        = v-b-sum
x-analysis.xyz-z-prc-qnty   = v-c-qnty * 100 / v-all-qnty
x-analysis.xyz-z-qnty       = v-c-qnty
x-analysis.xyz-z-sum-prc    = v-c-sum * 100 / v-all-sum
x-analysis.xyz-z-sum        = v-c-sum

.

define variable v-doc-rec as recid no-undo .
define buffer buf_xyz-analysis for ub.xyz-analysis.
find first buf_xyz-analysis no-lock where
            buf_xyz-analysis.xyz-id                 = p-id and
            buf_xyz-analysis.db-num                 = p-db-num no-error .

 v-doc-rec = recid(buf_xyz-analysis) .

 run ref/xyzanal1.p (
                input-output v-doc-rec
                ,{&update}
                ,buf_XYZ-analysis.XYZ-id
                ,buf_XYZ-analysis.db-num
                ,buf_XYZ-analysis.cral-id
                ,buf_XYZ-analysis.XYZ-name
                ,buf_XYZ-analysis.XYZ-des
                ,buf_XYZ-analysis.raxd-x
                ,buf_XYZ-analysis.raxd-y
                ,buf_XYZ-analysis.raxd-z
                ,buf_XYZ-analysis.XYZ-x
                ,buf_XYZ-analysis.XYZ-y
                ,buf_XYZ-analysis.XYZ-z
                ,x-analysis.xyz-x-prc-qnty
                ,x-analysis.xyz-x-qnty
                ,x-analysis.xyz-x-sum-prc
                ,x-analysis.xyz-x-sum
                ,x-analysis.xyz-y-prc-qnty
                ,x-analysis.xyz-y-qnty
                ,x-analysis.xyz-y-sum-prc
                ,x-analysis.xyz-y-sum
                ,x-analysis.xyz-z-prc-qnty
                ,x-analysis.xyz-z-qnty
                ,x-analysis.xyz-z-sum-prc
                ,x-analysis.xyz-z-sum
                ,x-analysis.r-goods
                ,table x-analysis-doc
                ,table x-analysis-obj
                ,table x-analysis-period
                ) no-error .

if error-status :error then message
return-value
error-status :get-message(1)
222
.


run waitfram-hide in this-procedure .
  end.

end procedure. /* save-table */