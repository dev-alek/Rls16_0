block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: func-abc.p $
$Archive: ref/func-abc.p $

Проведение АВС анализа

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 05/19/05
*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: func-abc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/func-abc.p $":U .
define variable vss-description as character no-undo init "Проведение АВС анализа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/factord.i  }
{ ref/def-abct.i }
{ gbl/waitfram.i }
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


run waitfram-hide.