block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: func-ab.p $
$Archive: ref/func-ab.p $

Проведение АВС анализа 80/20 (первое разделение )

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 05/19/05
*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: func-ab.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/func-ab.p $":U .
define variable vss-description as character no-undo init "Проведение АВС анализа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/factord.i  }
{ ref/def-abct.i }
{ gbl/waitfram.i }
{ gbl/thbjattr.i }
define temp-table  x-analysis        no-undo  like ub.abc-analysis.
define input         parameter table for    x-analysis.
define input-output  parameter table for    temp-oborot.
define output        parameter table for    temp-goods.

run waitfram-show ("Ранжирование товаров...").

/* Определим процентное соотношения товаров */
define variable v-all-sum as decimal   no-undo .
v-all-sum = 0 .
for each  temp-oborot USE-INDEX PI :
    v-all-sum = v-all-sum + temp-oborot.sum-crit .
    find first temp-goods where temp-goods.gds-code = temp-oborot.gds-code no-error .

    if not available temp-goods then DO:
       create temp-goods.
        assign
          temp-goods.gds-code          =  temp-oborot.gds-code
          temp-goods.sum-crit          =  temp-oborot.sum-crit
          temp-goods.qnty              =  temp-oborot.qnty
          temp-goods.reserve-day       =  temp-oborot.reserve-day
          temp-goods.stock-qnty        =  temp-oborot.stock-qnty
          temp-goods.stock-price-acc   =  temp-oborot.price-cost
          temp-goods.stock-price-sale  =  temp-oborot.qnty * temp-oborot.price-crc
          temp-goods.sum-acc           =  temp-oborot.sum-acc
          temp-goods.sum-cur           =  temp-oborot.sum-cur
          temp-goods.sum-doc           =  temp-oborot.sum-doc
          temp-goods.vat-acc           =  temp-oborot.vat-acc
          temp-goods.vat-cur           =  temp-oborot.vat-cur
          temp-goods.vat-doc           =  temp-oborot.vat-doc
          temp-goods.transport-acc     =  temp-oborot.transport-acc
          temp-goods.transport-cur     =  temp-oborot.transport-cur
          temp-goods.transport-doc     =  temp-oborot.transport-doc
          temp-goods.other-acc         =  temp-oborot.other-acc
          temp-goods.other-cur         =  temp-oborot.other-cur
          temp-goods.other-doc         =  temp-oborot.other-doc
          temp-goods.road-tax-acc      =  temp-oborot.road-tax-acc
          temp-goods.road-tax-cur      =  temp-oborot.road-tax-cur
          temp-goods.road-tax-doc      =  temp-oborot.road-tax-doc
          temp-goods.slt-acc           =  temp-oborot.slt-acc
          temp-goods.slt-cur           =  temp-oborot.slt-cur
          temp-goods.slt-doc           =  temp-oborot.slt-doc
          temp-goods.order-qnty        =  temp-oborot.order-qnty
      .

    END.
    ELSE
     assign
      temp-goods.gds-code          = temp-oborot.gds-code
      temp-goods.sum-crit          = temp-goods.sum-crit       + temp-oborot.sum-crit
      temp-goods.qnty              = temp-goods.qnty           + temp-oborot.qnty
      temp-goods.reserve-day       = temp-goods.reserve-day    + temp-oborot.reserve-day
      temp-goods.stock-qnty        = temp-goods.stock-qnty     + temp-oborot.stock-qnty
      temp-goods.stock-price-acc   = temp-goods.stock-price-acc  + ( temp-oborot.price-cost )
      temp-goods.stock-price-sale  = temp-goods.stock-price-sale + ( temp-oborot.qnty * temp-oborot.price-crc )
      temp-goods.sum-acc           = temp-goods.sum-acc        + temp-oborot.sum-acc
      temp-goods.sum-cur           = temp-goods.sum-cur        + temp-oborot.sum-cur
      temp-goods.sum-doc           = temp-goods.sum-doc        + temp-oborot.sum-doc
      temp-goods.vat-acc           = temp-goods.vat-acc        + temp-oborot.vat-acc
      temp-goods.vat-cur           = temp-goods.vat-cur        + temp-oborot.vat-cur
      temp-goods.vat-doc           = temp-goods.vat-doc        + temp-oborot.vat-doc
      temp-goods.transport-acc     = temp-goods.transport-acc  + temp-oborot.transport-acc
      temp-goods.transport-cur     = temp-goods.transport-cur  + temp-oborot.transport-cur
      temp-goods.transport-doc     = temp-goods.transport-doc  + temp-oborot.transport-doc
      temp-goods.other-acc         = temp-goods.other-acc      + temp-oborot.other-acc
      temp-goods.other-cur         = temp-goods.other-cur      + temp-oborot.other-cur
      temp-goods.other-doc         = temp-goods.other-doc      + temp-oborot.other-doc
      temp-goods.road-tax-acc      = temp-goods.road-tax-acc   + temp-oborot.road-tax-acc
      temp-goods.road-tax-cur      = temp-goods.road-tax-cur   + temp-oborot.road-tax-cur
      temp-goods.road-tax-doc      = temp-goods.road-tax-doc   + temp-oborot.road-tax-doc
      temp-goods.slt-acc           = temp-goods.slt-acc        + temp-oborot.slt-acc
      temp-goods.slt-cur           = temp-goods.slt-cur        + temp-oborot.slt-cur
      temp-goods.slt-doc           = temp-goods.slt-doc        + temp-oborot.slt-doc
      temp-goods.order-qnty        = temp-goods.order-qnty     + temp-oborot.order-qnty
    .
end.


for each  temp-goods :
          temp-goods.crit-pr = temp-goods.sum-crit * 100 / v-all-sum.
end.


find first x-analysis no-error .
if error-status :error then
  message vss-workfile vss-revision vss-description skip
  error-status :get-message(1) view-as alert-box error .

define variable v-A     as decimal   no-undo .
define variable v-B     as decimal   no-undo .
define variable first-A as logical   no-undo .
define variable first-B as logical   no-undo .

define variable par-type as character no-undo .
define variable par-abc-type as character no-undo .
define variable  v-value-date    as date   no-undo .
define variable  v-value-decimal as decimal   no-undo .
define variable  v-value-integer as integer   no-undo .
define variable  v-value-logical as logical   no-undo .
define variable v-found as logical   no-undo .
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   {&attr-abc-global} ,
  input   'abc-type'  ,
  output  par-abc-type ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  v-value-logical   ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
  if error-status :error or v-found = false then do:
      message "Нет настроек Ассортиментной политики !!!." view-as alert-box information .
      return error return-value .
  end.

assign
  v-a = x-analysis.double-line-proc
  first-A = true
  .

define variable v-nak as decimal   no-undo .
v-nak = 0.

for each temp-goods  where
         temp-goods.sum-crit > 0
         break by temp-goods.crit-pr desc :

    v-nak = v-nak + temp-goods.crit-pr .
    temp-goods.prcnt-account = v-nak .

    if v-nak <= v-A   then do:
       temp-goods.crit = "A" .
       first-A = true.
       next.
    end.

    if v-nak > v-A  then do:
       if first-A = true then
          assign
            first-A = false
            temp-goods.crit = "A"
          .
        else
          assign
            temp-goods.crit = "B"
          .
    end.
end.
run waitfram-hide.