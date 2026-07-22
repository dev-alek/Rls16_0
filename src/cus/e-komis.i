/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка документа для отчета по реализации комиссионных товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/21/03
Author: Bakhtadze Natalya
Creation date: 05/21/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FOR  each ub.doc-line NO-LOCk WHERE
         ub.doc-line.doc-code = doc-num:
  { gbl/doclicod.i recid(ub.doc-line) v-gds-code no-error }
  if error-status:error then do:
   next.
  end.
  assign
  my-accum = my-accum + 1
  .
  IF my-accum MODULO 50  = 0 then do:
    run waitfram-show in this-procedure ("Обработано " + string(my-accum) + " строк накладных ").
  end.
  { str/out-vatp.i ub.doc-line ub.doc-line. t-doc. " " }
  assign
  price-rubl-without-tax-sale-b = price-rubl-with-tax-sale - vat-rubl-buyer - slt-rubl-sale - road-tax-rubl-sale
  .


  _parts:
  FOR EACH ub.parts NO-LOCK WHERE
          ub.parts.artic = ub.doc-line.artic
      AND ub.parts.prod-type = ub.doc-line.prod-type
      AND ub.parts.prod-code = ub.doc-line.prod-code
      AND ub.parts.out-code = doc-num
      AND ub.parts.obj-type = ub.doc-line.obj-type
      AND ub.parts.obj-code = ub.doc-line.obj-code
      :
    find first buf_parts-attr no-lock where
               buf_parts-attr.in-code = ub.parts.in-code
           AND buf_parts-attr.gds-code = v-gds-code
           AND buf_parts-attr.part-code = ub.parts.part-code no-error .
    if available buf_parts-attr then do:
&if "{1}" = "list" &then
      if not can-find(first cli-list no-lock where
             cli-list.obj-type = buf_parts-attr.supp-type
         AND cli-list.obj-code = buf_parts-attr.supp-code) then NEXT _parts.
&else
      if
      NOT (buf_parts-attr.supp-type = cli_supp.obj-type
      AND buf_parts-attr.supp-code = cli_supp.obj-code) then NEXT _parts.
&endif
      if buf_parts-attr.purch-code <> ocons-pay
      AND buf_parts-attr.purch-code <> ocons-pay-2
      then next _parts.
      assign
      v-parts-VAt-pc = buf_parts-attr.vat-pc
      v-parts-SLT-pc = buf_parts-attr.SLT-pc
      v-in-code = buf_parts-attr.income-in-code
      v-part-code  = buf_parts-attr.income-part-code
      .
    end.
    else do:
&if "{1}" = "list" &then
      if not can-find(first cli-list no-lock where
             cli-list.obj-type = ub.parts.supp-type
         AND cli-list.obj-code = ub.parts.supp-code) then NEXT _parts.
&else
      if
      NOT (ub.parts.supp-type = cli_supp.obj-type
      AND ub.parts.supp-code = cli_supp.obj-code) then NEXT _parts.
&endif
      if ub.parts.purch-code <> ocons-pay
      AND ub.parts.purch-code <> ocons-pay-2
      then next _parts.
      assign
      v-parts-VAt-pc = ub.parts.vat-pc
      v-parts-SLT-pc = ub.parts.SLT-pc
      v-in-code = ub.parts.in-code
      v-part-code = ub.parts.part-code
      .

    end.

    { str/in-vatp.i calc-parts ub.parts. t-doc " " " " }
&if "{1}" = "list" &then
&else
    if T-parts
    then do:
       FIND FIRST sj-goods WHERE
                sj-goods.artic = ub.doc-line.artic
            AND sj-goods.prod-type = ub.doc-line.prod-type
            AND sj-goods.prod-code = ub.doc-line.prod-code
            AND sj-goods.is-out_ = is-out
            AND sj-goods.VAT-supp = v-parts-Vat-pc
            AND sj-goods.price-with-tax-cost_ = price-rubl-with-tax-loc
            AND sj-goods.price-without-tax-sale_ = price-rubl-without-tax-sale-b
            AND sj-goods.part-code = v-part-code
            AND sj-goods.in-code = v-in-code
            No-error.
    end.
