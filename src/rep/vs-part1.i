/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

заполнение временных таблиц по партиям поставщика

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 07/15/03 4:15

*/

  find ub.goods where
      ub.goods.artic = ub.parts.artic
  and ub.goods.prod-type = ub.parts.prod-type
  and ub.goods.prod-code = ub.parts.prod-code
  no-lock.

assign
    l-date = ub.parts.fact-date
    qnty_sale = 0
    .
if FIRST( ub.parts.fact-date ) then
    assign prev-exch-code = ub.parts.exch-code.

if prev-exch-code <> ? and prev-exch-code <> ub.parts.exch-code then
    assign prev-exch-code = ?.

FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                                            AND b-parts.prod-type = ub.parts.prod-type
                                            AND b-parts.prod-code = ub.parts.prod-code
                                            AND b-parts.status_ = yes
                                            AND b-parts.doc-type = {&expense} NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock ,
     EACH ub.trn-doc WHERE ub.trn-doc.doc-code = b-parts.out-code
                                            AND ub.trn-doc.internal = no NO-LOCK
                                            BREAK BY b-parts.fact-date:

    if LAST-OF( b-parts.fact-date ) then
        assign qnty_sale = qnty_sale + 1.
    if LAST( b-parts.fact-date ) AND l-date - 1 < b-parts.fact-date then
        assign l-date = b-parts.fact-date + 1.
END.

FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                     AND b-parts.prod-type = ub.parts.prod-type
                     AND b-parts.prod-code = ub.parts.prod-code
                     AND b-parts.out-code = {&output-code}
                     NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock

                     :

    ACCUMULATE b-parts.fact-qnty (TOTAL).
END.
assign out-qnty = (ACCUM TOTAL b-parts.fact-qnty) .

FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                       AND b-parts.prod-type = ub.parts.prod-type
                       AND b-parts.prod-code = ub.parts.prod-code
                       AND b-parts.rsrv-free = yes
                       NO-LOCK  ,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock

                       :

    ACCUMULATE b-parts.fact-qnty (TOTAL).
END.
assign free-qnty = (ACCUM TOTAL b-parts.fact-qnty) .
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                                            AND b-parts.prod-type = ub.parts.prod-type
                                            AND b-parts.prod-code = ub.parts.prod-code
                                            AND b-parts.status_ = no
                                            AND b-parts.doc-type = {&income} NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock ,

        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = b-parts.out-code
                                            AND ub.trn-doc.internal = yes NO-LOCK:
    ACCUMULATE b-parts.qnty (TOTAL).
END.
assign free-qnty = free-qnty + (ACCUM TOTAL b-parts.qnty) .
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                                            AND b-parts.prod-type = ub.parts.prod-type
                                            AND b-parts.prod-code = ub.parts.prod-code
                                            AND b-parts.status_ = no
                                            AND b-parts.doc-type = {&return} NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock ,

        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = b-parts.out-code
                                            AND ub.trn-doc.internal = yes NO-LOCK:
    ACCUMULATE b-parts.qnty (TOTAL).
END.
assign free-qnty = free-qnty + (ACCUM TOTAL b-parts.qnty) .

if free-qnty > 0 then
    assign l-date = TODAY + 1.

{ str/in-vatp.i calc-parts ub.parts. " " g }

ACCUMULATE
    ub.parts.fact-qnty (TOTAL)
    ub.parts.fact-qnty * ub.parts.price-rubl (TOTAL)
    ub.parts.fact-qnty * ub.parts.price-base (TOTAL)
    out-qnty (TOTAL)
    out-qnty * ub.parts.price-rubl (TOTAL)
    out-qnty * ub.parts.price-base (TOTAL)
    free-qnty (TOTAL)
    free-qnty * vat-rubl-loc (TOTAL)
    free-qnty * vat-base-loc (TOTAL)
    free-qnty * price-rubl-with-tax-loc (TOTAL)
    free-qnty * price-base-with-tax-loc (TOTAL)
    .
CREATE suppl-parts.
assign
    suppl-parts.num-doc = num-doc
    suppl-parts.artic = ub.parts.artic
    suppl-parts.prod-type = ub.parts.prod-type
    suppl-parts.prod-code = ub.parts.prod-code
    suppl-parts.gds-code = ub.goods.gds-code
    suppl-parts.gds-name = ub.goods.gds-name
    suppl-parts.doc-type = ub.parts.doc-type
    suppl-parts.in-code = ub.parts.in-code
    suppl-parts.out-code = ub.parts.out-code
    suppl-parts.fact-date = ub.parts.fact-date
    suppl-parts.price0-base = ub.parts.price-base
    suppl-parts.price0-rubl = ub.parts.price-rubl
    suppl-parts.price-cli = ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.obj-type = ub.parts.obj-type
    suppl-parts.obj-code = ub.parts.obj-code
    suppl-parts.part-code = ub.parts.part-code
    suppl-parts.in-qnty = ub.parts.fact-qnty
    suppl-parts.in-sum0-rubl = ub.parts.fact-qnty * ub.parts.price-rubl
    suppl-parts.in-sum0-base = ub.parts.fact-qnty * ub.parts.price-base
    suppl-parts.in-sum-cli = ub.parts.fact-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.out-qnty = out-qnty
    suppl-parts.out-sum0-rubl = out-qnty * ub.parts.price-rubl
    suppl-parts.out-sum0-base = out-qnty * ub.parts.price-base
    suppl-parts.out-sum-cli = out-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.free-qnty = free-qnty
    suppl-parts.free-NDS0-rubl = free-qnty * vat-rubl-loc
    suppl-parts.free-NDS0-base = free-qnty * vat-base-loc
    suppl-parts.free-sum0-rubl = free-qnty * price-rubl-with-tax-loc
    suppl-parts.free-sum0-base = free-qnty * price-base-with-tax-loc
    suppl-parts.free-sum-cli = free-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.qnty-sale = qnty_sale
    suppl-parts.fs-date = ub.parts.fact-date
    suppl-parts.ls-date = l-date
    .

/* $Workfile$ e n d */