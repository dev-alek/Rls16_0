block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: abc-a.p $
$Archive: ref/abc-a.p $

Формирование таблицы с оборотами и прибылями для ABC XYZ анализов

Автор: Чернова Светлана Александровна
Дата создания: 05/12/05
Author: Svetlana Chernova
Creation date: 05/12/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: abc-a.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/abc-a.p $":U .
define variable vss-description as character no-undo init "Формирование таблицы с оборотами и прибылями для ABC XYZ анализов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/factord.i  }
{ ref/def-abct.i }
{ gbl/waitfram.i }
{ cmp/gds-list.i gds-list def shared }
DEFINE TEMP-TABLE x-analysis        no-undo  LIKE ub.abc-analysis.
DEFINE TEMP-TABLE x-analysis-doc    no-undo  LIKE ub.abc-analysis-doc.
DEFINE TEMP-TABLE x-analysis-obj    no-undo  LIKE ub.abc-analysis-obj.
DEFINE TEMP-TABLE x-analysis-period no-undo  LIKE ub.abc-analysis-period.


define temp-table tt-aht-ot-line no-undo like ub.aht-ot-line .

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


define temp-table temp-oborot1 no-undo like temp-oborot .
define temp-table temp-oborot2 no-undo like temp-oborot .
define temp-table temp-goods1  no-undo like temp-goods .
define temp-table temp-goods2  no-undo like temp-goods .


define temp-table temp-tt no-undo
field id        as recid    /* есть */
field summa     as decimal  /* есть */
field proc      as decimal  /* есть */
field proc-2    as decimal
field proc-acc1 as decimal
field proc-acc2 as decimal
field ABC-1     as character
field ABC       as character
index pi proc desc
index pi1 proc-acc1 desc
index pi2 proc-acc2 desc
index pi3 id
.


define variable p-ver-aht as logical   no-undo .
define variable i as integer   no-undo .
define variable v-i as character no-undo EXTENT 5.
define variable v-day as integer   no-undo .
define variable v-date-1  as date   no-undo .
define variable v-date-2  as date   no-undo .

run ver-aht in this-procedure (output p-ver-aht) no-error .
/*    if error-status :error or p-ver-aht = false  then do:
      message vss-workfile vss-revision vss-description skip
              return-value    skip
              error-status :get-message(1)
              "123" skip
              view-as alert-box error .

    end.
 */

 for each temp-oborot  : delete temp-oborot . end.
 for each temp-oborot1 : delete temp-oborot1 . end.
 for each temp-oborot2 : delete temp-oborot2 . end.

 find first x-analysis no-error .

assign
  v-i[1] = {&aht-repayment}
  v-i[2] = {&aht-cons_acc}
  v-i[3] = {&aht-cons_benf}
  v-i[4] = {&aht-resp_stor}
  v-i[5] = {&aht-old_cons}
.

  run make-tt in this-procedure  .
  run ref/func-abc.p
      ( input table x-analysis
      , input-output table temp-oborot
      , output table temp-goods )
  .

 for each temp-tt : delete temp-tt . end.
 for each temp-goods :
     create temp-tt.
     assign
       temp-tt.id = recid(temp-goods)
       temp-tt.summa = temp-goods.sum-crit
     .
 end.

  run ref/tt-abc.p
      ( input table x-analysis
      , input-output table temp-tt )
  .
 for each temp-goods :
     find first temp-tt where  temp-tt.id = recid(temp-goods) .

     temp-goods.crit = temp-tt.abc .
     if x-analysis.abc-type = "2"  then do:
       temp-goods.prcnt-account = temp-tt.proc-acc2.
     end.
     else do:
       temp-goods.prcnt-account = temp-tt.proc-acc1.
     end.


 end.
 run save-table in this-procedure .
 run make-other-table in this-procedure .
 /* run calc-other-table. */

/*++      end      ++*/


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
define variable v-exist         as logical   no-undo .

