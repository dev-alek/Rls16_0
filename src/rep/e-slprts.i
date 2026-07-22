/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Партии товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FOR each ub.doc-line NO-LOCk WHERE
        ub.doc-line.doc-code = doc-num:
  my-accum = my-accum + 1.
  IF my-accum MODULO 50  = 0 then do:
      run waitfram-show in this-procedure ("Обработано " + string(my-accum) + " строк накладных ").
  end.
  assign
  sale_sum_base = 0
  sale_sum_rubl = 0
  .
  FOR EACH ub.gds-dtl No-LOCK WHERE
          ub.gds-dtl.doc-code = ub.doc-line.doc-code AND
          ub.gds-dtl.artic = ub.doc-line.artic AND
          ub.gds-dtl.prod-type = ub.doc-line.prod-type AND
          ub.gds-dtl.prod-code = ub.doc-line.prod-code:
    assign
    sale_sum_base = sale_sum_base + (ub.gds-dtl.price-base - ub.gds-dtl.discnt-base) * ub.gds-dtl.fact-qnty
    sale_sum_rubl = sale_sum_rubl + (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) * ub.gds-dtl.fact-qnty
    .
  END.


  FIND FIRST ub.gds-obj /*SHARE-LOCK*/ No-LOCK  WHERE
            ub.gds-obj.artic = ub.doc-line.artic AND
            ub.gds-obj.prod-type = ub.doc-line.prod-type AND
            ub.gds-obj.prod-code = ub.doc-line.prod-code AND
            ub.gds-obj.obj-type = obj-list.obj-type AND
            ub.gds-obj.obj-code = obj-list.obj-code No-ERROR.

  FOR EACH ub.parts NO-LOCK WHERE
          ub.parts.artic = ub.doc-line.artic AND
          ub.parts.prod-type = ub.doc-line.prod-type AND
          ub.parts.prod-code = ub.doc-line.prod-code AND
          ub.parts.out-code = doc-num AND
          ub.parts.obj-type = ub.doc-line.obj-type AND
          ub.parts.obj-code = ub.doc-line.obj-code:
    assign
    v-is-primary = no
    .
    find first buf_parts-attr no-lock where
              buf_parts-attr.in-code  = ub.parts.in-code
         AND  buf_parts-attr.gds-code = ub.gds-obj.gds-code
         AND buf_parts-attr.part-code = ub.parts.part-code no-error .
    if available buf_parts-attr then do:
      if v-doc-type = {&expense}
      and v-internal = no then do:
          /*для внешнего расхода */
          /*надо найти документ СТП*/
          /*и найти был ли для этого расхода документ СТП*/
        find first buf_trn-stp no-lock where
                  buf_trn-stp.out-code = doc-num
              AND buf_trn-stp.ext-doc-type = {&TDEDT_Chg_Purch_Code} no-error.
        if available buf_trn-stp  and buf_parts-attr.in-code = buf_trn-stp.doc-code then do:
          find first buf_parts-stp no-lock where
                    buf_parts-stp.obj-type = ub.parts.obj-type
                AND buf_parts-stp.obj-code = ub.parts.obj-code
                AND buf_parts-stp.artic    = ub.parts.artic
                AND buf_parts-stp.prod-type    = ub.parts.prod-type
                AND buf_parts-stp.prod-code   = ub.parts.prod-code
                AND buf_parts-stp.in-code    = buf_trn-stp.doc-code
                AND buf_parts-stp.out-code    = buf_trn-stp.doc-code
                AND buf_parts-stp.part-code    = parts.part-code no-error.
          if available buf_parts-stp then do:
            find first bf-in_parts-attr no-lock where
                bf-in_parts-attr.in-code   = buf_parts-attr.income-in-code   AND
                bf-in_parts-attr.gds-code  = ub.gds-obj.gds-code              AND
                bf-in_parts-attr.part-code = buf_parts-attr.income-part-code NO-ERROR.
            if available bf-in_parts-attr then do:
              assign
              v-is-primary = yes
              .
              assign
              v-is-attr      = yes
              v-parts-VAt-pc = bf-in_parts-attr.vat-pc
              v-parts-SLT-pc = bf-in_parts-attr.SLT-pc
              v-supp-type = bf-in_parts-attr.supp-type
              v-supp-code = bf-in_parts-attr.supp-code
              v-purch-code = (IF parts.purch-code = integer({&repayment-code})
                              AND bf-in_parts-attr.purch-code = integer({&old-consignation-code})
                              then integer({&responsible-storage-code})
                              else  bf-in_parts-attr.purch-code
                            )
              v-pay-code  = bf-in_parts-attr.pay-code
              v-in-code = bf-in_parts-attr.income-in-code
              v-fact-date = bf-in_parts-attr.fact-date
              v-obj-type =  parts.obj-type
              v-obj-code =  parts.obj-code
              v-cst-code = bf-in_parts-attr.cst-code
              .
            end. /* if available bf-in_parts-attr then do:*/
          end. /*if available buf_parts-stp then do:*/
        end. /*if available buf_trn-stp then do:*/
        if not v-is-primary then do:
          /*не было смены типа приобретения на текущей расходной накладной на текущей партии*/
          assign
          v-is-attr      = yes
          v-parts-VAt-pc = buf_parts-attr.vat-pc
          v-parts-SLT-pc = buf_parts-attr.SLT-pc
          v-supp-type = buf_parts-attr.supp-type
          v-supp-code = buf_parts-attr.supp-code
          v-purch-code = buf_parts-attr.purch-code
          v-pay-code  = buf_parts-attr.pay-code
          v-in-code = buf_parts-attr.in-code
          v-fact-date = (if buf_parts-attr.in-code = buf_parts-attr.income-in-code
                          then buf_parts-attr.fact-date
                          else ?)
          v-obj-type =  ub.parts.obj-type
          v-obj-code =  ub.parts.obj-code
          v-cst-code = buf_parts-attr.cst-code
          .
          if v-fact-date = ? then do:
            if T-parts then do:
              FIND FIRST ub.trn-doc No-LOCK WHERE
                          ub.trn-doc.doc-code = v-in-code No-ERROR.
            end.
            if avail ub.trn-doc then do:
              assign
              v-fact-date = ub.trn-doc.fact-date
              .
            end.
          end.
        end.  /*if not v-is-primary then do:*/
      end. /*if v-doc-type = {&expense}*/
      if NOT (v-doc-type = {&expense} and v-internal = no)
      or not available bf-in_parts-attr
      then do:
        assign
        v-is-attr      = yes
        v-parts-VAt-pc = buf_parts-attr.vat-pc
        v-parts-SLT-pc = buf_parts-attr.SLT-pc
        v-supp-type = buf_parts-attr.supp-type
        v-supp-code = buf_parts-attr.supp-code
        v-purch-code = buf_parts-attr.purch-code
        v-pay-code  = buf_parts-attr.pay-code
        v-in-code = buf_parts-attr.income-in-code
        v-fact-date = buf_parts-attr.fact-date
        v-obj-type =  ub.parts.obj-type
        v-obj-code =  ub.parts.obj-code
        v-cst-code = buf_parts-attr.cst-code
        .
      end.
    end.
    else do:
      assign
      v-is-attr      = no
      v-parts-VAt-pc = ub.parts.vat-pc
      v-parts-SLT-pc = ub.parts.SLT-pc
      v-supp-type = ub.parts.supp-type
      v-supp-code = ub.parts.supp-code
      v-purch-code = ub.parts.purch-code
      v-pay-code  = ub.parts.pay-code
      v-in-code = ub.parts.in-code
      v-fact-date = ?
      v-obj-type =  ub.parts.obj-type
      v-obj-code =  ub.parts.obj-code
      v-cst-code = ub.parts.cst-code
      .
      if T-parts then do:
        FIND FIRST ub.trn-doc No-LOCK WHERE
                    ub.trn-doc.doc-code = ub.parts.in-code No-ERROR.
      end.
      if avail ub.trn-doc then do:
        assign
        v-fact-date = ub.trn-doc.fact-date
        .
      end.
    end.
    release bf-in_parts-attr.
    IF NOT T-parts then do:
      IF T-supp then do:
        FIND FIRST sj-goods WHERE
                  sj-goods.artic = ub.doc-line.artic
              AND sj-goods.prod-type = ub.doc-line.prod-type
              AND sj-goods.prod-code = ub.doc-line.prod-code
              AND sj-goods.VAT-supp = v-parts-VAT-pc
              AND sj-goods.SLT-supp = v-parts-SLT-pc
              AND sj-goods.supp-type = v-supp-type
              AND sj-goods.supp-code = v-supp-code
              AND (NOT T-cons OR
                  (sj-goods.purch-code = v-purch-code
                  and
                  sj-goods.pay-code = v-pay-code)
                  )
              AND sj-goods.obj-type = for-doc.obj-type
              AND sj-goods.obj-code = for-doc.obj-code
                  No-error.
      end.
      ELSE do:
        FIND FIRST sj-goods WHERE
                  sj-goods.artic = ub.doc-line.artic
              AND sj-goods.prod-type = ub.doc-line.prod-type
              AND sj-goods.prod-code = ub.doc-line.prod-code
              AND sj-goods.VAT-supp = v-parts-VAT-pc
              AND sj-goods.SLT-supp = v-parts-SLT-pc
              AND (NOT T-cons OR
                  (sj-goods.purch-code = v-purch-code
                  and
                  sj-goods.pay-code = v-pay-code)
                  )
              AND sj-goods.obj-type = for-doc.obj-type
              AND sj-goods.obj-code = for-doc.obj-code
                  No-error.
      end.
    END. /*t-parts*/
    else do:
      IF T-supp then do:
        FIND FIRST sj-goods WHERE
                  sj-goods.artic = ub.doc-line.artic
              AND sj-goods.prod-type = ub.doc-line.prod-type
              AND sj-goods.prod-code = ub.doc-line.prod-code
              AND sj-goods.VAT-supp = v-parts-VAT-pc
              AND sj-goods.SLT-supp = v-parts-SLT-pc
              AND sj-goods.supp-type = v-supp-type
              AND sj-goods.supp-code = v-supp-code
              AND sj-goods.in-code = v-in-code
              AND (NOT T-cons OR
                  (sj-goods.purch-code = v-purch-code
                  and
                  sj-goods.pay-code = v-pay-code)
                  )
              AND sj-goods.obj-type = for-doc.obj-type
              AND sj-goods.obj-code = for-doc.obj-code
                  No-error.
      end.
      ELSE do:
        FIND FIRST sj-goods WHERE
                   sj-goods.artic = ub.doc-line.artic
              AND  sj-goods.prod-type = ub.doc-line.prod-type
              AND  sj-goods.prod-code = ub.doc-line.prod-code
              AND  sj-goods.VAT-supp = v-parts-VAT-pc
              AND  sj-goods.SLT-supp = v-parts-SLT-pc
              AND  sj-goods.in-code = v-in-code
              AND   (NOT T-cons OR
                     (sj-goods.purch-code = v-purch-code
                     and
                     sj-goods.pay-code = v-pay-code)
                    )
              AND sj-goods.obj-type = for-doc.obj-type
              AND sj-goods.obj-code = for-doc.obj-code
                  No-error.
        end.
      end.
      if not avail sj-goods
      OR
      (T-split
        AND
      sj-goods.is-out_ <> is-out) then do:
        FIND FIRST ub.goods No-LOCK WHERE
                    ub.goods.artic = ub.doc-line.artic AND
                    ub.goods.prod-type = ub.doc-line.prod-type AND
                    ub.goods.prod-code = ub.doc-line.prod-code No-ERROR.
        FIND ub.gds-prt where
            ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK .
        FIND FIRST ub.bar-code No-LOCK WHERE
                  ub.bar-code.gds-code = ub.goods.gds-code AND
                  ub.bar-code.in-code = "" AND
                  ub.bar-code.part-code = "" AND
                  ub.bar-code.node-code =  ub.gds-prt.node-code AND
                  ub.bar-code.unit-cli = ub.goods.unit-base NO-ERROR.

        create sj-goods.
        { gbl/hostcode.i v-obj-type v-obj-code v-host-code }
        { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} ? v-host-code v-obj-type v-obj-code v-vat-pc no-error }
        { gbl/pftxvalg.i goods.gds-code {&slt-tax-code} ? v-host-code v-obj-type v-obj-code v-slt-pc no-error }
        run grplib-get-full-name in this-procedure (
                                                     input goods.grp-code
                                                    ,output v-grp-name) no-error .
        if error-status:error then do:
          v-grp-name = "!!!!НЕИЗВЕСТНАЯ ГРУППА".
        end.
        assign
        sj-goods.artic = ub.goods.artic
        sj-goods.prod-type = ub.goods.prod-type
        sj-goods.prod-code = ub.goods.prod-code
        sj-goods.b-code = ub.bar-code.b-code
        sj-goods.VAT-PC = v-vat-pc
        sj-goods.SLT-pc = v-slt-pc
        sj-goods.unit = ub.goods.unit-base
        sj-goods.struct = ub.goods.struct
        sj-goods.cst-code = v-cst-code
        sj-goods.is-prt = ub.gds-prt.node-name <> {&empty-scale}
        sj-goods.prt-root = ub.goods.prt-root
        sj-goods.gds-name = REPLACE(ub.goods.gds-name, " ", "_")
        sj-goods.grp-name = ub.goods.grp-name
        sj-goods.VAT-supp = v-parts-VAT-pc
        sj-goods.SLT-supp = v-parts-SLT-pc
        sj-goods.supp-type = IF T-supp OR T-parts then v-supp-type else ""
        sj-goods.supp-code = IF T-supp OR T-parts then v-supp-code else 0
        sj-goods.purch-code = IF T-cons or T-parts
                            then v-purch-code
                            else sj-goods.purch-code
        sj-goods.pay-code = IF T-cons or T-parts
                            then v-pay-code
                            else sj-goods.pay-code
        sj-goods.in-code = if T-parts then v-in-code else ""
        sj-goods.fact-date = if T-parts then v-fact-date else ?
        sj-goods.arch-date = if T-parts then v-fact-date else ?
        sj-goods.obj-code = if T-parts then v-obj-code else ?
        sj-goods.obj-type = if T-parts then v-obj-type else ?
        sj-goods.is-out_ = is-out
        .
      END. /*if not avail sj-goods*/

      { str/in-vatp.i calc-parts parts. " " g }

      assign
      prt-qnty =  is-out * ub.parts.fact-qnty
      sj-goods.qnty = sj-goods.qnty +  prt-qnty
      sj-goods.sale-sum-base = sj-goods.sale-sum-base + sale_sum_base / doc-line.fact-qnty  * prt-qnty
      sj-goods.sale-sum-rubl = sj-goods.sale-sum-rubl + sale_sum_rubl / doc-line.fact-qnty * prt-qnty
      sj-goods.uchet-price-base = if T-parts then ub.parts.price-base else 0
      sj-goods.uchet-price-rubl = if T-parts then ub.parts.price-rubl else 0
      sj-goods.uchet-sum-base = sj-goods.uchet-sum-base + ub.parts.price-base * prt-qnty
      sj-goods.uchet-sum-rubl = sj-goods.uchet-sum-rubl + ub.parts.price-rubl * prt-qnty
      sj-goods.uchet-sum-base-without-tax = sj-goods.uchet-sum-base-without-tax +
                                            (price-base-with-tax-loc - slt-base-loc - vat-base-loc) * prt-qnty
      sj-goods.uchet-sum-rubl-without-tax = sj-goods.uchet-sum-rubl-without-tax +
                                            (price-rubl-with-tax-loc  - slt-rubl-loc - vat-rubl-loc) * prt-qnty
      .
  END. /*FOR EACH parts*/
END. /*FOR EACH doc-line*/


/* $Workfile$ e n d */