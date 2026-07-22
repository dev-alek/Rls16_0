/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

заполнение временных таблиц по партиям поставщика  СУДЬБА

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 07/15/03 4:15

*/

find ub.goods where ub.goods.artic = ub.parts.artic
                                  and ub.goods.prod-type = ub.parts.prod-type
                                  and ub.goods.prod-code = ub.parts.prod-code no-lock.
assign
    l-date = ub.parts.fact-date
    qnty_sale = 0
    .

if prev-exch-code <> ? and prev-exch-code <> ub.parts.exch-code then
    assign prev-exch-code = ?
    v-can-print-cli = false
    .

for each b-parts where b-parts.artic = ub.parts.artic
                                            and b-parts.prod-type = ub.parts.prod-type
                                            and b-parts.prod-code = ub.parts.prod-code
                                            and b-parts.status_ = yes
                                            and b-parts.doc-type = {&expense} no-lock,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code
          /* and  ub.parts-attr.income-in-code = num-doc */ no-lock ,
     each ub.trn-doc where ub.trn-doc.doc-code = b-parts.out-code
                                            and ub.trn-doc.internal = no no-lock
                                            break 
      by b-parts.artic
      by b-parts.prod-type
      by b-parts.prod-code
      /*
      жаль, но эти нужно убрать :(
       by b-parts.in-code
        by b-parts.part-code
      */
      by b-parts.status_
      by b-parts.rsrv-free
      by b-parts.fact-date
:

    if last-of( b-parts.fact-date ) then
        assign qnty_sale = qnty_sale + 1.
    if last( b-parts.fact-date ) and l-date - 1 < b-parts.fact-date then
        assign l-date = b-parts.fact-date + 1.
end.

for each b-parts where b-parts.artic = ub.parts.artic
                     and b-parts.prod-type = ub.parts.prod-type
                     and b-parts.prod-code = ub.parts.prod-code
                     and b-parts.out-code = {&output-code}
                     and b-parts.fact-date >= /* from-date */ ub.parts.fact-date
                     and b-parts.fact-date <= to-date
                     no-lock ,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = ub.parts.out-code no-lock

             :
    /*         message "расход" b-parts.fact-qnty b-parts.fact-date
             skip
             b-parts.out-code

             .
      */
    accumulate b-parts.fact-qnty (total).
end.
assign out-qnty = (accum total b-parts.fact-qnty) .

for each b-parts where b-parts.artic = ub.parts.artic
                     and b-parts.prod-type = ub.parts.prod-type
                     and b-parts.prod-code = ub.parts.prod-code
                     and b-parts.out-code = {&free-code}
                     and b-parts.fact-date >= ub.parts.fact-date
                     and b-parts.fact-date <= to-date
                     no-lock ,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = ub.parts.out-code no-lock

             :
/*          message "free" b-parts.fact-qnty b-parts.fact-date
             skip
            "out-code  "  b-parts.out-code
            "part-code "  b-parts.part-code
            "in-code   "  b-parts.in-code                   skip
            ub.parts.out-code
             .
  */
    accumulate b-parts.fact-qnty (total).
end.
assign free-qnty = (accum total b-parts.fact-qnty) .


/*
for each b-parts where b-parts.artic = ub.parts.artic
                       and b-parts.prod-type = ub.parts.prod-type
                       and b-parts.prod-code = ub.parts.prod-code
                       and b-parts.rsrv-free = yes
                       and b-parts.fact-date <= to-date
                       and b-parts.fact-date >= /* from-date  */ ub.parts.fact-date
                       no-lock  ,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code
          /* and
          ub.parts-attr.income-in-code = num-doc*/
          no-lock                     :

    accumulate b-parts.fact-qnty (total).
end.
assign free-qnty = (accum total b-parts.fact-qnty) .
for each b-parts where b-parts.artic = ub.parts.artic
                                            and b-parts.prod-type = ub.parts.prod-type
                                            and b-parts.prod-code = ub.parts.prod-code
                                            and b-parts.status_ = no
                                            and b-parts.doc-type = {&income} no-lock,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code /*
          and
          ub.parts-attr.income-in-code = num-doc */
          no-lock ,

        each ub.trn-doc where ub.trn-doc.doc-code = b-parts.out-code
                                            and ub.trn-doc.internal = yes no-lock:
    accumulate b-parts.qnty (total).