run waitfram-show in this-procedure ("Формирование таблицы оборотов...").
    for each x-analysis-obj :
      run waitfram-show in this-procedure ("Формирование таблицы оборотов...По объекту " + x-analysis-obj.obj-type + " " + string(x-analysis-obj.obj-code)).

            for each buf_gds-obj no-lock where
                buf_gds-obj.obj-type = x-analysis-obj.obj-type and
                buf_gds-obj.obj-code = x-analysis-obj.obj-code
                :
                if x-analysis.r-goods = 2 then do:
                   if not can-find( first gds-list where buf_gds-obj.gds-code = gds-list.gds-code) then next .
                end.

                run def-sum in this-procedure (
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
                  ,output v-slt-doc
                  ,output v-exist
                  ) .

                  if v-exist  = true then do:
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
                      run def-order in this-procedure (
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
define output parameter p-exist          as logical   no-undo .

define variable  p-date-1 as date   no-undo .
define variable  p-date-2 as date   no-undo .

define variable v-fact-order-1 as decimal   no-undo .
define variable v-fact-order-2 as decimal   no-undo .
define variable v-sum          as decimal   no-undo .


define buffer buf_aht-ot-line for ub.aht-ot-line.
p-exist = false .

find first x-analysis no-error .
if error-status :error then message error-status :get-message(1) "7770" view-as alert-box information .

for each tt-aht-ot-line : delete tt-aht-ot-line . end.

    for each x-analysis-period :
      assign
        p-date-1 = x-analysis-period.abcp-start
        p-date-2 = x-analysis-period.abcp-end
      .
      run day-begin-fact-order in this-procedure (input p-date-1 , output  v-fact-order-1).
      run factord-end-day in this-procedure       (input p-date-2 , output  v-fact-order-2).

      for each x-analysis-doc :
        repeat i = 1 to 5 :
            for each buf_aht-ot-line no-lock where
                    buf_aht-ot-line.ext-doc-type = x-analysis-doc.abcd-ext-doc-type and
                    buf_aht-ot-line.gds-code     = p-gds-code                       and
                    buf_aht-ot-line.obj-code     = p-obj-code                       and
                    buf_aht-ot-line.obj-type     = p-obj-type                       and
                    buf_aht-ot-line.sum-type     = v-i[i]                           and
                    buf_aht-ot-line.fact-order   >= v-fact-order-1                  and
                    buf_aht-ot-line.fact-order   <= v-fact-order-2
            :
                create tt-aht-ot-line.
                buffer-copy buf_aht-ot-line to tt-aht-ot-line .
                if buf_aht-ot-line.sum-type = {&aht-cons_benf} then do:   /* "b" - в количестве не учитывается (коммис.вознаграждение)*/
                   tt-aht-ot-line.fact-qnty  = 0 .
                end.
            end.
        end.
      end.
    end.
    /* проверка наличия остотка на последний день последнего периода */
    define buffer buf_aht-stk-line for ub.aht-stk-line  .
    repeat i = 1 to 5 :
        find last buf_aht-stk-line no-lock where
                        buf_aht-stk-line.gds-code     = p-gds-code and
                        buf_aht-stk-line.obj-code     = p-obj-code and
                        buf_aht-stk-line.obj-type     = p-obj-type and
                        buf_aht-stk-line.sum-type     = v-i[i]     and
                        buf_aht-stk-line.fact-order   <= v-fact-order-2  use-index category no-error .
        if  available buf_aht-stk-line and buf_aht-stk-line.fact-qnty <> 0 then do:
            p-exist = true  .
            leave.
        end.
    /*---------------------------------------------------------------------*/
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
    p-exist = true  .
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
            run calc-qnty in this-procedure (output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
        when 2
      /*"Оборот в учетных ценах в нац.валюте"
      "Реализовано по ценам из партий в нац.валюте"*/
        then do:
            run calc-str-oborot in this-procedure ( "rubl" , "cost" , "with-vat" , output v-sum).
        end.
        when 3
      /*"Оборот в ценах документа в нац.валюте"
      "Реализовано товара по ценам документа в нац.валюте"*/
        then do:
            run calc-str-oborot in this-procedure  ( "rubl" , "sale" , "with-vat" , output v-sum).
        end.
        when 4
      /*"Оборот в текущих продажных ценах в нац.валюте     "
      "Реализовано в текущих продажных ценах в нац.валюте "*/
        then do:
            run calc-str-oborot in this-procedure  ( "rubl" , "crsa" , "with-vat" , output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
        when 5
      /*"Оборот в учетных ценах в базовой валюте        "
      "Реализовано по ценам из партий в базовой валюте "*/
        then do:
          run calc-str-oborot in this-procedure  ( "base" , "cost" , "with-vat" , output v-sum).
        end.
        when 6
      /*"Оборот в ценах документа в баз.валюте"
      "Реализовано по ценам из документа в базовой валюте"*/
        then do:
            run calc-str-oborot in this-procedure  ( "base" , "sale" , "with-vat" , output v-sum).
        end.
        when 7
      /*"Оборот в текущих продажных ценах в базовой валюте"
      "Реализовано в текущих продажных ценах в базовой валюте"*/
        then do:
            run calc-str-oborot in this-procedure  ( "base" , "crsa" , "with-vat" , output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
        when 8
      /*"Прибыль с учетом налогов в нац.валюте"
      "Сумма реализ. товара в  ценах док. без налогов минус сумма в учетных ценах без налогов (нац.валюта)"*/
        then do:
          run calc-str-prib in this-procedure  ( "rubl" , "sale" , "cost" , "without-vat" , output v-sum).
        end.
        when 9
      /*"Прибыль с учетом налогов в базовой валюте"
      "Сумма реализ. товара в  ценах док. без налогов минус сумма в учетных ценах без налогов (баз. вал.)"*/
        then do:
            run calc-str-prib in this-procedure  ( "base" , "sale" , "cost" , "without-vat" , output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
        when 10
      /*"Прибыль в нац.валюте"
      "Сумма реализ. в  ценах док. минус сумма в учетных ценах (нац.валюта)"*/
        then do:
              run calc-str-prib in this-procedure  ( "rubl" , "sale" , "cost" , "with-vat" , output v-sum).
        end.
        when 11
      /*"Прибыль в базовой валюте"
      "Сумма реализ. в  ценах док. минус сумма в учетных ценах (баз. вал.)"*/
        then do:
              run calc-str-prib in this-procedure  ( "base" , "sale" , "cost" , "with-vat" , output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
        when 12
      /*"Потенциальная прибыль с учетом налогов в нац.валюте"
      "Сумма реализ. в  тек. прод ценах без налогов минус сумма в учетных ценах без налогов (нац.валюта)"*/
        then do:
              run calc-str-prib in this-procedure  ( "rubl" , "crsa" , "cost" , "without-vat" , output v-sum).
        end.
        when 13
      /*"Потенциальная прибыль с учетом налогов в базовой валюте"
      "Сумма реализ. в  тек. прод. ценах  без налогов минус сумма в учетных ценах без налогов (баз. вал.)"*/
        then do:
              run calc-str-prib in this-procedure  ( "base" , "crsa" , "cost" , "without-vat" , output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
        when 14
      /*"Потенциальная прибыль в нац.валюте"
      "Сумма реализ. товара в тек. прод. ценах  минус сумма в учетных ценах (нац.валюта)"*/
        then do:
              run calc-str-prib in this-procedure  ( "rubl" , "crsa" , "cost" , "with-vat" , output v-sum).
        end.
        when 15
      /*"Потенциальная прибыль в базовой валюте"
      "Сумма реализ. товара в тек. прод. ценах  минус сумма в учетных ценах (баз. вал.)"*/
        then do:
                run calc-str-prib in this-procedure  ( "base" , "crsa" , "cost" , "with-vat" , output v-sum).
        end.
      /*----------------------------------------------------------------------------------------------------------------------*/
      end case.

     v-sum-crit = v-sum-crit + v-sum .

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

for each x-analysis-period break by x-analysis-period.abcp-start desc :
 v-date-1 = x-analysis-period.abcp-start.
end.

for each x-analysis-period break by x-analysis-period.abcp-end  :
 v-date-2 = x-analysis-period.abcp-end.
end.

for each x-analysis-period break by x-analysis-period.abcp-start desc :
 v-day = v-day + ( x-analysis-period.abcp-end -  x-analysis-period.abcp-start + 1) .
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

procedure save-table :

  do
  on error undo, return error return-value
  :
define buffer buf_goods for ub.goods  .
define variable ii as integer   no-undo .

run waitfram-show in this-procedure ("Сохранение результатов анализа по объектам в БД...").
for each temp-oborot ,
    first temp-goods where
          temp-goods.gds-code = temp-oborot.gds-code
        :
        create ub.abc-analysis-gds-obj.
        assign
          ub.abc-analysis-gds-obj.abc-id = p-id
          ub.abc-analysis-gds-obj.db-num = p-db-num
          ub.abc-analysis-gds-obj.gds-code     = temp-oborot.gds-code
          ub.abc-analysis-gds-obj.obj-code     = temp-oborot.obj-code
          ub.abc-analysis-gds-obj.obj-type     = temp-oborot.obj-type
          ub.abc-analysis-gds-obj.abog-other-acc      =temp-oborot.other-acc
          ub.abc-analysis-gds-obj.abog-other-cur      =temp-oborot.other-cur
          ub.abc-analysis-gds-obj.abog-other-doc      =temp-oborot.other-doc
          ub.abc-analysis-gds-obj.abog-qnty           =temp-oborot.qnty
          ub.abc-analysis-gds-obj.abog-price-crc      =temp-oborot.price-crc
          ub.abc-analysis-gds-obj.abog-reserve-day    =temp-oborot.reserve-day
          ub.abc-analysis-gds-obj.abog-road-tax-acc   =temp-oborot.road-tax-acc
          ub.abc-analysis-gds-obj.abog-road-tax-cur   =temp-oborot.road-tax-cur
          ub.abc-analysis-gds-obj.abog-road-tax-doc   =temp-oborot.road-tax-doc
          ub.abc-analysis-gds-obj.abog-slt-acc        =temp-oborot.slt-acc
          ub.abc-analysis-gds-obj.abog-slt-cur        =temp-oborot.slt-cur
          ub.abc-analysis-gds-obj.abog-slt-doc        =temp-oborot.slt-doc
          ub.abc-analysis-gds-obj.abog-stock-qnty     =temp-oborot.stock-qnty
          ub.abc-analysis-gds-obj.abog-sum-acc        =temp-oborot.sum-acc
          ub.abc-analysis-gds-obj.abog-sum-cur        =temp-oborot.sum-cur
          ub.abc-analysis-gds-obj.abog-sum-doc        =temp-oborot.sum-doc
          ub.abc-analysis-gds-obj.abog-transport-acc  =temp-oborot.transport-acc
          ub.abc-analysis-gds-obj.abog-transport-cur   =temp-oborot.transport-cur
          ub.abc-analysis-gds-obj.abog-transport-doc   =temp-oborot.transport-doc
          ub.abc-analysis-gds-obj.abog-vat-acc     =temp-oborot.vat-acc
          ub.abc-analysis-gds-obj.abog-vat-cur     =temp-oborot.vat-cur
          ub.abc-analysis-gds-obj.abog-vat-doc     =temp-oborot.vat-doc
          ub.abc-analysis-gds-obj.abog-temp-sale-goods   = temp-oborot.qnty / v-day
        .
end.
run waitfram-show in this-procedure ("Сохранение результатов анализа по товарам в БД...").
define variable v-all-sum as decimal   no-undo .
define variable v-all-qnty as decimal   no-undo .
define variable v-a-sum  as decimal   no-undo .
define variable v-a-qnty as decimal   no-undo .
define variable v-b-sum  as decimal   no-undo .
define variable v-b-qnty as decimal   no-undo .
define variable v-c-sum  as decimal   no-undo .
define variable v-c-qnty as decimal   no-undo .
define variable v-d-sum  as decimal   no-undo .
define variable v-d-qnty as decimal   no-undo .
define variable v-e-sum  as decimal   no-undo .
define variable v-e-qnty as decimal   no-undo .
define variable v-f-sum  as decimal   no-undo .
define variable v-f-qnty as decimal   no-undo .


for each temp-goods :
    v-all-sum  = v-all-sum  + temp-goods.sum-crit .
    v-all-qnty = v-all-qnty + 1.

    case temp-goods.crit :
       when "A"
       then do:
            v-a-sum  = v-a-sum  + temp-goods.sum-crit .
            v-a-qnty = v-a-qnty + 1.
       end.
       when "B"
       then do:
            v-b-sum  = v-b-sum  + temp-goods.sum-crit .
            v-b-qnty = v-b-qnty + 1.
       end.
       when "C"
       then do:
            v-c-sum  = v-c-sum  + temp-goods.sum-crit .
            v-c-qnty = v-c-qnty + 1.
       end.
       when "D"
       then do:
            v-d-sum  = v-d-sum  + temp-goods.sum-crit .
            v-d-qnty = v-d-qnty + 1.
       end.
       when "E"
       then do:
            v-e-sum  = v-e-sum  + temp-goods.sum-crit .
            v-e-qnty = v-e-qnty + 1.
       end.
       when "F"
       then do:
            v-f-sum  = v-f-sum  + temp-goods.sum-crit .
            v-f-qnty = v-f-qnty + 1.
       end.


    end case.

    find first buf_goods no-lock  where  buf_goods.gds-code = temp-goods.gds-code no-error .

    create ub.abc-analysis-goods.
    assign
      ub.abc-analysis-goods.abc-id                 = p-id
      ub.abc-analysis-goods.db-num                 = p-db-num
      ub.abc-analysis-goods.gds-code               = temp-goods.gds-code
      ub.abc-analysis-goods.grp-code               = buf_goods.grp-code
      ub.abc-analysis-goods.prod-type              = buf_goods.prod-type
      ub.abc-analysis-goods.prod-code              = buf_goods.prod-code
      ub.abc-analysis-goods.abcg-abc               = temp-goods.crit
      ub.abc-analysis-goods.abcg-order-qnty        = temp-goods.order-qnty
      ub.abc-analysis-goods.abcg-other-acc         = temp-goods.other-acc
      ub.abc-analysis-goods.abcg-other-cur         = temp-goods.other-cur
      ub.abc-analysis-goods.abcg-other-doc         = temp-goods.other-doc
      ub.abc-analysis-goods.abcg-prcnt-for-estimate = temp-goods.crit-pr
      ub.abc-analysis-goods.abcg-prcnt-account     = temp-goods.prcnt-account
      ub.abc-analysis-goods.abcg-qnty              = temp-goods.qnty
      ub.abc-analysis-goods.abcg-road-tax-acc      = temp-goods.road-tax-acc
      ub.abc-analysis-goods.abcg-road-tax-cur      = temp-goods.road-tax-cur
      ub.abc-analysis-goods.abcg-road-tax-doc      = temp-goods.road-tax-doc
      ub.abc-analysis-goods.abcg-slt-acc           = temp-goods.slt-acc
      ub.abc-analysis-goods.abcg-slt-cur           = temp-goods.slt-cur
      ub.abc-analysis-goods.abcg-slt-doc           = temp-goods.slt-doc
      ub.abc-analysis-goods.abcg-stock-qnty        = temp-goods.stock-qnty
      ub.abc-analysis-goods.abcg-stock-price-acc   = temp-goods.stock-price-acc
      ub.abc-analysis-goods.abcg-stock-price-sale  = temp-goods.stock-price-sale
      ub.abc-analysis-goods.abcg-sum-acc           = temp-goods.sum-acc
      ub.abc-analysis-goods.abcg-sum-cur           = temp-goods.sum-cur
      ub.abc-analysis-goods.abcg-sum-doc           = temp-goods.sum-doc
      ub.abc-analysis-goods.abcg-sum-for-estimate  = temp-goods.sum-crit
      ub.abc-analysis-goods.abcg-temp-sale-goods   = temp-goods.qnty / v-day
      ub.abc-analysis-goods.abcg-transport-acc     = temp-goods.transport-acc
      ub.abc-analysis-goods.abcg-transport-cur     = temp-goods.transport-cur
      ub.abc-analysis-goods.abcg-transport-doc     = temp-goods.transport-doc
      ub.abc-analysis-goods.abcg-vat-acc           = temp-goods.vat-acc
      ub.abc-analysis-goods.abcg-vat-cur           = temp-goods.vat-cur
      ub.abc-analysis-goods.abcg-vat-doc           = temp-goods.vat-doc
      .
end.



for each ub.abc-analysis-goods  exclusive-lock where
      ub.abc-analysis-goods.abc-id  = p-id and
      ub.abc-analysis-goods.db-num  = p-db-num  break
        by ub.abc-analysis-goods.abcg-abc
        by ub.abc-analysis-goods.abcg-prcnt-for-estimate desc :
 if first-of (ub.abc-analysis-goods.abcg-abc ) then do:
    ii = 0 .
 end.
 ii = ii + 1.
 ub.abc-analysis-goods.proc-from-all =  ub.abc-analysis-goods.abcg-sum-for-estimate  * 100 / v-all-sum .
 ub.abc-analysis-goods.rating = ii .
end.


find current x-analysis  no-error .
assign
x-analysis.abc-a-prc-qnty   = v-a-qnty * 100 / v-all-qnty
x-analysis.abc-a-qnty       = v-a-qnty
x-analysis.abc-a-sum-prc    = v-a-sum * 100 / v-all-sum
x-analysis.abc-a-sum        = v-a-sum

x-analysis.abc-b-prc-qnty   = v-b-qnty * 100 / v-all-qnty
x-analysis.abc-b-qnty       = v-b-qnty
x-analysis.abc-b-sum-prc    = v-b-sum * 100 / v-all-sum
x-analysis.abc-b-sum        = v-b-sum

x-analysis.abc-c-prc-qnty   = v-c-qnty * 100 / v-all-qnty
x-analysis.abc-c-qnty       = v-c-qnty
x-analysis.abc-c-sum-prc    = v-c-sum * 100 / v-all-sum
x-analysis.abc-c-sum        = v-c-sum

x-analysis.abc-d-prc-qnty   = v-d-qnty * 100 / v-all-qnty
x-analysis.abc-d-qnty       = v-d-qnty
x-analysis.abc-d-sum-prc    = v-d-sum * 100 / v-all-sum
x-analysis.abc-d-sum        = v-d-sum

x-analysis.abc-e-prc-qnty   = v-e-qnty * 100 / v-all-qnty
x-analysis.abc-e-qnty       = v-e-qnty
x-analysis.abc-e-sum-prc    = v-e-sum * 100 / v-all-sum
x-analysis.abc-e-sum        = v-e-sum

x-analysis.abc-f-prc-qnty   = v-f-qnty * 100 / v-all-qnty
x-analysis.abc-f-qnty       = v-f-qnty
x-analysis.abc-f-sum-prc    = v-f-sum * 100 / v-all-sum
x-analysis.abc-f-sum        = v-f-sum
.

define variable v-doc-rec as recid no-undo .
define buffer buf_abc-analysis for ub.abc-analysis.
find first buf_abc-analysis no-lock where
            buf_abc-analysis.abc-id                 = p-id and
            buf_abc-analysis.db-num                 = p-db-num no-error .

 v-doc-rec = recid(buf_abc-analysis) .

 run ref/abcanal1.p
              (  input-output v-doc-rec
                ,{&update}
                ,table x-analysis
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
              buf-ord-line.artic    =   p-artic              and
              buf-ord-line.prod-type          =   p-prod-type and
              buf-ord-line.prod-code          =   p-prod-code  ,
          first buf-ord-doc no-lock where
                buf-ord-doc.doc-code          =   buf-ord-line.doc-code and
                buf-ord-doc.obj-type          =   p-obj-type and
                buf-ord-doc.obj-code          =   p-obj-code and
                buf-ord-doc.status_           <>   {&fact}    and
                buf-ord-doc.status_           <>   {&g___new}  and
                buf-ord-doc.doc-date         <=  v-date-2   and
                buf-ord-doc.doc-date         >=  v-date-1
                :
          for each x-analysis-period :
            if buf-ord-doc.doc-date >= x-analysis-period.abcp-start and
               buf-ord-doc.doc-date <= x-analysis-period.abcp-end
                then do:
                  v-qnty =  v-qnty + buf-ord-line.qnty .
                end.
          end.
      end.
  end.

end procedure. /* def-order */

procedure save-table-duble :
define buffer buf_goods for ub.goods  .
  do
  on error undo, return error return-value
  :
run waitfram-show in this-procedure ( "Сохранение результатов анализа по объектам в БД...").
for each temp-oborot1 ,
    first temp-goods1 where
          temp-goods1.gds-code = temp-oborot1.gds-code
        :
        create ub.abc-analysis-gds-obj.
        assign
          ub.abc-analysis-gds-obj.abc-id              = p-id
          ub.abc-analysis-gds-obj.db-num              = p-db-num
          ub.abc-analysis-gds-obj.gds-code            = temp-oborot1.gds-code
          ub.abc-analysis-gds-obj.obj-code            = temp-oborot1.obj-code
          ub.abc-analysis-gds-obj.obj-type            = temp-oborot1.obj-type
          ub.abc-analysis-gds-obj.abog-other-acc      =temp-oborot1.other-acc
          ub.abc-analysis-gds-obj.abog-other-cur      =temp-oborot1.other-cur
          ub.abc-analysis-gds-obj.abog-other-doc      =temp-oborot1.other-doc
          ub.abc-analysis-gds-obj.abog-qnty           =temp-oborot1.qnty
          ub.abc-analysis-gds-obj.abog-price-crc      =temp-oborot1.price-crc
          ub.abc-analysis-gds-obj.abog-reserve-day    =temp-oborot1.reserve-day
          ub.abc-analysis-gds-obj.abog-road-tax-acc   =temp-oborot1.road-tax-acc
          ub.abc-analysis-gds-obj.abog-road-tax-cur   =temp-oborot1.road-tax-cur
          ub.abc-analysis-gds-obj.abog-road-tax-doc   =temp-oborot1.road-tax-doc
          ub.abc-analysis-gds-obj.abog-slt-acc        =temp-oborot1.slt-acc
          ub.abc-analysis-gds-obj.abog-slt-cur        =temp-oborot1.slt-cur
          ub.abc-analysis-gds-obj.abog-slt-doc        =temp-oborot1.slt-doc
          ub.abc-analysis-gds-obj.abog-stock-qnty     =temp-oborot1.stock-qnty
          ub.abc-analysis-gds-obj.abog-sum-acc        =temp-oborot1.sum-acc
          ub.abc-analysis-gds-obj.abog-sum-cur        =temp-oborot1.sum-cur
          ub.abc-analysis-gds-obj.abog-sum-doc        =temp-oborot1.sum-doc
          ub.abc-analysis-gds-obj.abog-transport-acc  =temp-oborot1.transport-acc
          ub.abc-analysis-gds-obj.abog-transport-cur   =temp-oborot1.transport-cur
          ub.abc-analysis-gds-obj.abog-transport-doc   =temp-oborot1.transport-doc
          ub.abc-analysis-gds-obj.abog-vat-acc     =temp-oborot1.vat-acc
          ub.abc-analysis-gds-obj.abog-vat-cur     =temp-oborot1.vat-cur
          ub.abc-analysis-gds-obj.abog-vat-doc     =temp-oborot1.vat-doc
          ub.abc-analysis-gds-obj.abog-temp-sale-goods   = temp-oborot1.qnty / v-day
        .
end.

for each temp-oborot2 ,
    first temp-goods2 where
          temp-goods2.gds-code = temp-oborot2.gds-code
        :
        create ub.abc-analysis-gds-obj.
        assign
          ub.abc-analysis-gds-obj.abc-id = p-id
          ub.abc-analysis-gds-obj.db-num = p-db-num
          ub.abc-analysis-gds-obj.gds-code     = temp-oborot2.gds-code
          ub.abc-analysis-gds-obj.obj-code     = temp-oborot2.obj-code
          ub.abc-analysis-gds-obj.obj-type     = temp-oborot2.obj-type
          ub.abc-analysis-gds-obj.abog-other-acc      =temp-oborot2.other-acc
          ub.abc-analysis-gds-obj.abog-other-cur      =temp-oborot2.other-cur
          ub.abc-analysis-gds-obj.abog-other-doc      =temp-oborot2.other-doc
          ub.abc-analysis-gds-obj.abog-qnty           =temp-oborot2.qnty
          ub.abc-analysis-gds-obj.abog-price-crc      =temp-oborot2.price-crc
          ub.abc-analysis-gds-obj.abog-reserve-day    =temp-oborot2.reserve-day
          ub.abc-analysis-gds-obj.abog-road-tax-acc   =temp-oborot2.road-tax-acc
          ub.abc-analysis-gds-obj.abog-road-tax-cur   =temp-oborot2.road-tax-cur
          ub.abc-analysis-gds-obj.abog-road-tax-doc   =temp-oborot2.road-tax-doc
          ub.abc-analysis-gds-obj.abog-slt-acc        =temp-oborot2.slt-acc
          ub.abc-analysis-gds-obj.abog-slt-cur        =temp-oborot2.slt-cur
          ub.abc-analysis-gds-obj.abog-slt-doc        =temp-oborot2.slt-doc
          ub.abc-analysis-gds-obj.abog-stock-qnty     =temp-oborot2.stock-qnty
          ub.abc-analysis-gds-obj.abog-sum-acc        =temp-oborot2.sum-acc
          ub.abc-analysis-gds-obj.abog-sum-cur        =temp-oborot2.sum-cur
          ub.abc-analysis-gds-obj.abog-sum-doc        =temp-oborot2.sum-doc
          ub.abc-analysis-gds-obj.abog-transport-acc  =temp-oborot2.transport-acc
          ub.abc-analysis-gds-obj.abog-transport-cur   =temp-oborot2.transport-cur
          ub.abc-analysis-gds-obj.abog-transport-doc   =temp-oborot2.transport-doc
          ub.abc-analysis-gds-obj.abog-vat-acc     =temp-oborot2.vat-acc
          ub.abc-analysis-gds-obj.abog-vat-cur     =temp-oborot2.vat-cur
          ub.abc-analysis-gds-obj.abog-vat-doc     =temp-oborot2.vat-doc
          ub.abc-analysis-gds-obj.abog-temp-sale-goods   = temp-oborot2.qnty / v-day
        .
end.

run waitfram-show in this-procedure  ("Сохранение результатов анализа по товарам в БД...").
define variable v-all-sum as decimal   no-undo .
define variable v-all-qnty as decimal   no-undo .
define variable v-a-sum  as decimal   no-undo .
define variable v-a-qnty as decimal   no-undo .
define variable v-b-sum  as decimal   no-undo .
define variable v-b-qnty as decimal   no-undo .
define variable v-c-sum  as decimal   no-undo .
define variable v-c-qnty as decimal   no-undo .
define variable v-d-sum  as decimal   no-undo .
define variable v-d-qnty as decimal   no-undo .
define variable v-e-sum  as decimal   no-undo .
define variable v-e-qnty as decimal   no-undo .
define variable v-f-sum  as decimal   no-undo .
define variable v-f-qnty as decimal   no-undo .


for each temp-goods1  :
    v-all-sum  = v-all-sum  + temp-goods1.sum-crit .
    v-all-qnty = v-all-qnty + 1.

    case temp-goods1.crit :
       when "A"
       then do:
            v-a-sum  = v-a-sum  + temp-goods1.sum-crit .
            v-a-qnty = v-a-qnty + 1.
       end.
       when "B"
       then do:
            v-b-sum  = v-b-sum  + temp-goods1.sum-crit .
            v-b-qnty = v-b-qnty + 1.
       end.
       when "C"
       then do:
            v-c-sum  = v-c-sum  + temp-goods1.sum-crit .
            v-c-qnty = v-c-qnty + 1.
       end.
       when "D"
       then do:
            v-d-sum  = v-d-sum  + temp-goods1.sum-crit .
            v-d-qnty = v-d-qnty + 1.
       end.
       when "E"
       then do:
            v-e-sum  = v-e-sum  + temp-goods1.sum-crit .
            v-e-qnty = v-e-qnty + 1.
       end.
       when "F"
       then do:
            v-f-sum  = v-f-sum  + temp-goods1.sum-crit .
            v-f-qnty = v-f-qnty + 1.
       end.
    end case.
    find first buf_goods no-lock  where  buf_goods.gds-code = temp-goods1.gds-code no-error .
    create ub.abc-analysis-goods.
    assign
      ub.abc-analysis-goods.abc-id                 = p-id
      ub.abc-analysis-goods.db-num                 = p-db-num
      ub.abc-analysis-goods.gds-code               = temp-goods1.gds-code
      ub.abc-analysis-goods.grp-code               = buf_goods.grp-code
      ub.abc-analysis-goods.prod-type              = buf_goods.prod-type
      ub.abc-analysis-goods.prod-code              = buf_goods.prod-code

      ub.abc-analysis-goods.abcg-abc               = temp-goods1.crit
      ub.abc-analysis-goods.abcg-order-qnty        = temp-goods1.order-qnty
      ub.abc-analysis-goods.abcg-other-acc         = temp-goods1.other-acc
      ub.abc-analysis-goods.abcg-other-cur         = temp-goods1.other-cur
      ub.abc-analysis-goods.abcg-other-doc         = temp-goods1.other-doc
      ub.abc-analysis-goods.abcg-prcnt-for-estimate = temp-goods1.crit-pr
      ub.abc-analysis-goods.abcg-prcnt-account     = temp-goods1.prcnt-account
      ub.abc-analysis-goods.abcg-qnty              = temp-goods1.qnty
      ub.abc-analysis-goods.abcg-road-tax-acc      = temp-goods1.road-tax-acc
      ub.abc-analysis-goods.abcg-road-tax-cur      = temp-goods1.road-tax-cur
      ub.abc-analysis-goods.abcg-road-tax-doc      = temp-goods1.road-tax-doc
      ub.abc-analysis-goods.abcg-slt-acc           = temp-goods1.slt-acc
      ub.abc-analysis-goods.abcg-slt-cur           = temp-goods1.slt-cur
      ub.abc-analysis-goods.abcg-slt-doc           = temp-goods1.slt-doc
      ub.abc-analysis-goods.abcg-stock-qnty        = temp-goods1.stock-qnty
      ub.abc-analysis-goods.abcg-stock-price-acc   = temp-goods1.stock-price-acc
      ub.abc-analysis-goods.abcg-stock-price-sale  = temp-goods1.stock-price-sale
      ub.abc-analysis-goods.abcg-sum-acc           = temp-goods1.sum-acc
      ub.abc-analysis-goods.abcg-sum-cur           = temp-goods1.sum-cur
      ub.abc-analysis-goods.abcg-sum-doc           = temp-goods1.sum-doc
      ub.abc-analysis-goods.abcg-sum-for-estimate  = temp-goods1.sum-crit
      ub.abc-analysis-goods.abcg-temp-sale-goods   = temp-goods1.qnty / v-day
      ub.abc-analysis-goods.abcg-transport-acc     = temp-goods1.transport-acc
      ub.abc-analysis-goods.abcg-transport-cur     = temp-goods1.transport-cur
      ub.abc-analysis-goods.abcg-transport-doc     = temp-goods1.transport-doc
      ub.abc-analysis-goods.abcg-vat-acc           = temp-goods1.vat-acc
      ub.abc-analysis-goods.abcg-vat-cur           = temp-goods1.vat-cur
      ub.abc-analysis-goods.abcg-vat-doc           = temp-goods1.vat-doc
      .
end.

for each temp-goods2  :
    v-all-sum  = v-all-sum  + temp-goods2.sum-crit .
    v-all-qnty = v-all-qnty + 1.

    case temp-goods2.crit :
       when "A"
       then do:
            v-a-sum  = v-a-sum  + temp-goods2.sum-crit .
            v-a-qnty = v-a-qnty + 1.
       end.
       when "B"
       then do:
            v-b-sum  = v-b-sum  + temp-goods2.sum-crit .
            v-b-qnty = v-b-qnty + 1.
       end.
       when "C"
       then do:
            v-c-sum  = v-c-sum  + temp-goods2.sum-crit .
            v-c-qnty = v-c-qnty + 1.
       end.
       when "D"
       then do:
            v-d-sum  = v-d-sum  + temp-goods2.sum-crit .
            v-d-qnty = v-d-qnty + 1.
       end.
       when "E"
       then do:
            v-e-sum  = v-e-sum  + temp-goods2.sum-crit .
            v-e-qnty = v-e-qnty + 1.
       end.
       when "F"
       then do:
            v-f-sum  = v-f-sum  + temp-goods2.sum-crit .
            v-f-qnty = v-f-qnty + 1.
       end.

    end case.
    find first buf_goods no-lock  where  buf_goods.gds-code = temp-goods2.gds-code no-error .
    create ub.abc-analysis-goods.
    assign
      ub.abc-analysis-goods.abc-id                 = p-id
      ub.abc-analysis-goods.db-num                 = p-db-num
      ub.abc-analysis-goods.gds-code               = temp-goods2.gds-code
      ub.abc-analysis-goods.grp-code               = buf_goods.grp-code
      ub.abc-analysis-goods.prod-type              = buf_goods.prod-type
      ub.abc-analysis-goods.prod-code              = buf_goods.prod-code
      ub.abc-analysis-goods.abcg-abc               = temp-goods2.crit
      ub.abc-analysis-goods.abcg-order-qnty        = temp-goods2.order-qnty
      ub.abc-analysis-goods.abcg-other-acc         = temp-goods2.other-acc
      ub.abc-analysis-goods.abcg-other-cur         = temp-goods2.other-cur
      ub.abc-analysis-goods.abcg-other-doc         = temp-goods2.other-doc
      ub.abc-analysis-goods.abcg-prcnt-for-estimate = temp-goods2.crit-pr
      ub.abc-analysis-goods.abcg-prcnt-account     = temp-goods2.prcnt-account
      ub.abc-analysis-goods.abcg-qnty              = temp-goods2.qnty
      ub.abc-analysis-goods.abcg-road-tax-acc      = temp-goods2.road-tax-acc
      ub.abc-analysis-goods.abcg-road-tax-cur      = temp-goods2.road-tax-cur
      ub.abc-analysis-goods.abcg-road-tax-doc      = temp-goods2.road-tax-doc
      ub.abc-analysis-goods.abcg-slt-acc           = temp-goods2.slt-acc
      ub.abc-analysis-goods.abcg-slt-cur           = temp-goods2.slt-cur
      ub.abc-analysis-goods.abcg-slt-doc           = temp-goods2.slt-doc
      ub.abc-analysis-goods.abcg-stock-qnty        = temp-goods2.stock-qnty
      ub.abc-analysis-goods.abcg-stock-price-acc   = temp-goods2.stock-price-acc
      ub.abc-analysis-goods.abcg-stock-price-sale  = temp-goods2.stock-price-sale
      ub.abc-analysis-goods.abcg-sum-acc           = temp-goods2.sum-acc
      ub.abc-analysis-goods.abcg-sum-cur           = temp-goods2.sum-cur
      ub.abc-analysis-goods.abcg-sum-doc           = temp-goods2.sum-doc
      ub.abc-analysis-goods.abcg-sum-for-estimate  = temp-goods2.sum-crit
      ub.abc-analysis-goods.abcg-temp-sale-goods   = temp-goods2.qnty / v-day
      ub.abc-analysis-goods.abcg-transport-acc     = temp-goods2.transport-acc
      ub.abc-analysis-goods.abcg-transport-cur     = temp-goods2.transport-cur
      ub.abc-analysis-goods.abcg-transport-doc     = temp-goods2.transport-doc
      ub.abc-analysis-goods.abcg-vat-acc           = temp-goods2.vat-acc
      ub.abc-analysis-goods.abcg-vat-cur           = temp-goods2.vat-cur
      ub.abc-analysis-goods.abcg-vat-doc           = temp-goods2.vat-doc
      .
end.

find current x-analysis  no-error .
assign
x-analysis.abc-a-prc-qnty   = v-a-qnty * 100 / v-all-qnty
x-analysis.abc-a-qnty       = v-a-qnty
x-analysis.abc-a-sum-prc    = v-a-sum * 100 / v-all-sum
x-analysis.abc-a-sum        = v-a-sum

x-analysis.abc-b-prc-qnty   = v-b-qnty * 100 / v-all-qnty
x-analysis.abc-b-qnty       = v-b-qnty
x-analysis.abc-b-sum-prc    = v-b-sum * 100 / v-all-sum
x-analysis.abc-b-sum        = v-b-sum

x-analysis.abc-c-prc-qnty   = v-c-qnty * 100 / v-all-qnty
x-analysis.abc-c-qnty       = v-c-qnty
x-analysis.abc-c-sum-prc    = v-c-sum * 100 / v-all-sum
x-analysis.abc-c-sum        = v-c-sum

x-analysis.abc-d-prc-qnty   = v-d-qnty * 100 / v-all-qnty
x-analysis.abc-d-qnty       = v-d-qnty
x-analysis.abc-d-sum-prc    = v-d-sum * 100 / v-all-sum
x-analysis.abc-d-sum        = v-d-sum

x-analysis.abc-e-prc-qnty   = v-e-qnty * 100 / v-all-qnty
x-analysis.abc-e-qnty       = v-e-qnty
x-analysis.abc-e-sum-prc    = v-e-sum * 100 / v-all-sum
x-analysis.abc-e-sum        = v-e-sum

x-analysis.abc-f-prc-qnty   = v-f-qnty * 100 / v-all-qnty
x-analysis.abc-f-qnty       = v-f-qnty
x-analysis.abc-f-sum-prc    = v-f-sum * 100 / v-all-sum
x-analysis.abc-f-sum        = v-f-sum
.
define variable ii as integer   no-undo .
for each ub.abc-analysis-goods  exclusive-lock where
      ub.abc-analysis-goods.abc-id  = p-id and
      ub.abc-analysis-goods.db-num  = p-db-num  break
        by ub.abc-analysis-goods.abcg-abc
        by ub.abc-analysis-goods.abcg-prcnt-for-estimate desc :
 if first-of (ub.abc-analysis-goods.abcg-abc ) then do:
    ii = 0 .
 end.
 ii = ii + 1.
 ub.abc-analysis-goods.proc-from-all =  ub.abc-analysis-goods.abcg-sum-for-estimate  * 100 / v-all-sum .
 ub.abc-analysis-goods.rating = ii .
end.


define variable v-doc-rec as recid no-undo .
define buffer buf_abc-analysis for ub.abc-analysis.
find first buf_abc-analysis no-lock where
            buf_abc-analysis.abc-id                 = p-id and
            buf_abc-analysis.db-num                 = p-db-num no-error .

 v-doc-rec = recid(buf_abc-analysis) .

 run ref/abcanal1.p
 (              input-output v-doc-rec
                ,{&update}
                ,table x-analysis
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


procedure make-other-table :

  do
  on error undo, return error return-value
  :

run waitfram-show in this-procedure ("Разбивка по группам и по производителям...").
define buffer buf_goods for ub.goods  .
define buffer buf_abc-analysis-goods for ub.abc-analysis-goods  .
define variable v-all-sum as decimal   no-undo init 0.

  for each buf_abc-analysis-goods no-lock where
      buf_abc-analysis-goods.abc-id  = p-id and
      buf_abc-analysis-goods.db-num  = p-db-num
      :


      find first buf_goods no-lock WHERE buf_goods.gds-code = buf_abc-analysis-goods.gds-code no-error  .
      if error-status :error then do:
        message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "Не найден товар с кодом " buf_abc-analysis-goods.gds-code
            view-as alert-box error
        .
        next.
      end.
       find first ub.abc-analysis-prod exclusive-lock where
                  ub.abc-analysis-prod.abc-id =  p-id     and
                  ub.abc-analysis-prod.db-num =  p-db-num and
                  ub.abc-analysis-prod.prod-type =  buf_goods.prod-type and
                  ub.abc-analysis-prod.prod-code =  buf_goods.prod-code no-error .
             if not available ub.abc-analysis-prod then do:
                create ub.abc-analysis-prod.
             end.
             assign
                  ub.abc-analysis-prod.abc-id =  p-id
                  ub.abc-analysis-prod.db-num =  p-db-num
                  ub.abc-analysis-prod.prod-type =  buf_goods.prod-type
                  ub.abc-analysis-prod.prod-code =  buf_goods.prod-code
                  ub.abc-analysis-prod.abcg-other-acc            =  ub.abc-analysis-prod.abcg-other-acc           + buf_abc-analysis-goods.abcg-other-acc
                  ub.abc-analysis-prod.abcg-other-cur            =  ub.abc-analysis-prod.abcg-other-cur           + buf_abc-analysis-goods.abcg-other-cur
                  ub.abc-analysis-prod.abcg-other-doc            =  ub.abc-analysis-prod.abcg-other-doc           + buf_abc-analysis-goods.abcg-other-doc
                  ub.abc-analysis-prod.abcg-prcnt-for-estimate   =  ub.abc-analysis-prod.abcg-prcnt-for-estimate  + buf_abc-analysis-goods.abcg-prcnt-for-estimate
                  ub.abc-analysis-prod.abcg-qnty                 =  ub.abc-analysis-prod.abcg-qnty                + buf_abc-analysis-goods.abcg-qnty
                  ub.abc-analysis-prod.abcg-road-tax-acc         =  ub.abc-analysis-prod.abcg-road-tax-acc        + buf_abc-analysis-goods.abcg-road-tax-acc
                  ub.abc-analysis-prod.abcg-road-tax-cur         =  ub.abc-analysis-prod.abcg-road-tax-cur        + buf_abc-analysis-goods.abcg-road-tax-cur
                  ub.abc-analysis-prod.abcg-road-tax-doc         =  ub.abc-analysis-prod.abcg-road-tax-doc        + buf_abc-analysis-goods.abcg-road-tax-doc
                  ub.abc-analysis-prod.abcg-slt-acc              =  ub.abc-analysis-prod.abcg-slt-acc             + buf_abc-analysis-goods.abcg-slt-acc
                  ub.abc-analysis-prod.abcg-slt-cur              =  ub.abc-analysis-prod.abcg-slt-cur             + buf_abc-analysis-goods.abcg-slt-cur
                  ub.abc-analysis-prod.abcg-slt-doc              =  ub.abc-analysis-prod.abcg-slt-doc             + buf_abc-analysis-goods.abcg-slt-doc
                  ub.abc-analysis-prod.abcg-stock-price-acc      =  ub.abc-analysis-prod.abcg-stock-price-acc     + buf_abc-analysis-goods.abcg-stock-price-acc
                  ub.abc-analysis-prod.abcg-stock-price-sale     =  ub.abc-analysis-prod.abcg-stock-price-sale    + buf_abc-analysis-goods.abcg-stock-price-sale
                  ub.abc-analysis-prod.abcg-stock-qnty           =  ub.abc-analysis-prod.abcg-stock-qnty          + buf_abc-analysis-goods.abcg-stock-qnty
                  ub.abc-analysis-prod.abcg-sum-acc              =  ub.abc-analysis-prod.abcg-sum-acc             + buf_abc-analysis-goods.abcg-sum-acc
                  ub.abc-analysis-prod.abcg-sum-cur              =  ub.abc-analysis-prod.abcg-sum-cur             + buf_abc-analysis-goods.abcg-sum-cur
                  ub.abc-analysis-prod.abcg-sum-doc              =  ub.abc-analysis-prod.abcg-sum-doc             + buf_abc-analysis-goods.abcg-sum-doc
                  ub.abc-analysis-prod.abcg-sum-for-estimate     =  ub.abc-analysis-prod.abcg-sum-for-estimate    + buf_abc-analysis-goods.abcg-sum-for-estimate
                  ub.abc-analysis-prod.abcg-transport-acc        =  ub.abc-analysis-prod.abcg-transport-acc       + buf_abc-analysis-goods.abcg-transport-acc
                  ub.abc-analysis-prod.abcg-transport-cur        =  ub.abc-analysis-prod.abcg-transport-cur       + buf_abc-analysis-goods.abcg-transport-cur
                  ub.abc-analysis-prod.abcg-transport-doc        =  ub.abc-analysis-prod.abcg-transport-doc       + buf_abc-analysis-goods.abcg-transport-doc
                  ub.abc-analysis-prod.abcg-vat-acc              =  ub.abc-analysis-prod.abcg-vat-acc             + buf_abc-analysis-goods.abcg-vat-acc
                  ub.abc-analysis-prod.abcg-vat-cur              =  ub.abc-analysis-prod.abcg-vat-cur             + buf_abc-analysis-goods.abcg-vat-cur
                  ub.abc-analysis-prod.abcg-vat-doc              =  ub.abc-analysis-prod.abcg-vat-doc             + buf_abc-analysis-goods.abcg-vat-doc
             .
       find first ub.abc-analysis-grp exclusive-lock where
                  ub.abc-analysis-grp.abc-id =  p-id and
                  ub.abc-analysis-grp.db-num =  p-db-num and
                  ub.abc-analysis-grp.grp-code =  buf_goods.grp-code no-error .
             if not available ub.abc-analysis-grp then do:
                create ub.abc-analysis-grp.
             end.
             assign
                  ub.abc-analysis-grp.abc-id =  p-id
                  ub.abc-analysis-grp.db-num =  p-db-num
                  ub.abc-analysis-grp.grp-code =  buf_goods.grp-code
                  ub.abc-analysis-grp.abcg-other-acc            =  ub.abc-analysis-grp.abcg-other-acc           + buf_abc-analysis-goods.abcg-other-acc
                  ub.abc-analysis-grp.abcg-other-cur            =  ub.abc-analysis-grp.abcg-other-cur           + buf_abc-analysis-goods.abcg-other-cur
                  ub.abc-analysis-grp.abcg-other-doc            =  ub.abc-analysis-grp.abcg-other-doc           + buf_abc-analysis-goods.abcg-other-doc
                  ub.abc-analysis-grp.abcg-prcnt-for-estimate   =  ub.abc-analysis-grp.abcg-prcnt-for-estimate  + buf_abc-analysis-goods.abcg-prcnt-for-estimate
                  ub.abc-analysis-grp.abcg-qnty                 =  ub.abc-analysis-grp.abcg-qnty                + buf_abc-analysis-goods.abcg-qnty
                  ub.abc-analysis-grp.abcg-road-tax-acc         =  ub.abc-analysis-grp.abcg-road-tax-acc        + buf_abc-analysis-goods.abcg-road-tax-acc
                  ub.abc-analysis-grp.abcg-road-tax-cur         =  ub.abc-analysis-grp.abcg-road-tax-cur        + buf_abc-analysis-goods.abcg-road-tax-cur
                  ub.abc-analysis-grp.abcg-road-tax-doc         =  ub.abc-analysis-grp.abcg-road-tax-doc        + buf_abc-analysis-goods.abcg-road-tax-doc
                  ub.abc-analysis-grp.abcg-slt-acc              =  ub.abc-analysis-grp.abcg-slt-acc             + buf_abc-analysis-goods.abcg-slt-acc
                  ub.abc-analysis-grp.abcg-slt-cur              =  ub.abc-analysis-grp.abcg-slt-cur             + buf_abc-analysis-goods.abcg-slt-cur
                  ub.abc-analysis-grp.abcg-slt-doc              =  ub.abc-analysis-grp.abcg-slt-doc             + buf_abc-analysis-goods.abcg-slt-doc
                  ub.abc-analysis-grp.abcg-stock-price-acc      =  ub.abc-analysis-grp.abcg-stock-price-acc     + buf_abc-analysis-goods.abcg-stock-price-acc
                  ub.abc-analysis-grp.abcg-stock-price-sale     =  ub.abc-analysis-grp.abcg-stock-price-sale    + buf_abc-analysis-goods.abcg-stock-price-sale
                  ub.abc-analysis-grp.abcg-stock-qnty           =  ub.abc-analysis-grp.abcg-stock-qnty          + buf_abc-analysis-goods.abcg-stock-qnty
                  ub.abc-analysis-grp.abcg-sum-acc              =  ub.abc-analysis-grp.abcg-sum-acc             + buf_abc-analysis-goods.abcg-sum-acc
                  ub.abc-analysis-grp.abcg-sum-cur              =  ub.abc-analysis-grp.abcg-sum-cur             + buf_abc-analysis-goods.abcg-sum-cur
                  ub.abc-analysis-grp.abcg-sum-doc              =  ub.abc-analysis-grp.abcg-sum-doc             + buf_abc-analysis-goods.abcg-sum-doc
                  ub.abc-analysis-grp.abcg-sum-for-estimate     =  ub.abc-analysis-grp.abcg-sum-for-estimate    + buf_abc-analysis-goods.abcg-sum-for-estimate
                  ub.abc-analysis-grp.abcg-transport-acc        =  ub.abc-analysis-grp.abcg-transport-acc       + buf_abc-analysis-goods.abcg-transport-acc
                  ub.abc-analysis-grp.abcg-transport-cur        =  ub.abc-analysis-grp.abcg-transport-cur       + buf_abc-analysis-goods.abcg-transport-cur
                  ub.abc-analysis-grp.abcg-transport-doc        =  ub.abc-analysis-grp.abcg-transport-doc       + buf_abc-analysis-goods.abcg-transport-doc
                  ub.abc-analysis-grp.abcg-vat-acc              =  ub.abc-analysis-grp.abcg-vat-acc             + buf_abc-analysis-goods.abcg-vat-acc
                  ub.abc-analysis-grp.abcg-vat-cur              =  ub.abc-analysis-grp.abcg-vat-cur             + buf_abc-analysis-goods.abcg-vat-cur
                  ub.abc-analysis-grp.abcg-vat-doc              =  ub.abc-analysis-grp.abcg-vat-doc             + buf_abc-analysis-goods.abcg-vat-doc
                  .
  end.

for each temp-goods :
    v-all-sum  = v-all-sum  + temp-goods.sum-crit .
end.

define variable ii as integer   no-undo .

 for each temp-tt : delete temp-tt . end.
 for each ub.abc-analysis-grp  no-lock where
      ub.abc-analysis-grp.abc-id  = p-id and
      ub.abc-analysis-grp.db-num  = p-db-num :
     create temp-tt.
     assign
       temp-tt.id = recid(ub.abc-analysis-grp)
       temp-tt.summa = ub.abc-analysis-grp.abcg-sum-for-estimate
     .
 end.
 run ref/tt-abc.p
      ( input table x-analysis
      , input-output table temp-tt )
  .

for each temp-tt  break
        by temp-tt.abc
        by temp-tt.proc desc :

      if first-of (temp-tt.abc ) then do:
          ii = 0 .
      end.
      ii = ii + 1.
      find first ub.abc-analysis-grp  exclusive-lock where  recid (ub.abc-analysis-grp) = temp-tt.id no-error .
          if available ub.abc-analysis-grp then do:
              ub.abc-analysis-grp.abcg-abc      =  temp-tt.abc.
              ub.abc-analysis-grp.proc-from-all =  ub.abc-analysis-grp.abcg-sum-for-estimate  * 100 / v-all-sum .
              ub.abc-analysis-grp.rating        = ii .
          end.
end.

 for each temp-tt : delete temp-tt . end.
 for each ub.abc-analysis-prod  no-lock where
      ub.abc-analysis-prod.abc-id  = p-id and
      ub.abc-analysis-prod.db-num  = p-db-num :
     create temp-tt.
     assign
       temp-tt.id = recid(ub.abc-analysis-prod)
       temp-tt.summa = ub.abc-analysis-prod.abcg-sum-for-estimate
     .
 end.
 run ref/tt-abc.p
      ( input table x-analysis
      , input-output table temp-tt )
  .

for each temp-tt  break
        by temp-tt.abc
        by temp-tt.proc desc :

      if first-of (temp-tt.abc ) then do:
          ii = 0 .
      end.
      ii = ii + 1.
      find first ub.abc-analysis-prod  exclusive-lock where  recid (ub.abc-analysis-prod) = temp-tt.id no-error .
          if available ub.abc-analysis-prod then do:
              ub.abc-analysis-prod.abcg-abc      =  temp-tt.abc.
              ub.abc-analysis-prod.proc-from-all =  ub.abc-analysis-prod.abcg-sum-for-estimate  * 100 / v-all-sum .
              ub.abc-analysis-prod.rating        = ii .
          end.
end.


  run waitfram-hide in this-procedure .

  end.

end procedure. /* make-other-table */