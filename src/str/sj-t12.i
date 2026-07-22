/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сбор данных по накладным продажи - по чекам - для формы torg12

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/01/04
Author: Bakhtadze Natalya
Creation date: 06/01/04

требует наличи

{ cmp/trg-def.i }
{ str/out-vatp.i def }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


define temp-table sj-t12 no-undo
field b-code                          like ub.bar-code.b-code
field gds-code                        like ub.goods.gds-code
field prt-code                        like ub.gds-dtl.prt-code
field artic                           like ub.goods.artic
field prod-type                       like ub.goods.prod-type
field prod-code                       like ub.goods.prod-code
field doc-qnty                        like ub.gds-dtl.doc-qnty
field fact-qnty                       like ub.gds-dtl.fact-qnty

field gds-dtl-qnty                    like ub.gds-dtl.doc-qnty
/*это копируется c gds-dtl чтобы рассчитать outvat-p*/
field cur-base                        like ub.gds-dtl.cur-base
field discnt-base                     like ub.gds-dtl.discnt-base
field discnt-pc                       like ub.gds-dtl.discnt-pc
field discnt-rubl                     like ub.gds-dtl.discnt-rubl
field discnt-type                     like ub.gds-dtl.discnt-type
field doc-code                        like ub.gds-dtl.doc-code
field obj-code                        like ub.gds-dtl.obj-code
field obj-type                        like ub.gds-dtl.obj-type
field ov                              like ub.gds-dtl.ov
field price-base                      like ub.gds-dtl.price-base
field price-rubl                      like ub.gds-dtl.price-rubl
/*-----*/


field vat-pc                           like ub.doc-line.vat-pc
field slt-pc                           like ub.doc-line.slt-pc

field price-rubl-with-tax-sale         like ub.gds-dtl.price-rubl
field price-base-with-tax-sale         like ub.gds-dtl.price-base
field price-rubl-without-tax-sale      like ub.gds-dtl.price-rubl
field price-base-without-tax-sale      like ub.gds-dtl.price-base
field vat-base-sale                    like ub.gds-dtl.price-base
field vat-rubl-sale                    like ub.gds-dtl.price-rubl
field vat-base-buyer                   like ub.gds-dtl.price-base
field vat-rubl-buyer                   like ub.gds-dtl.price-rubl
field slt-base-sale                    like ub.gds-dtl.price-base
field slt-rubl-sale                    like ub.gds-dtl.price-rubl
field road-tax-base-sale               like ub.gds-dtl.price-base
field road-tax-rubl-sale               like ub.gds-dtl.price-rubl
field excise-base-sale                 like ub.gds-dtl.price-base
field excise-rubl-sale                 like ub.gds-dtl.price-rubl
field discnt-base-sale                 like ub.gds-dtl.price-base
field discnt-rubl-sale                 like ub.gds-dtl.price-rubl

field is-ok                            as logical
field calced                           as logical


index pi is unique primary
b-code
index iok
is-ok
.

