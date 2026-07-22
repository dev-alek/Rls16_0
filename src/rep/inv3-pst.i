/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 09/17/03 2:17

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  for each buf_doc-line no-lock where buf_doc-line.doc-code = trn-doc.doc-code :
    find first buf_goods no-lock
      where buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
        and buf_goods.artic     = buf_doc-line.artic
    no-error .
    find first ub.units no-lock  where ub.units.unit-name = buf_goods.unit-base  no-error .

    { gbl/gdsbcode.i  buf_goods.gds-code  ? b-code   no-error }
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip
        "Артикул товара" skip buf_goods.artic   view-as alert-box error .
    end.
    if CostPrice = false then do: /* найдем продажную цену  */
       /* Определим текущую цену бар-кода ( корневого признака ) */
       { gbl/bcodeprc.i
        buf_doc-line.obj-type
        buf_doc-line.obj-code
        b-code
        0
        trn-doc.fact-order
        v-cur-dn
        v-cur-pr
        v-cur-rt
        v-cur-ex }
           if v-cur-pr = ? then v-cur-pr = 0.
    end.
    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 "'Документ инвентаризации '"  "'(по поставщикам)'"}


    for each buf_parts no-lock  where
                buf_parts.obj-type    = buf_doc-line.obj-type and
                buf_parts.obj-code    = buf_doc-line.obj-code and
                buf_parts.artic       = buf_goods.artic       and
                buf_parts.prod-type   = buf_goods.prod-type   and
                buf_parts.prod-code   = buf_goods.prod-code   and
                buf_parts.out-code    = buf_doc-line.doc-code
    :
           find first temp-str where
                temp-str.supp-type   = buf_parts.supp-type and
                temp-str.supp-code   = buf_parts.supp-code and
                temp-str.artic       = buf_goods.artic     and
                temp-str.prod-type   = buf_goods.prod-type and
                temp-str.prod-code   = buf_goods.prod-code
                no-error .
           if not  available temp-str then do:
              create temp-str .
               find first buf_clients where buf_clients.obj-code = buf_parts.supp-code and
                                           buf_clients.obj-type = buf_parts.supp-type no-lock no-error .
                assign
                  temp-str.supp-type   = buf_parts.supp-type
                  temp-str.supp-code   = buf_parts.supp-code
                  temp-str.supp-name   = "(" + buf_parts.supp-type  + " " + string(buf_parts.supp-code) + ") "   +
                                         if available buf_clients then  buf_clients.obj-name
                                         else "***"
                  temp-str.b-code      = string(b-code)
                  temp-str.grp-name    = buf_goods.grp-name
                  temp-str.artic       = buf_goods.artic
                  temp-str.prod-type   = buf_goods.prod-type
                  temp-str.prod-code   = buf_goods.prod-code
                  temp-str.gds-code    = buf_goods.gds-code
                  temp-str.OKEI        = ub.units.OKEI
                  temp-str.unit-base   = buf_goods.unit-base
                  temp-str.tb-code     = buf_goods.sort
                .
                  if g#gds-engl then assign temp-str.gds-name = buf_goods.engl-name.
                                else assign temp-str.gds-name = buf_goods.gds-name.
              end.

    /* if p-no-vat = "no" then do:*/
    if rep-tipe = "sl" then do:  /* сличительная ведомость --------------------------------------------------------------------*/
        if PrintRubl then assign sum =  buf_parts.price-rubl * buf_parts.fact-qnty .
                     else assign sum =  buf_parts.price-base * buf_parts.fact-qnty .
        assign
          qnty = buf_parts.fact-qnty
        .
        if sum >= 0 then do: /* излишек */
          assign
            temp-str.a-qnty      = temp-str.a-qnty  + qnty
            temp-str.a-stoim     = temp-str.a-stoim + sum
            temp-str.a-qnty1     = temp-str.a-qnty1 + buf_parts.cli-qnty
            temp-str.ubl         = 0
          .
        end.
        else do:
          assign
            temp-str.b-qnty      = temp-str.b-qnty  - qnty
            temp-str.b-stoim     = temp-str.b-stoim - sum
            temp-str.b-qnty1     = temp-str.b-qnty1 - buf_parts.cli-qnty
            temp-str.ubl         = 0
            sum = - sum         /* ? */
          .
          run ubl in this-procedure . /* смотрим естеств убыль */
        end.
    end. /* end sl */
  end.   /* for each parts */

  if rep-tipe = "invent" then do: /* это инвентариз. опись */
    /* суммы до документа */
    run partslib-init-temp-parts-by-factord in this-procedure
      (input  buf_doc-line.obj-type
      ,input  buf_doc-line.obj-code
      ,input  buf_doc-line.artic
      ,input  buf_doc-line.prod-type
      ,input  buf_doc-line.prod-code
      ,input  buf_doc-line.fact-order
      ,input  true
      ) .
     for each temp-parts :
       if not can-find (first   temp-str where
                temp-str.supp-type   = temp-parts.supp-type and
                temp-str.supp-code   = temp-parts.supp-code and
                temp-str.artic       = buf_goods.artic     and
                temp-str.prod-type   = buf_goods.prod-type and
                temp-str.prod-code   = buf_goods.prod-code ) then do:
              create temp-str .
               find first buf_clients where buf_clients.obj-code = temp-parts.supp-code and
                                           buf_clients.obj-type = temp-parts.supp-type no-lock no-error .

                assign
                  temp-str.supp-type   = temp-parts.supp-type
                  temp-str.supp-code   = temp-parts.supp-code
                  temp-str.supp-name   = "(" + temp-parts.supp-type  + " " + string(temp-parts.supp-code) + ") "   +
                                    ( if available buf_clients then  buf_clients.obj-name else "***")
                  temp-str.b-code      = string(b-code)
                  temp-str.grp-name    = buf_goods.grp-name
                  temp-str.artic       = buf_goods.artic
                  temp-str.prod-type   = buf_goods.prod-type
                  temp-str.prod-code   = buf_goods.prod-code
                  temp-str.gds-code    = buf_goods.gds-code
                  temp-str.OKEI        = ub.units.OKEI
                  temp-str.unit-base   = buf_goods.unit-base
                  temp-str.tb-code     = buf_goods.sort
                .
                  if g#gds-engl then assign temp-str.gds-name = buf_goods.engl-name.
                                else assign temp-str.gds-name = buf_goods.gds-name.
              end.

     end.

     for each temp-str where
          temp-str.gds-code    = buf_goods.gds-code :
          l-b-qnty = 0 .
          l-b-stoim = 0 .
          for each temp-parts where
              temp-parts.host-code = trn-doc.host-code      and
              temp-parts.supp-type = temp-str.supp-type     and
              temp-parts.supp-code = temp-str.supp-code     and
              temp-parts.obj-type  = buf_doc-line.obj-type  and
              temp-parts.obj-code  = buf_doc-line.obj-code  and
              temp-parts.artic     = buf_doc-line.artic     and
              temp-parts.prod-type = buf_doc-line.prod-type and
              temp-parts.prod-code = buf_doc-line.prod-code :
              assign
                l-b-stoim = l-b-stoim + ( temp-parts.fact-qnty * (IF PrintRubl THEN temp-parts.price-rubl else  temp-parts.price-base ))
                l-b-qnty  = l-b-qnty + temp-parts.fact-qnty
                .
          end.
          assign
             temp-str.b-stoim = l-b-stoim
             temp-str.b-qnty  = l-b-qnty
             temp-str.price-befor = temp-str.b-stoim / temp-str.b-qnty
          .
          if temp-str.price-befor = ? then assign temp-str.price-befor = 0 .


     end.
    /* суммы после документа */
    run partslib-init-temp-parts-by-factord in this-procedure
      (input  buf_doc-line.obj-type
      ,input  buf_doc-line.obj-code
      ,input  buf_doc-line.artic
      ,input  buf_doc-line.prod-type
      ,input  buf_doc-line.prod-code
      ,input  buf_doc-line.fact-order
      ,input  false
      ) .
     for each temp-str where
          temp-str.gds-code    = buf_goods.gds-code:
          l-a-qnty = 0 .
          l-a-stoim = 0 .
          for each temp-parts where
              temp-parts.host-code = trn-doc.host-code      and
              temp-parts.supp-type = temp-str.supp-type     and
              temp-parts.supp-code = temp-str.supp-code     and
              temp-parts.obj-type  = buf_doc-line.obj-type  and
              temp-parts.obj-code  = buf_doc-line.obj-code  and
              temp-parts.artic     = buf_doc-line.artic     and
              temp-parts.prod-type = buf_doc-line.prod-type and
              temp-parts.prod-code = buf_doc-line.prod-code :
              assign
                l-a-stoim = l-a-stoim + ( temp-parts.fact-qnty * (IF PrintRubl THEN temp-parts.price-rubl else  temp-parts.price-base ))
                l-a-qnty  = l-a-qnty + temp-parts.fact-qnty
                .
          end.
          assign
             temp-str.a-stoim = l-a-stoim
             temp-str.a-qnty  = l-a-qnty
             temp-str.price-after = temp-str.a-stoim / temp-str.a-qnty
             .
          if temp-str.price-after = ? then assign temp-str.price-after = 0 .

          if   v-prn0 = "no" then do:
            if temp-str.a-qnty = 0 and
               temp-str.a-stoim = 0 and
               temp-str.b-qnty = 0 and
               temp-str.b-stoim = 0  then delete temp-str .
          end.

     end.  /* fe temp-str*/

  end.
  else do:
    /* if temp-str.a-qnty = 0 and temp-str.a-stoim = 0 and  temp-str.b-qnty = 0 and temp-str.b-stoim = 0 then delete temp-str .*/
  end.
  if CostPrice = false then do:
     for each temp-str where
          temp-str.gds-code    = buf_goods.gds-code:
                assign
                temp-str.a-stoim      =  temp-str.a-qnty * v-cur-pr
                temp-str.b-stoim      =  temp-str.b-qnty * v-cur-pr
                temp-str.Price-after  = v-cur-pr
                temp-str.Price-befor  = v-cur-pr
                .
     end.

  end.

 end.    /* for each doc-line */

/* $Workfile$ e n d */