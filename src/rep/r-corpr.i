/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

К печати совокупной накладной расхода, возврата r-corpr1.p и счетуфакт  r-corpr2.p по сменетипа приобрет.

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  DEFINE temp-table gds-prop no-undo
    field   artic            as  char
    field   prod-type        as  char
    field   prod-code        as  integer
    field   part-code        like parts.part-code
    field   in-code          like parts.in-code
    field   gds-code         as  integer
    field   gds-name         as  char
    field   gds-name1        as  char
    field   grp-name         as  char
    field   unit-base        as  char
    field   b-code           as  integer
    field   qnty             as  decimal
    field   price-no-VAT      as  decimal
    field   sum-no-VAT      as  decimal
    field   VAT-pc           as  decimal
    field   VAT          as  decimal
    field   stoim            as  decimal
    field   sum              as  decimal
    field   sum-actciz       as  decimal
    field   gds-type         as character
    field   country          as character
    field   GTD              as character
    INDEX pi  IS PRIMARY   artic  prod-type prod-code part-code in-code
    INDEX pi1              gds-name
    INDEX pi2              grp-name
 .

  define buffer buf_trn-doc       for trn-doc.
  define buffer buf_goods         for goods.
  define buffer buf_parts         for parts .

  define variable v-obj-type like clients.obj-type .
  define variable v-obj-code like clients.obj-code .
  define variable v-fact-order-start  as decimal   no-undo .
  define variable v-fact-order-end    as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input x-date-start,         output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

  for each obj-list no-lock :
    assign
      v-obj-type = obj-list.obj-type
      v-obj-code = obj-list.obj-code
    .
    for each buf_trn-doc no-lock
      where buf_trn-doc.obj-type = obj-list.obj-type
        and buf_trn-doc.obj-code = obj-list.obj-code
        and buf_trn-doc.status_  = {&fact}
        and buf_trn-doc.fact-order >= v-fact-order-start
        and buf_trn-doc.fact-order < v-fact-order-end
      :
      if buf_trn-doc.ext-doc-type <> {&TDEDT_Chg_Purch_Code} then next .

      for each parts-root no-lock where parts-root.doc-code = buf_trn-doc.doc-code :
        find first buf_goods where buf_goods.gds-code = parts-root.gds-code no-lock .
        find first buf_parts no-lock
          where buf_parts.artic     = buf_goods.artic
            and buf_parts.prod-code = buf_goods.prod-code
            and buf_parts.prod-type = buf_goods.prod-type
            and buf_parts.part-code = parts-root.part-code
            and buf_parts.in-code   = parts-root.in-code
            and buf_parts.out-code  = buf_trn-doc.doc-code
            and buf_parts.obj-code  = buf_trn-doc.obj-code
            and buf_parts.obj-type  = buf_trn-doc.obj-type
          no-error .
        if (buf_parts.supp-type <> p-cli-type or buf_parts.supp-code <> p-cli-code) then next .

        find first gds-prop
          where gds-prop.artic     = buf_goods.artic
            and gds-prop.prod-code = buf_goods.prod-code
            and gds-prop.prod-type = buf_goods.prod-type
            and gds-prop.part-code = parts-root.part-code
            and gds-prop.in-code   = parts-root.in-code
          no-error .
        if not available gds-prop then do:
          create gds-prop .
          { gbl/gdsbcode.i  buf_goods.gds-code  ?  gds-prop.b-code  no-error }
          if error-status :error then do:
            message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip  "Код товара" buf_goods.gds-code skip
            view-as alert-box error .
          end.
          assign
            gds-prop.artic     = buf_goods.artic
            gds-prop.prod-type = buf_goods.prod-type
            gds-prop.prod-code = buf_goods.prod-code
            gds-prop.gds-code  = buf_goods.gds-code
            gds-prop.gds-name  = buf_goods.gds-name
            gds-prop.grp-name  = buf_goods.grp-name
            gds-prop.unit-base = buf_goods.unit-base
            gds-prop.part-code = parts-root.part-code
            gds-prop.in-code   = parts-root.in-code
            gds-prop.VAT-pc    = buf_parts.VAT-pc
            gds-prop.GTD       = buf_parts.cst-code
          .
          if is_rem = ? then do:
            find first country no-lock  where country.alpha1 = buf_goods.alpha1  no-error.
            if available country then assign gds-prop.country = country.short-name .
            else                      assign gds-prop.country = "" .

            find first Units no-lock where units.unit-name = buf_goods.unit-base .
            if (units.type = "{&bef-divisional},{&bef-twounit}"  or  units.type = "{&bef-divisional},{&bef-altunit}" ) then
              assign gds-prop.gds-name = string(buf_goods.artic,"x(16)") +  " "  + string(buf_goods.Sort,"x(5)") + " " + trim(buf_goods.gds-name) + " " + trim(buf_goods.PS) .
            else assign gds-prop.gds-name = string(buf_goods.artic,"x(16)") +  " "  + trim(buf_goods.gds-name) .
          end.
          else do:
            if g#gds-engl then assign gds-prop.gds-name = buf_goods.engl-name.
            else               assign gds-prop.gds-name = buf_goods.gds-name.
          end.
        end.
        create tt-clcparts.
        buffer-copy buf_parts to tt-clcparts.
        run clcprtsl_calc-parts (input recid (tt-clcparts), input no, input no,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ) .
        find first tt-allsum where tt-allsum.sum-type = {&sum-general}.

        assign  gds-prop.qnty = gds-prop.qnty + ABSOLUTE(buf_parts.fact-qnty) .
        if x-SET_val_TYPE = 1 then
          assign
            gds-prop.price-no-VAT = gds-prop.price-no-VAT + ABSOLUTE(tt-allsum.sum-dsc-rubl-acc - tt-allsum.slt-rubl-acc - tt-allsum.vat-rubl-acc) / gds-prop.qnty
            gds-prop.sum-no-VAT   = gds-prop.sum-no-VAT   + ABSOLUTE(tt-allsum.sum-dsc-rubl-acc - tt-allsum.slt-rubl-acc - tt-allsum.vat-rubl-acc)
            gds-prop.VAT          = gds-prop.VAT          + ABSOLUTE(tt-allsum.vat-rubl-acc)
            gds-prop.stoim        = gds-prop.stoim        + ABSOLUTE(tt-allsum.sum-dsc-rubl-acc - tt-allsum.slt-rubl-acc)
            gds-prop.sum          = gds-prop.sum          + ABSOLUTE(tt-allsum.sum-dsc-rubl-acc)
            v-tax-sum             = v-tax-sum             + ABSOLUTE(tt-allsum.road-tax-rubl-acc)
            v-tot-discnt          = v-tot-discnt          + ABSOLUTE(tt-allsum.dsc-rubl-acc)
          .
        else
          assign
            gds-prop.price-no-VAT = gds-prop.price-no-VAT + ABSOLUTE(tt-allsum.sum-dsc-base-acc - tt-allsum.slt-base-acc - tt-allsum.vat-base-acc) / gds-prop.qnty
            gds-prop.sum-no-VAT   = gds-prop.sum-no-VAT   + ABSOLUTE(tt-allsum.sum-dsc-base-acc - tt-allsum.slt-base-acc - tt-allsum.vat-base-acc)
            gds-prop.VAT          = gds-prop.VAT          + ABSOLUTE(tt-allsum.vat-base-acc)
            gds-prop.stoim        = gds-prop.stoim        + ABSOLUTE(tt-allsum.sum-dsc-base-acc - tt-allsum.slt-base-acc)
            gds-prop.sum          = gds-prop.sum          + ABSOLUTE(tt-allsum.sum-dsc-base-acc)
            v-tax-sum             = v-tax-sum             + ABSOLUTE(tt-allsum.road-tax-base-acc)
            v-tot-discnt          = v-tot-discnt          + ABSOLUTE(tt-allsum.dsc-base-acc)
          .
      end.
    end.
  end.

/* $Workfile$ e n d */