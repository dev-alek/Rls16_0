block-level on error undo, throw.
/*

$Revision: c5e125f9f735, 902, rls $
$Author: EShklyar $
$Date: Tue Dec 06 17:15:45 2016 +0300 $
$Workfile: func-xyz.p $
$Archive: ref/func-xyz.p $

Проведение XYZ анализа

Автор: Чернова Светлана Александровна
Дата создания: 05/19/05
Author: Svetlana Chernova
Creation date: 05/19/05

*/
{ ref/def-abct.i }
define temp-table    x-analysis         no-undo  like ub.XYZ-analysis
field r-goods as integer.
define temp-table    x-analysis-period  no-undo  like ub.XYZ-analysis-period.

define input         parameter table for    x-analysis.
define input         parameter table for    x-analysis-period.
define input-output  parameter table for    temp-oborot.
define input-output  parameter table for    temp-xyz.
define output        parameter table for    temp-goods.

define variable vss-revision    as character no-undo init "$Revision: c5e125f9f735, 902, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 06 17:15:45 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: func-xyz.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/func-xyz.p $":U .
define variable vss-description as character no-undo init "Проведение XYZ анализа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/factord.i  }
{ gbl/waitfram.i }
run waitfram-show ("Ранжирование товаров...").

/* Определим процентное соотношения товаров */
define variable v-all-sum    as decimal   no-undo .
define variable v-all-period as integer   no-undo .
v-all-sum    = 0 .
v-all-period = 0 .
for each x-analysis-period :
   v-all-period = v-all-period + 1.
end.

for each  temp-oborot USE-INDEX PI :
    v-all-sum = v-all-sum + temp-oborot.sum-crit .
    find first temp-goods where temp-goods.gds-code = temp-oborot.gds-code no-error .

    if not available temp-goods then DO:
       create temp-goods.
        assign
          temp-goods.gds-code          = temp-oborot.gds-code
          temp-goods.sum-crit          =  temp-oborot.sum-crit
          temp-goods.qnty              =  temp-oborot.qnty
          temp-goods.reserve-day       =  temp-oborot.reserve-day
          temp-goods.stock-qnty        =  temp-oborot.stock-qnty
          temp-goods.stock-price-acc   =  temp-oborot.price-cost
          temp-goods.stock-price-sale  =  temp-oborot.stock-qnty * temp-oborot.price-crc
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
      temp-goods.stock-price-sale  = temp-goods.stock-price-sale + ( temp-oborot.stock-qnty * temp-oborot.price-crc )
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

define variable v-kol-period as integer   no-undo .
define variable v-sig as decimal   no-undo .

      for each  temp-goods :

        v-kol-period = 0 .
        v-sig = 0 .
        for each temp-xyz where
              temp-xyz.gds-code = temp-goods.gds-code
              :
              v-kol-period = v-kol-period + 1 .
        end.

        temp-goods.kol-period   = v-kol-period .
        temp-goods.average-qnty = if v-kol-period = 0 then 0 else temp-goods.sum-crit / v-kol-period.

        for each temp-xyz where
              temp-xyz.gds-code = temp-goods.gds-code
              :
              v-sig = v-sig + exp ((temp-xyz.sum-crit-p - temp-goods.average-qnty) , 2 ) .
        end.
          temp-goods.sigma   = v-sig / v-all-period .
          temp-goods.K_V     = if temp-goods.average-qnty = 0 then 0 else (exp ( temp-goods.sigma , 0.5 ) / temp-goods.average-qnty).
          temp-goods.crit-pr = temp-goods.K_V * 100 .
      end.


find first x-analysis no-error .
if error-status :error then
  message vss-workfile vss-revision vss-description skip
  error-status :get-message(1) view-as alert-box error .

define variable v-A as decimal   no-undo .
define variable v-B as decimal   no-undo .
define variable first-A as logical   no-undo .
define variable first-B as logical   no-undo .


assign
v-A = x-analysis.XYZ-x
v-B = x-analysis.XYZ-z

.
define variable v-nak as decimal   no-undo .
v-nak = 0.
for each temp-goods  where
    temp-goods.sum-crit > 0
    break by temp-goods.crit-pr :

    v-nak = temp-goods.crit-pr .

    if v-nak < v-A   then do:
       temp-goods.crit = "X" .
    end.

    if v-nak >= v-A  and v-nak <= v-B then do:
          assign
            temp-goods.crit = "Y"
          .
    end.


    if v-nak > v-B  then do:
            assign
              temp-goods.crit = "Z"
            .
    end.

end.
run waitfram-hide.