end.
assign free-qnty = free-qnty + (accum total b-parts.qnty) .
for each b-parts where b-parts.artic = ub.parts.artic
                                            and b-parts.prod-type = ub.parts.prod-type
                                            and b-parts.prod-code = ub.parts.prod-code
                                            and b-parts.status_ = no
                                            and b-parts.doc-type = {&return} no-lock,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code
          /* and
          ub.parts-attr.income-in-code = num-doc */
          no-lock ,

        each ub.trn-doc where ub.trn-doc.doc-code = b-parts.out-code
                                            and ub.trn-doc.internal = yes no-lock:
    accumulate b-parts.qnty (total).
end.
assign free-qnty = free-qnty + (accum total b-parts.qnty) .
*/

if free-qnty > 0 then
    assign l-date = today + 1.

{ str/in-vatp.i calc-parts ub.parts. " " g }

accumulate
    ub.parts.fact-qnty (total)
    ub.parts.fact-qnty * ub.parts.price-rubl (total)
    ub.parts.fact-qnty * ub.parts.price-base (total)
    out-qnty (total)
    out-qnty * ub.parts.price-rubl (total)
    out-qnty * ub.parts.price-base (total)
    free-qnty (total)
    free-qnty * vat-rubl-loc (total)
    free-qnty * vat-base-loc (total)
    free-qnty * price-rubl-with-tax-loc (total)
    free-qnty * price-base-with-tax-loc (total)
    .
/* message "dd - create"  num-doc  ub.parts.in-code ub.parts.doc-type. */

create suppl-parts.
assign
    suppl-parts.num-doc = num-doc
    suppl-parts.artic = ub.parts.artic
    suppl-parts.prod-type = ub.parts.prod-type
    suppl-parts.prod-code = ub.parts.prod-code
    suppl-parts.gds-code = ub.goods.gds-code
    suppl-parts.gds-name = ub.goods.gds-name
    suppl-parts.doc-type = ub.parts.doc-type
    suppl-parts.in-code  = ub.parts.in-code
    suppl-parts.out-code = ub.parts.out-code
    suppl-parts.fact-date   = ub.parts.fact-date
    suppl-parts.price0-base = ub.parts.price-base
    suppl-parts.price0-rubl = ub.parts.price-rubl
    suppl-parts.price-cli = ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.obj-type  = ub.parts.obj-type
    suppl-parts.obj-code  = ub.parts.obj-code
    suppl-parts.part-code = ub.parts.part-code
    suppl-parts.in-qnty   = ub.parts.fact-qnty
    suppl-parts.in-sum0-rubl = ub.parts.fact-qnty * ub.parts.price-rubl
    suppl-parts.in-sum0-base = ub.parts.fact-qnty * ub.parts.price-base
    suppl-parts.in-sum-cli   = ub.parts.fact-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.p-in-qnty      = if (ub.parts.fact-date < from-date) then 0 else (ub.parts.fact-qnty)
    suppl-parts.p-in-sum0-rubl = if (ub.parts.fact-date < from-date) then 0 else (ub.parts.fact-qnty * ub.parts.price-rubl)
    suppl-parts.p-in-sum0-base = if (ub.parts.fact-date < from-date) then 0 else (ub.parts.fact-qnty * ub.parts.price-base)
    suppl-parts.p-in-sum-cli   = if (ub.parts.fact-date < from-date) then 0 else (ub.parts.fact-qnty * ub.parts.price-cli / ub.parts.cli-base-rate)
    suppl-parts.out-qnty = out-qnty
    suppl-parts.out-sum0-rubl = out-qnty * ub.parts.price-rubl
    suppl-parts.out-sum0-base = out-qnty * ub.parts.price-base
    suppl-parts.out-sum-cli = out-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.free-qnty = free-qnty
    suppl-parts.free-nds0-rubl = free-qnty * vat-rubl-loc
    suppl-parts.free-nds0-base = free-qnty * vat-base-loc
    suppl-parts.free-sum0-rubl = free-qnty * price-rubl-with-tax-loc
    suppl-parts.free-sum0-base = free-qnty * price-base-with-tax-loc
    suppl-parts.free-sum-cli = free-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.qnty-sale = qnty_sale
    suppl-parts.fs-date = ub.parts.fact-date
    suppl-parts.ls-date = l-date

 .

/* $Workfile$ e n d */