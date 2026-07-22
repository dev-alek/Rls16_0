/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

тело для inv3

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/22/06
Author: Michael Kochetkov
Creation date: 03/22/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
  find first buf_goods no-lock where
             buf_goods.prod-type = buf_doc-line.prod-type and
             buf_goods.prod-code = buf_doc-line.prod-code and
             buf_goods.artic     = buf_doc-line.artic     no-error.
  find first ub.units no-lock where ub.units.unit-name = buf_goods.unit-base no-error.

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

  if p-grp = "yes":U then do :
  find first buf_gds-grp where buf_gds-grp.node-code = buf_goods.grp-code no-error .
      run grplib-get-full-name in this-procedure
      (  input buf_gds-grp.node-code
      , output full-grp-name
      ) .
  case v-classify :
    when "no-classify":U
    then do:
      if buf_gds-grp.lvl-num = 1 then do :
        create temp-str.
        assign temp-str.b-code     = string( b-code )
              temp-str.grp-name    = buf_gds-grp.node-name
              temp-str.artic       = buf_goods.artic
              temp-str.prod-type   = buf_goods.prod-type
              temp-str.prod-code   = buf_goods.prod-code
              temp-str.gds-code    = buf_goods.gds-code
              temp-str.OKEI        = units.OKEI
              temp-str.unit-base   = buf_goods.unit-base
              temp-str.tb-code     = buf_goods.sort
              temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
              .
        end.
      if buf_gds-grp.lvl-num > 1 and buf_gds-grp.upper-code ne 0 then do :
          run no-classify in this-procedure ( input buf_gds-grp.upper-code, output full-grp-name ) no-error .
          create temp-str.
          assign temp-str.b-code   = string( b-code )
              temp-str.grp-name    = full-grp-name
              temp-str.artic       = buf_goods.artic
              temp-str.prod-type   = buf_goods.prod-type
              temp-str.prod-code   = buf_goods.prod-code
              temp-str.gds-code    = buf_goods.gds-code
              temp-str.OKEI        = units.OKEI
              temp-str.unit-base   = buf_goods.unit-base
              temp-str.tb-code     = buf_goods.sort
              temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
              .
        end.
    end.
    when "n-level":U
    then do:
        if   buf_gds-grp.lvl-num = v-var-level
        or ( buf_gds-grp.lvl-num <  v-var-level and buf_gds-grp.is-term  = yes )
          then do :
              create temp-str.
              assign temp-str.b-code = string( b-code )
                temp-str.grp-name    = full-grp-name
                temp-str.artic       = buf_goods.artic
                temp-str.prod-type   = buf_goods.prod-type
                temp-str.prod-code   = buf_goods.prod-code
                temp-str.gds-code    = buf_goods.gds-code
                temp-str.OKEI        = units.OKEI
                temp-str.unit-base   = buf_goods.unit-base
                temp-str.tb-code     = buf_goods.sort
                temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
              .
        end.
        else do:
          run n-level in this-procedure ( input buf_gds-grp.upper-code, input v-var-level, output full-grp-name ) no-error .
              create temp-str.
              assign temp-str.b-code = string( b-code )
                temp-str.grp-name    = full-grp-name
                temp-str.artic       = buf_goods.artic
                temp-str.prod-type   = buf_goods.prod-type
                temp-str.prod-code   = buf_goods.prod-code
                temp-str.gds-code    = buf_goods.gds-code
                temp-str.OKEI        = units.OKEI
                temp-str.unit-base   = buf_goods.unit-base
                temp-str.tb-code     = buf_goods.sort
                temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
              .
        end.
    end.
    when "t-level":U
    then do:
        if buf_gds-grp.is-term = true
        then do :
          create temp-str.
          assign temp-str.b-code = string( b-code )
            temp-str.grp-name    = buf_gds-grp.node-name
            temp-str.artic       = buf_goods.artic
            temp-str.prod-type   = buf_goods.prod-type
            temp-str.prod-code   = buf_goods.prod-code
            temp-str.gds-code    = buf_goods.gds-code
            temp-str.OKEI        = units.OKEI
            temp-str.unit-base   = buf_goods.unit-base
            temp-str.tb-code     = buf_goods.sort
            temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
          .
        end.
        else do:
            run t-level in this-procedure ( input buf_gds-grp.node-code, output full-grp-name ) no-error .
            create temp-str.
            assign temp-str.b-code = string( b-code )
              temp-str.grp-name    = full-grp-name
              temp-str.artic       = buf_goods.artic
              temp-str.prod-type   = buf_goods.prod-type
              temp-str.prod-code   = buf_goods.prod-code
              temp-str.gds-code    = buf_goods.gds-code
              temp-str.OKEI        = units.OKEI
              temp-str.unit-base   = buf_goods.unit-base
              temp-str.tb-code     = buf_goods.sort
              temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
          .

        end.
    end.
  end case. /* v-classify */
