/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тело для inv3

Автор: Булгаков Андрей Николаевич
Дата создания: 10/04/05
Author: Andrew Bulgakoff
Creation date: 10/04/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable is-petrol as logical no-undo.
define variable is-pieces as logical no-undo.

define buffer buf_inv-line for ub.inv-line.

for each  buf_doc-line no-lock where
          buf_doc-line.doc-code = buf_trn-doc.doc-code
  , first buf_inv-line no-lock where
          buf_inv-line.doc-code  = buf_doc-line.doc-code  and
          buf_inv-line.artic     = buf_doc-line.artic     and
          buf_inv-line.prod-type = buf_doc-line.prod-type and
          buf_inv-line.prod-code = buf_doc-line.prod-code
  , first buf_goods no-lock where
          buf_goods.prod-type = buf_doc-line.prod-type and
          buf_goods.prod-code = buf_doc-line.prod-code and
          buf_goods.artic     = buf_doc-line.artic
  , first ub.units no-lock where
          ub.units.unit-name = buf_goods.unit-base
:
  { str/is-petrl.i buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code is-petrol is-pieces no-error }
  if error-status :error or is-petrol <> yes or is-pieces <> no then do: next. end.
  { gbl/gdsbcode.i buf_goods.gds-code ? b-code no-error }
  if error-status :error then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошибка при определении бар-кода товара"     skip
            "Артикул товара:" buf_goods.artic            skip
            "Производитель:"  buf_goods.prod-type buf_goods.prod-code skip
            error-status :get-message( 1 ) skip
            error-status :get-message( 2 ) skip
            return-value                   skip( 1 )
    view-as alert-box error.
  end.

  assign Counter1 = Counter1 + 1.
  { rep/repfrm.i disp Counter1 }
  create temp-str.
  assign temp-str.b-code      = string( b-code )
         temp-str.grp-name    = buf_goods.grp-name
         temp-str.artic       = buf_goods.artic
         temp-str.prod-type   = buf_goods.prod-type
         temp-str.prod-code   = buf_goods.prod-code
         temp-str.gds-code    = buf_goods.gds-code
         temp-str.OKEI        = units.OKEI
         temp-str.unit-base   = buf_goods.unit-cli
         temp-str.tb-code     = buf_goods.sort
         temp-str.gds-name    = ( if g#gds-engl = yes then buf_goods.engl-name else buf_goods.gds-name ).
  { gbl/rootnode.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code v-root-node }
  { gbl/prtat.i v-root-node  "'empty-scale=request'"  temp-str.empty-scale }

  if rep-tipe = "invent" then do: /* инвентаризационная опись */
    find first buf_doc-line-sum no-lock where
               buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
               buf_doc-line-sum.gds-code = buf_goods.gds-code    and
               buf_doc-line-sum.sum-type = {&sum-before-doc}     no-error.
    if costprice = yes then do:
      if p-no-vat = "no" then do:
        if PrintRubl = yes then do: assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-rubl. end.
                           else do: assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-base. end.
      end.
      else do:
        if PrintRubl = yes then do: assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-VAT-rubl. end.
                           else do: assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-base - buf_doc-line-sum.cost-VAT-base. end.
      end.
    end.
    else do:
      if PrintRubl = yes then do: assign temp-str.b-stoim = buf_doc-line-sum.crsa-sum-rubl. end.
                         else do: assign temp-str.b-stoim = buf_doc-line-sum.crsa-sum-base. end.
    end.
    assign temp-str.b-qnty      = ( buf_inv-line.wast-cli-qnty - buf_doc-line.cli-qnty )
           temp-str.price-befor = temp-str.b-stoim / temp-str.b-qnty.
    if temp-str.price-befor = ? then do: assign temp-str.price-befor = 0. end.

    if is-after = yes then do: /* уже рассчитаны суммы после */
      find first buf_doc-line-sum no-lock where
                 buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                 buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                 buf_doc-line-sum.sum-type = {&sum-after-doc}      no-error.
      if costprice = yes then do:
        if p-no-vat = "no" then do:
          if PrintRubl = yes then do: assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-rubl. end.
                             else do: assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-base. end.
        end.
        else do:
          if PrintRubl = yes then do: assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-VAT-rubl. end.
                             else do: assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-base - buf_doc-line-sum.cost-VAT-base. end.
        end.
      end.
      else do:
        if PrintRubl = yes then do: assign temp-str.a-stoim = buf_doc-line-sum.crsa-sum-rubl. end.
                           else do: assign temp-str.a-stoim = buf_doc-line-sum.crsa-sum-base. end.
      end.
      assign temp-str.a-qnty      = buf_inv-line.wast-cli-qnty
             temp-str.price-after = temp-str.a-stoim / temp-str.a-qnty.
    end.
    else do: /* нет сумм после ! */
      if costprice = yes then do:
        if PrintRubl = yes then do: assign sum = buf_doc-line.price-rubl * buf_doc-line.fact-qnty. end.
                           else do: assign sum = buf_doc-line.price-base * buf_doc-line.fact-qnty. end.
      end.
      else do:
        assign sum = 0.
        for each buf_gds-dtl no-lock where
                 buf_gds-dtl.doc-code  = buf_doc-line.doc-code  and
                 buf_gds-dtl.artic     = buf_doc-line.artic     and
                 buf_gds-dtl.prod-type = buf_doc-line.prod-type and
                 buf_gds-dtl.prod-code = buf_doc-line.prod-code :
          if PrintRubl = yes then do: assign sum = sum + buf_gds-dtl.price-rubl * buf_gds-dtl.doc-qnty. end.
                             else do: assign sum = sum + buf_gds-dtl.price-base * buf_gds-dtl.doc-qnty. end.
        end.
      end.
      assign temp-str.a-stoim     = temp-str.b-stoim + sum
             temp-str.a-qnty      = temp-str.b-qnty  + buf_inv-line.wast-cli-qnty
             temp-str.price-after = temp-str.a-stoim / temp-str.a-qnty.
    end.
    if temp-str.price-after = ? then do: assign temp-str.price-after = 0. end.

    if v-prn0 = "no" then do:
      if temp-str.a-qnty = 0 and temp-str.a-stoim = 0 and temp-str.b-qnty = 0 and temp-str.b-stoim = 0 then do:
        delete temp-str.
      end.
    end.
  end. /* инвентаризационная опись */
  else do: /* сличительная ведомость */
    if costprice = yes then do:
      if buf_doc-line.fact-qnty = 0 then do:
        if is-general = yes then do: /* уже рассчитаны суммы */
          find first buf_doc-line-sum no-lock where
                     buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                     buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                     buf_doc-line-sum.sum-type = {&sum-general-doc}    no-error.
          if PrintRubl = yes then do: assign sum = buf_doc-line-sum.cost-sum-rubl. end.
                             else do: assign sum = buf_doc-line-sum.cost-sum-base. end.
        end.
      end.
      else do:
        if PrintRubl = yes then do: assign sum = buf_doc-line.price-rubl * buf_doc-line.fact-qnty. end.
                           else do: assign sum = buf_doc-line.price-base * buf_doc-line.fact-qnty. end.
      end.
    end.
    else do:
      assign sum = 0.
      for each buf_gds-dtl no-lock where
               buf_gds-dtl.doc-code  = buf_doc-line.doc-code  and
               buf_gds-dtl.artic     = buf_doc-line.artic     and
               buf_gds-dtl.prod-type = buf_doc-line.prod-type and
               buf_gds-dtl.prod-code = buf_doc-line.prod-code :
        if PrintRubl = yes then do: assign sum = sum + buf_gds-dtl.price-rubl * buf_gds-dtl.doc-qnty. end.
                           else do: assign sum = sum + buf_gds-dtl.price-base * buf_gds-dtl.doc-qnty. end.
      end.
    end.
    assign qnty = buf_doc-line.cli-qnty.

    if sum >= 0 then do: /* излишек */
      assign temp-str.a-qnty      = qnty
             temp-str.a-stoim     = sum
             temp-str.a-qnty1     = buf_doc-line.cli-qnty
             temp-str.ubl         = 0.
      if temp-str.a-qnty = 0 and temp-str.a-stoim = 0 then do: delete temp-str. end.
    end.
    else do: /* недостача */
      assign temp-str.b-qnty      = - qnty
             temp-str.b-stoim     = - sum
             temp-str.b-qnty1     = - buf_doc-line.cli-qnty
             temp-str.ubl         = 0
             sum                  = - sum.
      if is-wastage = yes then do:
        find first buf_doc-line-sum no-lock where
                   buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                   buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                   buf_doc-line-sum.sum-type = {&sum-wastage-doc}    no-error.
        if available buf_doc-line-sum then do:
          if costprice = yes then do:
            if PrintRubl = yes then do: assign temp-str.ubl = buf_doc-line-sum.cost-sum-rubl. end.
                               else do: assign temp-str.ubl = buf_doc-line-sum.cost-sum-base. end.
          end.
          else do:
            if PrintRubl = yes then do: assign temp-str.ubl = buf_doc-line-sum.sale-sum-rubl. end.
                               else do: assign temp-str.ubl = buf_doc-line-sum.sale-sum-base. end.
          end.
          if sum < temp-str.ubl then do: assign temp-str.ubl = sum. end.
        end.
      end.
      if temp-str.b-qnty = 0 and temp-str.b-stoim = 0 then do: delete temp-str. end.
    end. /* недостача */
  end. /* сличительная ведомость */
end. /* for each buf_doc-line */

/* $Workfile$   E n d */