procedure fill-sjt12 :
  _main:
  do
  on error undo, return error
  :

    define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .

    define variable v-inkas-code like ub.inkas.inkas-code no-undo .
    define variable v-trn-doc-code like ub.trn-doc.doc-code no-undo .
    define variable v-ret-doc-code like ub.trn-doc.out-code no-undo .
    define variable v-doc-code     like ub.trn-doc.doc-code no-undo .
    define variable check-v-doc-code     like ub.trn-doc.doc-code no-undo .

    define buffer buf_trn-doc for ub.trn-doc.
    define buffer buf_ret-doc for ub.trn-doc.
    define buffer buf_inkas for ub.inkas.
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_goods for ub.goods.
    define buffer buf_bar-code for ub.bar-code.
    define buffer buf_sj-t12 for sj-t12.
    define buffer buf_gds-dtl for ub.gds-dtl.
    define buffer buf_doc-line for ub.doc-line.
    define buffer buf_sale-doc for ub.sale-doc.

      FOR EACH sj-t12 :
        delete sj-t12 .
      END .
      find first buf_trn-doc no-lock where
                buf_trn-doc.doc-code = p-doc-code no-error .
      if not available buf_trn-doc then do:
        undo _main, return error substitute("Не найден документ с номером &1", p-doc-code).
      end.

      if NOT (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
              or
              buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
              ) then do:
        undo _main, return error substitute("Неверный тип документа &1: &2", p-doc-code, buf_trn-doc.ext-doc-type).
      end.
      if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} then do:
        assign
        v-inkas-code = buf_trn-doc.doc-code
        v-trn-doc-code = buf_trn-doc.doc-code
        v-ret-doc-code = buf_trn-doc.out-code
        v-doc-code     = v-trn-doc-code
        .
      end.
      else do:
        assign
        v-inkas-code = buf_trn-doc.out-code
        v-trn-doc-code = buf_trn-doc.out-code
        v-ret-doc-code = buf_trn-doc.doc-code
        v-doc-code     = v-ret-doc-code
        .
      end.
      _chk-doc:
      FOR EACH buf_chk-doc No-LOCK WHERE
                buf_chk-doc.obj-type = buf_trn-doc.obj-type AND
                buf_chk-doc.obj-code = buf_trn-doc.obj-code AND
                buf_chk-doc.out-code = v-inkas-code,
          EACH buf_chk-gds WHERE
                buf_chk-gds.doc-code = buf_chk-doc.doc-code NO-LOCK,
          FIRST buf_bar-code WHERE
                buf_bar-code.b-code = buf_chk-gds.b-code NO-LOCK,
          FIRST buf_goods WHERE
                buf_goods.gds-code = buf_bar-code.gds-code
                :
        if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
        if num-entries(buf_chk-gds.line-type, {&delim-par}) > 1 then do:
          find first buf_sale-doc no-lock where
                    buf_sale-doc.inkas-code = v-inkas-code
                and buf_sale-doc.doc-kind = entry(1, entry(2, buf_chk-gds.line-type, {&delim-par})) no-error .
          if available buf_sale-doc then do:
            assign
            check-v-doc-code = buf_sale-doc.doc-code.
          end.
        end.
        if v-doc-code = '':U then do:
          if buf_chk-doc.netto >= 0 then
          check-v-doc-code = v-trn-doc-code.
          else
          check-v-doc-code = v-ret-doc-code.
        end.
        if check-v-doc-code <> v-doc-code then do:
       /*чек не того типа - пропускаем*/
         next _chk-doc.
       end.
        FIND FIRST buf_gds-dtl WHERE
                  buf_gds-dtl.doc-code  = v-doc-code AND
                  buf_gds-dtl.artic     = buf_goods.artic AND
                  buf_gds-dtl.prod-type = buf_goods.prod-type AND
                  buf_gds-dtl.prod-code = buf_goods.prod-code AND
                  buf_gds-dtl.prt-code  = buf_bar-code.node-code NO-LOCK NO-ERROR .
        if available buf_gds-dtl then do:
          FIND FIRST buf_doc-line WHERE
                    buf_doc-line.doc-code  = buf_gds-dtl.doc-code AND
                    buf_doc-line.prod-type = buf_gds-dtl.prod-type AND
                    buf_doc-line.prod-code = buf_gds-dtl.prod-code  AND
                    buf_doc-line.artic     = buf_gds-dtl.artic NO-LOCK NO-ERROR.
        end.
        find first buf_sj-t12 where
                  buf_sj-t12.b-code   = buf_chk-gds.b-code
              AND buf_sj-t12.gds-code = buf_goods.gds-code no-error .
        if not available buf_sj-t12
        and available buf_gds-dtl
        then do:
          create buf_sj-t12.
          buffer-copy buf_gds-dtl
          using
          artic
          prod-type
          prod-code
          cur-base
          discnt-base
          discnt-pc
          discnt-rubl
          discnt-type
          doc-code
          obj-code
          obj-type
          ov
          price-base
          price-rubl
          to  buf_sj-t12
          assign
          buf_sj-t12.b-code    = buf_Chk-gds.b-code
          buf_sj-t12.gds-code  = buf_goods.gds-code
          buf_sj-t12.prt-code  = buf_bar-code.node-code
          buf_sj-t12.gds-dtl-qnty = buf_gds-dtl.doc-qnty
          .
        end.
        if available buf_sj-t12 then do:
          assign
          buf_sj-t12.doc-qnty    = buf_sj-t12.doc-qnty + (if buf_chk-doc.netto >= 0 then 1 else - 1) * buf_chk-gds.doc-qnty
          buf_sj-t12.fact-qnty    = buf_sj-t12.fact-qnty + (if buf_chk-doc.netto >= 0 then 1 else - 1) * buf_chk-gds.doc-qnty
          buf_sj-t12.gds-dtl-qnty = buf_gds-dtl.doc-qnty
          buf_sj-t12.IS-OK        = (buf_sj-t12.gds-dtl-qnty = buf_sj-t12.fact-qnty)
          .
        end.
        if available buf_gds-dtl
        and available buf_doc-line
        and buf_doc-line.doc-qnty <> 0
        and available buf_sj-t12
        and not buf_sj-t12.calced
        then do:
          /*может уже все СУММЫ рассчитать и поставить галочку что рассчитали*/
          { str/out-vatp.i calc-gds-dtl buf_doc-line. buf_trn-doc. buf_gds-dtl. }
          assign
          buf_sj-t12.price-rubl-with-tax-sale     = price-rubl-with-tax-sale
          buf_sj-t12.price-base-with-tax-sale     = price-base-with-tax-sale
          buf_sj-t12.price-rubl-without-tax-sale  = price-rubl-without-tax-sale
          buf_sj-t12.price-base-without-tax-sale  = price-base-without-tax-sale
          buf_sj-t12.vat-base-sale                = vat-base-sale
          buf_sj-t12.vat-rubl-sale                = vat-rubl-sale
          buf_sj-t12.vat-base-buyer               = vat-base-buyer
          buf_sj-t12.vat-rubl-buyer               = vat-rubl-buyer
          buf_sj-t12.slt-base-sale                = slt-base-sale
          buf_sj-t12.slt-rubl-sale                = slt-rubl-sale
          buf_sj-t12.road-tax-base-sale           = road-tax-base-sale
          buf_sj-t12.road-tax-rubl-sale           = road-tax-rubl-sale
          buf_sj-t12.excise-base-sale             = excise-base-sale
          buf_sj-t12.excise-rubl-sale             = excise-rubl-sale
          buf_sj-t12.discnt-base-sale             = discnt-base-sale
          buf_sj-t12.discnt-rubl-sale             = discnt-rubl-sale
          buf_sj-t12.vat-pc                       = buf_doc-line.vat-pc
          buf_sj-t12.slt-pc                       = buf_doc-line.slt-pc
          buf_sj-t12.calced                       = yes
          .
        end.
        else do:
        end.
      end. /*for each chk-doc*/
      for each buf_sj-t12 where
              buf_sj-t12.is-ok = no:
        if buf_sj-t12.gds-dtl-qnty > 0 then do:

        end.
        else do:
          find first buf_doc-line no-lock where
                    buf_doc-line.doc-code  = buf_sj-t12.doc-code
              AND  buf_doc-line.artic     = buf_sj-t12.artic
              AND  buf_doc-line.prod-type = buf_sj-t12.prod-type
              AND  buf_doc-line.prod-code = buf_sj-t12.prod-code .
          { str/out-vatp.i calc-gds-dtl buf_doc-line. buf_trn-doc. buf_sj-t12. }
          assign
          buf_sj-t12.price-rubl-with-tax-sale     = price-rubl-with-tax-sale
          buf_sj-t12.price-base-with-tax-sale     = price-base-with-tax-sale
          buf_sj-t12.price-rubl-without-tax-sale  = price-rubl-without-tax-sale
          buf_sj-t12.price-base-without-tax-sale  = price-base-without-tax-sale
          buf_sj-t12.vat-base-sale                = vat-base-sale
          buf_sj-t12.vat-rubl-sale                = vat-rubl-sale
          buf_sj-t12.vat-base-buyer               = vat-base-buyer
          buf_sj-t12.vat-rubl-buyer               = vat-rubl-buyer
          buf_sj-t12.slt-base-sale                = slt-base-sale
          buf_sj-t12.slt-rubl-sale                = slt-rubl-sale
          buf_sj-t12.road-tax-base-sale           = road-tax-base-sale
          buf_sj-t12.road-tax-rubl-sale           = road-tax-rubl-sale
          buf_sj-t12.excise-base-sale             = excise-base-sale
          buf_sj-t12.excise-rubl-sale             = excise-rubl-sale
          buf_sj-t12.discnt-base-sale             = discnt-base-sale
          buf_sj-t12.discnt-rubl-sale             = discnt-rubl-sale
          buf_sj-t12.vat-pc                       = buf_doc-line.vat-pc
          buf_sj-t12.slt-pc                       = buf_doc-line.slt-pc
          buf_sj-t12.calced                       = yes
          .

        end.
      END. /* for each buf_sj-t12 where */

  end.

end procedure. /* fill-sjt12 */