end.
else do :
  create temp-str.
  assign temp-str.b-code      = string( b-code )
         temp-str.grp-name    = buf_goods.grp-name
         temp-str.artic       = buf_goods.artic
         temp-str.prod-type   = buf_goods.prod-type
         temp-str.prod-code   = buf_goods.prod-code
         temp-str.gds-code    = buf_goods.gds-code
         temp-str.OKEI        = units.OKEI
         temp-str.unit-base   = buf_goods.unit-base
         temp-str.tb-code     = buf_goods.sort
         temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
         .
end.
  if rep-tipe = "invent-gold" or rep-tipe = "sl-gold" then do:
    assign temp-str.gds-name = trim( buf_goods.gds-name ) + " ":U + trim( buf_goods.PS ).
  end.
  else do:
    assign temp-str.gds-name = ( if g#gds-engl = yes then buf_goods.engl-name else buf_goods.gds-name ).
  end.

  { gbl/rootnode.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code v-root-node }
  { gbl/prtat.i v-root-node  "'empty-scale=request'"  temp-str.empty-scale }

  if rep-tipe begins "invent" then do: /* это инвентариз. опись */
    find first buf_doc-line-sum no-lock where
               buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
               buf_doc-line-sum.gds-code = buf_goods.gds-code    and
               buf_doc-line-sum.sum-type = {&sum-before-doc}     no-error.
    if costprice = yes then do:
      if no-vat = no then do:
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
    assign temp-str.b-qnty      = buf_doc-line-sum.fact-qnty
           temp-str.price-befor = temp-str.b-stoim / temp-str.b-qnty.
    if temp-str.price-befor = ? then do: assign temp-str.price-befor = 0. end.

    if rep-tipe = "invent-gold" then do:
      find first buf_doc-line-sum no-lock where
                 buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                 buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                 buf_doc-line-sum.sum-type = {&sum-before-cli-doc} no-error.
      if available buf_doc-line-sum then do: assign temp-str.b-qnty1 = buf_doc-line-sum.fact-qnty. end.
    end.

    if is-after = yes then do: /* уже рассчитаны суммы после */
      find first buf_doc-line-sum no-lock where
                 buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                 buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                 buf_doc-line-sum.sum-type = {&sum-after-doc}      no-error.
      if costprice = yes then do:
        if no-vat = no then do:
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
      assign temp-str.a-qnty      = buf_doc-line-sum.fact-qnty
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
             temp-str.a-qnty      = temp-str.b-qnty  + buf_doc-line.fact-qnty
             temp-str.price-after = temp-str.a-stoim / temp-str.a-qnty.
    end.
    if temp-str.price-after = ? then do: assign temp-str.price-after = 0. end.

    if rep-tipe = "invent-gold" then do:
      if is-after-cli = yes then do:
        find first buf_doc-line-sum no-lock where
                   buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                   buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                   buf_doc-line-sum.sum-type = {&sum-after-cli-doc}  no-error.
        if available buf_doc-line-sum then do: assign temp-str.a-qnty1 = buf_doc-line-sum.fact-qnty. end.
      end.
      else do:
        assign temp-str.a-qnty1 = temp-str.b-qnty1 + buf_doc-line.cli-qnty.
      end.
    end.
    if v-prn0 = "no" then do:
      if temp-str.a-qnty = 0 and temp-str.a-stoim = 0 and temp-str.b-qnty = 0 and temp-str.b-stoim = 0 then do:
        delete temp-str.
      end.
    end.
  end.
  else do: /* сличительная ведомость */
    if costprice = yes then do:
      if is-general = yes then do: /* уже рассчитаны суммы */
        find first buf_doc-line-sum no-lock where
                   buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                   buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                   buf_doc-line-sum.sum-type = {&sum-general-doc}    no-error.
        if no-vat = no then do:
          if PrintRubl = yes then do: assign sum = buf_doc-line-sum.cost-sum-rubl. end.
                             else do: assign sum = buf_doc-line-sum.cost-sum-base. end.
        end.
        else do:
          if PrintRubl = yes then do: assign sum = buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-VAT-rubl. end.
                             else do: assign sum = buf_doc-line-sum.cost-sum-base - buf_doc-line-sum.cost-VAT-base. end.
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
    assign qnty = buf_doc-line.fact-qnty.

    if sum >= 0 then do: /* излишек */
      assign temp-str.a-qnty      = qnty
             temp-str.a-stoim     = sum
             temp-str.a-qnty1     = buf_doc-line.cli-qnty
             temp-str.ubl         = 0.
      if temp-str.a-qnty = 0 and temp-str.a-stoim = 0 then do: delete temp-str. end.
    end.
    else do:
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
    end.
  end.
end.
/*--------*/
procedure t-level :
  define input parameter  p-node-code like ub.gds-grp.node-code no-undo .
  define output parameter p-node-name as character              no-undo .
  define variable         v-is-term   as logical                no-undo .
  define buffer loc-gds-grp for ub.gds-grp .

  v-is-term = false .
  repeat while v-is-term = false :
      find first loc-gds-grp where loc-gds-grp.upper-code = p-node-code no-error .
      run grplib-get-full-name in this-procedure
        (  input loc-gds-grp.node-code
        , output p-node-name
        ) .
        assign
          p-node-code = loc-gds-grp.node-code
          v-is-term = loc-gds-grp.is-term
        .
    end.
end procedure. /* t-level */
 /*-------*/
 procedure n-level :
  define input  parameter p-upper-code like ub.gds-grp.upper-code no-undo .
  define input  parameter p-lvl-num    as   integer               no-undo .
  define output parameter p-node-name  as   character             no-undo .
  define variable        v-lvl-num     as   integer               no-undo .
  define variable loc-grp-name         as   character             no-undo .
  define buffer loc-gds-grp for ub.gds-grp .

  v-lvl-num = 0 .
    repeat while p-lvl-num <> v-lvl-num :
      find first loc-gds-grp where loc-gds-grp.node-code = p-upper-code no-error .
      run grplib-get-full-name in this-procedure
        (  input loc-gds-grp.node-code
        , output p-node-name
        ) .
      assign
        v-lvl-num    = loc-gds-grp.lvl-num
        p-upper-code = loc-gds-grp.upper-code
      .
    end.
end procedure. /* n-level */
/*-----------*/
 procedure no-classify :
  define input    parameter p-node-code like ub.gds-grp.node-code no-undo .
  define output   parameter p-grp-name  as character              no-undo .
  define variable           v-lvl-num   like ub.gds-grp.lvl-num   no-undo .
  define buffer loc-gds-grp for ub.gds-grp .

  v-lvl-num = 0 .
  repeat while v-lvl-num ne 1 :
      find first loc-gds-grp where loc-gds-grp.node-code = p-node-code no-error .
      assign
          p-node-code = loc-gds-grp.upper-code
          v-lvl-num   = loc-gds-grp.lvl-num
          p-grp-name  = loc-gds-grp.node-name
      .
  end.
end procedure. /* no-classify */

/* $Workfile$   E n d */