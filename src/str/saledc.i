/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

создание и обновление dis-obj dis-host cli-gds обновление по мере необходимости dis-card и cli

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/25/05
Author: Bakhtadze Natalya
Creation date: 01/25/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

define variable cre-pay-base       like ub.dis-obj.pay-tot-base no-undo.
define variable cre-pay-rubl       like ub.dis-obj.pay-tot-rubl no-undo.
define variable chk-exch           as decimal no-undo.
define variable chk-exch-rubl      as decimal no-undo.
define variable chk-exch-base      as decimal no-undo.
define variable v-rate             as decimal no-undo .
define variable accum-tot-rubl     like ub.chk-pay.tot-rubl  no-undo .
define variable accum-tot-base     like ub.chk-pay.tot-rubl  no-undo .
define variable accum-cre-pay-base like ub.chk-pay.tot-rubl  no-undo .
define variable accum-cre-pay-rubl like ub.chk-pay.tot-rubl  no-undo .
define variable ret-doc-code as character no-undo .

&else

&if defined(sign) = 0 &then
&MESSAGE неопределен препроцессинг sign !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
&endif


  _cards:
  for each ub.chk-doc no-lock
    where ub.chk-doc.obj-type = buf_inkas.obj-type
      AND ub.chk-doc.obj-code = buf_inkas.obj-code
      AND ub.chk-doc.out-code = buf_inkas.inkas-code
      and ub.chk-doc.d-card > ""
  on error undo _main, return error
  :
  if lookup(string(ub.chk-doc.chk-type), {&no-d-card-receipt-codes}) > 0 then next _cards.
  &if "{1}" = "obj" &then
    find first temp-d-card where
              temp-d-card.d-card = ub.chk-doc.d-card
          AND temp-d-card.obj-type = ub.chk-doc.obj-type
          AND temp-d-card.obj-code = ub.chk-doc.obj-code  no-error .

  &else
    find first temp-d-card where
              temp-d-card.d-card = ub.chk-doc.d-card no-error .
  &endif
    if not available temp-d-card then do:

      find first ub.dis-card no-lock
        where ub.dis-card.d-card = ub.chk-doc.d-card
        no-error .
      if not avail dis-card then do:
        next _cards.
      end.

      FIND FIRST ub.clients WHERE
                  ub.clients.obj-type = ub.dis-card.cli-type AND
                  ub.clients.obj-code = ub.dis-card.cli-code No-ERROR.
      if not avail ub.clients then do:
        undo _main, return error "Не найден клиент для дисконтной карты " + ub.dis-card.d-card.
      end.
      assign
        ub.clients.buy-gds = ub.clients.buy-gds OR ( NOT buf_inkas.office )
        ub.clients.buy-serv = ub.clients.buy-serv OR buf_inkas.office
      .
      create temp-d-card.
      assign
      temp-d-card.d-card = ub.chk-doc.d-card
      temp-d-card.pay-tot-base = 0
      temp-d-card.pay-tot-rubl = 0
      temp-d-card.gds-tot-b0 = 0
      temp-d-card.gds-tot-r0 = 0
      temp-d-card.first-main-card   = ub.dis-card.first-main-card
      temp-d-card.main-card         = ub.dis-card.main-card
      temp-d-card.first-card        = ub.dis-card.first-card
      temp-d-card.cli-type          = ub.dis-card.cli-type
      temp-d-card.cli-code          = ub.dis-card.cli-code
      temp-d-card.card-num          = ub.dis-card.card-num
      temp-d-card.emitent-host-code = ub.dis-card.emitent-host-code
      temp-d-card.type              = ub.dis-card.type
      temp-d-card.obj-type          = ub.chk-doc.obj-type
      temp-d-card.obj-code          = ub.chk-doc.obj-code
      temp-d-card.host-code         = buf_inkas.host-code
      temp-d-card.sale-doc          = buf_inkas.inkas-code
      temp-d-card.sale-type         = {&table_inkas}
      temp-d-card.doc-date          = ub.chk-doc.chk-date
      temp-d-card.action            = sign
      .
    end. /*if not avail temp-d-card*/
    FOR EACH ub.chk-gds WHERE
              ub.chk-gds.doc-code = ub.chk-doc.doc-code AND
              ub.chk-gds.b-code <> 0 NO-LOCK ,
        FIRST ub.bar-code where
              ub.bar-code.b-code = ub.chk-gds.b-code No-LOCK,
        FIRST ub.goods where
              ub.goods.gds-code = ub.bar-code.gds-code No-LOCK,
        FIRST ub.doc-line WHERE
              ub.doc-line.doc-code = (if ub.chk-doc.netto >= 0 then buf_trn-doc.doc-code else ret-doc-code) AND
              ub.doc-line.prod-code = ub.goods.prod-code AND
              ub.doc-line.prod-type = ub.goods.prod-type AND
              ub.doc-line.artic = ub.goods.artic NO-LOCK
              On error undo _main, return error
              :
      /*списанные по расходу не относим к клиентам*/
      if ub.chk-gds.write-off-code <> ?
      and ub.chk-gds.write-off-code > 0 then NEXT.
      assign
      temp-d-card.gds-tot-r0 = temp-d-card.gds-tot-r0 +  {&sign} ( ub.doc-line.price-rubl * ub.chk-gds.doc-qnty )
      temp-d-card.gds-tot-b0 = temp-d-card.gds-tot-b0 +  {&sign} ( ub.doc-line.price-base * ub.chk-gds.doc-qnty )
      .
    END. /* FOR EACH ub.chk-gds ... */
    assign
    accum-tot-base = 0
    accum-tot-rubl = 0
    accum-cre-pay-base =0
    accum-cre-pay-rubl =0
    .

    FOR EACH ub.chk-pay WHERE
             ub.chk-pay.doc-code = ub.chk-doc.doc-code NO-LOCK
    On error undo _main, return error

    :
        if ub.chk-pay.pay-code = cre-pay
          then
        assign
        cre-pay-base = ub.chk-pay.tot-base
        cre-pay-rubl   = ub.chk-pay.tot-rubl .
          else
        assign
        cre-pay-base = 0
        cre-pay-rubl   = 0 .
        Assign
        accum-tot-rubl     = accum-tot-rubl +  ub.chk-pay.tot-rubl
        accum-tot-base     = accum-tot-base +  ub.chk-pay.tot-base
        accum-cre-pay-base = accum-cre-pay-base +  cre-pay-base
        accum-cre-pay-rubl = accum-cre-pay-rubl +  cre-pay-rubl
        .
        if v-cntxt-db-num = 0 and ub.chk-pay.pay-code <> cre-pay then do:
        /*если это главная база то генерим вспомогательную таблицу для записи
        в payment
        если это не главная БД то payment создасться при разборе новостей - чеков*/
          FIND FIRST vchk-pay No-LOCK WHERE
                      vchk-pay.d-card = ub.chk-doc.d-card AND
                      vchk-pay.pay-code = ub.chk-pay.pay-code AND
                      vchk-pay.curr-code = ub.chk-pay.curr-code AND
                      vchk-pay.doc-date = ub.chk-pay.chk-date AND
                      vchk-pay.cre-pay = (ub.chk-pay.pay-code = cre-pay) AND
                      vchk-pay.exch-rate = (ub.chk-pay.tot-sum / chk-pay.tot-rubl) AND
                    vchk-pay.base-rate = (ub.chk-pay.tot-rubl / chk-pay.tot-base ) No-ERROR.
          IF NOT AVAIL vchk-pay then do:
            create vchk-pay.
            assign
            vchk-pay.d-card   = ub.chk-doc.d-card
            vchk-pay.doc-date = ub.chk-pay.chk-date
            vchk-pay.pay-code = ub.chk-pay.pay-code
            vchk-pay.curr-code = ub.chk-pay.curr-code
            vchk-pay.cre-pay = (ub.chk-pay.pay-code = cre-pay)
            vchk-pay.exch-rate =  (ub.chk-pay.tot-sum / ub.chk-pay.tot-rubl)
            vchk-pay.base-rate = (ub.chk-pay.tot-rubl / ub.chk-pay.tot-base)
            .
          end.
          assign
          vchk-pay.tot-sum  = vchk-pay.tot-sum  + ub.chk-pay.tot-sum
          vchk-pay.tot-base = vchk-pay.tot-base + ub.chk-pay.tot-base
          vchk-pay.tot-rubl = vchk-pay.tot-rubl + ub.chk-pay.tot-rubl
          .
      END. /*if v-cntxt-db-num = 0*/
    END .
    assign
    temp-d-card.pay-tot-base = temp-d-card.pay-tot-base + {&sign} (ACCUM-tot-base -  ACCUM-cre-pay-base)
    temp-d-card.pay-tot-rubl = temp-d-card.pay-tot-rubl + {&sign} (ACCUM-tot-rubl -  ACCUM-cre-pay-rubl)
    .

    if v-base-code = 0 then
    chk-exch =  1.
    else do:
      v-rate = ?.
      if v-curr-r-b = {&r-b-base} then do:
        assign
        v-rate = ub.chk-doc.cash-rate / ub.chk-doc.cash-scale
        no-error
        .
        if v-rate <> 0
        and v-rate <> ? then do:
          chk-exch = v-rate.
        end.
        else do:
          assign
          v-rate = ACCUM-tot-rubl  / ACCUM-tot-base
          no-error
          .
          if v-rate <> ?
          and v-rate <> 0 then do:
            chk-exch = v-rate.
          end.
          else do:
              undo _main, return error substitute("&1&2 Невозможно определить курс базовой валюты для чека &3 по ДК &4"
                                                  , vss-description
                                                  , {&new-line}
                                                  , chk-doc.doc-code
                                                  , chk-doc.d-card).
          end.
        end.
      end. /*v-curr-b = base*/
      else do:
        assign
        v-rate = ACCUM-tot-rubl  / ACCUM-tot-base
        no-error
        .
        if v-rate <> ?
        and v-rate <> 0 then do:
          chk-exch = v-rate.
        end.
        else do:
          FIND LAST buf_curr-shop NO-LOCK WHERE
                    buf_curr-shop.obj-type = ub.chk-doc.obj-type AND
                    buf_curr-shop.obj-code = ub.chk-doc.obj-code AND
                    buf_curr-shop.curr-code = v-base-code AND
                    ( ( buf_curr-shop.exch-date = ub.chk-doc.chk-date AND
                        buf_curr-shop.exch-time <= ub.chk-doc.chk-time ) OR
                        buf_curr-shop.exch-date < ub.chk-doc.chk-date ) NO-ERROR .
          if available buf_curr-shop then do:
            assign
            v-rate = buf_Curr-shop.exch-rate / buf_curr-shop.exch-scale
            no-error .
            if v-rate <> ?
            and v-rate <> 0 then do:
              chk-exch = v-rate.
            end.
            else do:
                undo _main, return error substitute("&1&2 Невозможно определить курс базовой валюты для чека &3 по ДК &4"
                                                    , vss-description
                                                    , {&new-line}
                                                    , chk-doc.doc-code
                                                    , chk-doc.d-card).
            end.
          end.
        end.
      end. /*v-curr-b = rubl*/
    end. /*base-code <> 0*/
    assign
    chk-exch-rubl = (if v-curr-r-b = {&r-b-rubl} then 1 else chk-exch)
    chk-exch-base = (if v-curr-r-b = {&r-b-base} then 1 else chk-exch )
    .

    Assign
    temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-r-b + 0
    temp-d-card.sum-tot-rubl = temp-d-card.sum-tot-rubl + 0
    temp-d-card.sum-tot-base = temp-d-card.sum-tot-base + 0
    temp-d-card.gds-tot-r-b  = temp-d-card.gds-tot-r-b  + {&sign} ub.chk-doc.tot-doc
    temp-d-card.gds-tot-rubl = temp-d-card.gds-tot-rubl + {&sign} ub.chk-doc.tot-doc * chk-exch-rubl
    temp-d-card.gds-tot-base = temp-d-card.gds-tot-base + {&sign} ub.chk-doc.tot-doc / chk-exch-base
    temp-d-card.gds-dis-r-b  = temp-d-card.gds-dis-r-b  + {&sign} ub.chk-doc.discnt
    temp-d-card.gds-dis-rubl = temp-d-card.gds-dis-rubl + {&sign} ub.chk-doc.discnt * chk-exch-rubl
    temp-d-card.gds-dis-base = temp-d-card.gds-dis-base + {&sign} ub.chk-doc.discnt / chk-exch-base
    temp-d-card.num-chk      = temp-d-card.num-chk      + {&sign} 1
    .
    run ref/calctur4.p ( input ub.chk-doc.doc-code ) .
 END. /*_cards*/

&endif
/* $Workfile$ e n d */