&endif
&if "{1}" = "list" &then
&else
    else do:
&endif
      FIND FIRST sj-goods WHERE
&if "{1}" = "list" &then
                sj-goods.supp-type = ub.parts.supp-type
            AND sj-goods.supp-code = ub.parts.supp-code
&else
                sj-goods.artic = ub.doc-line.artic
            AND sj-goods.prod-type = ub.doc-line.prod-type
            AND sj-goods.prod-code = ub.doc-line.prod-code
            AND sj-goods.is-out_ = is-out
            AND sj-goods.VAT-supp = v-parts-Vat-pc
            AND sj-goods.price-with-tax-cost_ = price-rubl-with-tax-loc
            AND sj-goods.price-without-tax-sale_ = price-rubl-without-tax-sale-b
&endif
            No-error.
&if "{1}" = "list" &then
&else
    END. /*T-parts*/
&endif
    if not avail sj-goods
    then do:
      FIND FIRST ub.goods No-LOCK WHERE
                ub.goods.artic = ub.doc-line.artic
            AND ub.goods.prod-type = ub.doc-line.prod-type
            AND ub.goods.prod-code = ub.doc-line.prod-code No-ERROR.
      create sj-goods.
      assign
&if "{1}" = "list" &then
      sj-goods.supp-type = ub.parts.supp-type
      sj-goods.supp-code = ub.parts.supp-code
&else
      sj-goods.artic = ub.goods.artic
      sj-goods.prod-type = ub.goods.prod-type
      sj-goods.prod-code = ub.goods.prod-code
      sj-goods.unit = ub.goods.unit-base
      sj-goods.gds-name = REPLACE(ub.goods.gds-name, " ", "_")
      sj-goods.VAT-supp = v-parts-VAT-pc
      sj-goods.SLT-supp = v-parts-SLT-pc
      sj-goods.in-code = if T-parts then v-in-code else ""
      sj-goods.part-code = if T-parts then v-part-code else ""
      sj-goods.is-out_ = is-out
      /*цена учетная с налогами*/
      sj-goods.price-with-tax-cost_ = price-rubl-with-tax-loc
&endif
      .
    END. /*if not avail sj-goods*/

    assign
    prt-qnty =  is-out * ub.parts.fact-qnty
    sj-goods.qnty = sj-goods.qnty +  prt-qnty

    /*учетная часть*/

    /*цена учетная без налогов*/
    sj-goods.price-without-tax-cost_ = price-rubl-without-tax-loc
    /*сумма учетная без налогов*/
    sj-goods.sum-without-tax-cost_  =  sj-goods.sum-without-tax-cost_ + price-rubl-without-tax-loc * prt-qnty
    /*сумма учетного НДС*/
    sj-goods.sum-vat-cost_ = sj-goods.sum-vat-cost_ + vat-rubl-loc * prt-qnty
    /*сумма учетная с налогами*/
    sj-goods.sum-with-tax-cost_   =  sj-goods.sum-with-tax-cost_ + price-rubl-with-tax-loc * prt-qnty


    /*продажная часть*/
    /*сумма продажная без налогов*/
    sj-goods.sum-without-tax-sale_ = sj-goods.sum-without-tax-sale_ + price-rubl-without-tax-sale-b * prt-qnty
    /*цена продажная без налогов*/
    sj-goods.price-without-tax-sale_ = sj-goods.sum-without-tax-sale_ / sj-goods.qnty
    /*сумма продажного НДС*/
    sj-goods.sum-vat-sale_ = sj-goods.sum-vat-sale + vat-rubl-buyer * prt-qnty
    /*сумма продажного НП*/
    sj-goods.sum-slt-sale_ = sj-goods.sum-slt-sale + slt-rubl-sale * prt-qnty
    /*сумма продажная с налогами*/
    sj-goods.sum-with-tax-sale_ = sj-goods.sum-with-tax-sale_ + price-rubl-with-tax-sale * prt-qnty
    .
  END. /*FOR EACH parts*/
END. /*FOR EACH doc-line*/

/* $Workfile$ e n d */