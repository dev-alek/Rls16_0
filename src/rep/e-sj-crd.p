block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-sj-crd.p $
$Archive: rep/e-sj-crd.p $

Заполнение полей временной таблицы для журнала продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

/*1 - исп смены*/
define input parameter p-sj-handle as handle no-undo .
define input parameter v-curr-r-b as character no-undo .
DEFINE INPUT PARAMETER startdate as date no-undo .
DEFINE INPUT PARAMETER enddate as date no-undo .
DEFINE INPUT PARAMETER startshift as integer no-undo .
DEFINE INPUT PARAMETER endshift as integer no-undo .
DEFINE INPUT PARAMETER shiftalone as integer no-undo .
DEFINE INPUT PARAMETER PRODUCER as integer no-undo .
DEFINE INPUT PARAMETER Period-type as integer no-undo .
define input parameter RS-seller-cashier as character no-undo .
DEFINE INPUT PARAMETER BySAlers as logical no-undo .
DEFINE INPUT PARAMETER ptwounit as logical no-undo .
DEFINE INPUT PARAMETER par-run-names as character no-undo .
define input parameter p-by-shift-dates as logical   no-undo .
define input parameter p-cash-desk-num as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-sj-crd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/e-sj-crd.p $":U .
define variable vss-description as character no-undo init "Заполнение полей временной таблицы для журнала продаж".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i " " cmp }
{ str/cspromo-chk.i } /* функции для работы с промоакциями по НП */

&scop MaxSalemanNum 10000
define variable strbuf1     as character no-undo.
DEFINE variable for-saleman as integer no-undo.
DEFINE variable for-saleman-psn-code as integer no-undo.
define variable for-saleman-chr as character no-undo .
DEFINE VARIABLE vproc-check as character no-undo .
vproc-check = entry(1, par-run-names, {&delim-par}).
{ rep/e-sj-df.i "SHARED" }

DEFINE SHARED VARiable   cashdesc-num    AS    INTEGER         no-undo.
DEFINE SHARED VARiable    saleman-num     AS    INTEGER         no-undo.
DEFINE VARIABLE v-found-chk-gds as logical no-undo .
define variable v-rate as decimal no-undo .
define variable prev-doc as character no-undo .
DEFINE shared VARIABLE v-num-chk as integer no-undo .
assign
v-num-chk = 0
.


FOR EACH obj-list :
    strbuf1 = obj-list.obj-type + string( obj-list.obj-code ) .
    _chk-doc:
  FOR EACH ub.chk-doc no-lock WHERE
          ub.chk-doc.obj-type = obj-list.obj-type AND
          ub.chk-doc.obj-code = obj-list.obj-code
          and
          (
              (p-by-shift-dates = yes
              AND
              (ub.chk-doc.shift-date >= startdate AND
              ub.chk-doc.shift-date <= enddate)
              )
              or
              (p-by-shift-dates = no
              AND ub.chk-doc.chk-date >= startdate
              AND ub.chk-doc.chk-date <= enddate
              )
         )
       :
      if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then NEXT _chk-doc.
      if saleman-num < {&MaxSalemanNum} then do:
        if rs-seller-cashier = "seller" then do:
          if ub.chk-doc.sales-man <> 0
          and not can-find(first sj-salesman where sj-salesman.seller = ub.chk-doc.sales-man) then NEXT.
          if ub.chk-doc.salesman-psn-code <> ?
          and ub.chk-doc.salesman-psn-code <> 0
          and not can-find(first sj-salesman where sj-salesman.psn-code = ub.chk-doc.salesman-psn-code) then NEXT.
        end.
        else do:
          if ub.chk-doc.cashier <> 0
          and not can-find(first sj-salesman where sj-salesman.seller = ub.chk-doc.cashier) then NEXT.
          if ub.chk-doc.cashier-psn-code <> ?
          and ub.chk-doc.cashier-psn-code <> 0
          and not can-find(first sj-salesman where sj-salesman.psn-code = ub.chk-doc.cashier-psn-code) then NEXT.
        end.
      end.
      if p-cash-desk-num >= 0
      and ub.chk-doc.pay-desk <> p-cash-desk-num then   NEXT .
      if p-by-shift-dates then do:
        IF Period-Type = 3 AND
            ((ub.chk-doc.shift-date = startdate AND ub.chk-doc.shift-num < startshift) OR
              (ub.chk-doc.shift-date = enddate AND  ub.chk-doc.shift-num > endshift) ) THEN NEXT.
        IF Period-Type = 4 AND
            ub.chk-doc.shift-num <> shiftalone THEN NEXT.
     end.

  if v-curr-r-b = {&r-b-base} then do:
    v-rate = ?.
    assign
    v-rate = ub.chk-doc.cash-rate / ub.chk-doc.cash-scale
    no-error .
    if error-status:error
    or v-rate = 0 or v-rate = ?
    then do:
      FIND FIRST ub.chk-pay WHERE
                  ub.chk-pay.doc-code = ub.chk-doc.doc-code NO-LOCK .
      if not avail ub.chk-pay then  NEXT _chk-doc.
      assign
      v-rate = ub.chk-pay.tot-rubl / ub.chk-pay.tot-base.
    end.
end.
    if rs-seller-cashier = "seller" then do:
      assign
      for-saleman = IF BYSALERS
                    then ub.chk-doc.sales-man
                    else 0
      for-saleman-psn-code = IF BYSALERS and ub.chk-doc.salesman-psn-code <> ?
                            then ub.chk-doc.salesman-psn-code
                            else 0
      for-saleman-chr = string(for-saleman) + {&delim-par} + string(for-saleman-psn-code)
      v-found-chk-gds = no
      .
    end.
    else do:
      assign
      for-saleman = IF BYSALERS
                    then ub.chk-doc.cashier
                    else 0
      for-saleman-psn-code = IF BYSALERS and ub.chk-doc.cashier-psn-code <> ?
                            then ub.chk-doc.cashier-psn-code
                            else 0
      for-saleman-chr = string(for-saleman) + {&delim-par} + string(for-saleman-psn-code)
      v-found-chk-gds = no
      .

    end.
    FOR EACH ub.chk-gds WHERE
              ub.chk-gds.doc-code = ub.chk-doc.doc-code NO-LOCK :
      if rs-seller-cashier = "seller" then do:
        assign
        for-saleman = (if BYSALERS AND ub.chk-gds.sales-man <> ? AND ub.chk-gds.sales-man <> 0
                        then ub.chk-gds.sales-man
                        else for-saleman)
        for-saleman-psn-code = (if BYSALERS AND ub.chk-gds.salesman-psn-code <> ?  AND ub.chk-gds.salesman-psn-code <> 0
                        then ub.chk-gds.salesman-psn-code
                        else for-saleman-psn-code)
        for-saleman-chr = string(for-saleman) + {&delim-par} + string(for-saleman-psn-code)
        .
      end.

      FIND sj-goods WHERE
            sj-goods.obj-attr = strbuf1 AND
            sj-goods.b-code = ub.chk-gds.b-code AND
            sj-goods.saleman-chr = for-saleman-chr
             NO-ERROR .
      if available sj-goods then do:
        if ptwounit and sj-goods.twounit > 0 then
              FIND sj-adv WHERE
                    sj-adv.obj-attr = strbuf1 AND
                    sj-adv.b-code = ub.chk-gds.b-code AND
                    sj-adv.saleman-chr = for-saleman-chr AND
                    sj-adv.price = ub.chk-gds.price-base AND
                    sj-adv.dop-rowid = rowid(ub.chk-gds)
                    NO-ERROR .
        else
              FIND sj-adv WHERE
                    sj-adv.obj-attr = strbuf1 AND
                    sj-adv.b-code = ub.chk-gds.b-code AND
                    sj-adv.saleman-chr = for-saleman-chr AND
                    sj-adv.price = ub.chk-gds.price-base
                    NO-ERROR .
        if NOT available sj-adv then  do:
          CREATE sj-adv.
          assign
          sj-adv.obj-attr = strbuf1
          sj-adv.b-code = ub.chk-gds.b-code
          sj-adv.saleman-chr = for-saleman-chr
          sj-adv.price = ub.chk-gds.price-base
          sj-adv.discnt = ub.chk-gds.discnt
          sj-adv.qnty = 0
          sj-adv.qnty-2 = 0
          sj-adv.qnty-3 = 0
          sj-adv.dop-rowid = if ptwounit
                              then rowid(ub.chk-gds)
                              else sj-adv.dop-rowid
          .
        end. /* if NOT available sj-adv then  do: */
      end. /*if available sj-goods then do:*/
      else do:
        FIND ub.bar-code WHERE
              ub.bar-code.b-code = ub.chk-gds.b-code NO-LOCK NO-ERROR .
        IF not avail ub.bar-code then NEXT.
        if available ub.bar-code then do:
          if Producer = {&g-choice} then do:
            find first gds-list where
                      gds-list.gds-code = ub.bar-code.gds-code no-error .
            if not available gds-list then NEXT.
          end.
          FIND ub.goods WHERE
                ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK.
          if not avail ub.goods then NEXT.
          IF Producer = {&g-prod} then do:
            FIND g#cli WHERE
                  g#cli.obj-type = ub.goods.prod-type AND
                  g#cli.obj-code = ub.goods.prod-code NO-LOCK NO-ERROR.
            if not avail g#cli then NEXT.
          end.
          if ptwounit then do:
            FIND FIRST ub.units no-LOCK WHERE
                       ub.units.unit-name = ub.goods.unit-base No-ERROR.
          end.
          FIND ub.clients WHERE
                ub.clients.obj-type = ub.goods.prod-type AND
                ub.clients.obj-code = ub.goods.prod-code NO-LOCK.
          FIND FIRST ub.gds-prt No-LOCK WHERE
                      ub.gds-prt.node-code = ub.bar-code.node-code No-ERROR.
          CREATE sj-goods.
          CREATE sj-adv.
          assign
          sj-goods.obj-attr = strbuf1
          sj-goods.b-code = ub.bar-code.b-code
          sj-goods.saleman-chr = for-saleman-chr
          sj-goods.artic = ub.goods.artic
          sj-goods.name = ub.goods.gds-name
          sj-goods.grp-code = ub.goods.grp-code
          sj-goods.prod-name = ub.clients.obj-name
          sj-goods.node-code = ub.bar-code.node-code
          sj-goods.node-name = if avail ub.gds-prt and NOT ub.gds-prt.node-name = {&empty-scale}
                                  then ub.gds-prt.node-name
                                  else ""
          sj-goods.two-type = if ptwounit
                                  then  (if avail ub.units and LOOKUP({&twounit}, ub.units.type ) > 0
                                          then yes
                                          else no)
                                  else no
          sj-goods.alt-type = if ptwounit
                                  then (if  avail units and LOOKUP({&altunit}, units.type) > 0
                                        then yes
                                        else no)
                                    else no
          sj-goods.twounit = if sj-goods.two-type
                              then 1
                              else (if sj-goods.alt-type
                                    then ub.goods.wt-cart
                                    else 0)
          sj-adv.obj-attr = strbuf1
          sj-adv.b-code = ub.chk-gds.b-code
          sj-adv.saleman = for-saleman-chr
          sj-adv.price = ub.chk-gds.price-base
          sj-adv.discnt = ub.chk-gds.discnt
          sj-adv.qnty = 0
          sj-adv.qnty-2 = 0
          sj-adv.qnty-3 = 0
          sj-adv.dop-rowid = if ptwounit
                              then rowid(ub.chk-gds)
                              else sj-adv.dop-rowid
          .
          find first sj-grp where
                      sj-grp.grp-code = sj-goods.grp-code no-error .
          if not available sj-grp then do:
            create sj-grp.
            assign
            sj-grp.grp-code = sj-goods.grp-code
            sj-grp.grp-name = ub.goods.grp-name
            .
          end. /*if not available sj-grp then do:*/
        end. /*if available ub.bar-code then do:*/
      end. /*else do: (not avail sj-goods*/
      assign
      sj-adv.qnty = sj-adv.qnty + ub.chk-gds.doc-qnty
      /*штучные*/
      sj-adv.qnty-2 = sj-adv.qnty-2 + (if ub.chk-gds.doc-qnty >= 0 then 1 else - 1 ) *
                                      (if sj-goods.two-type then 1 else 0) * sj-goods.twounit +
                                      (if sj-goods.alt-type then 1 else 0) * ub.chk-gds.doc-qnty
      /*вес*/
      sj-adv.qnty-3 = sj-adv.qnty-3 + (if ub.chk-gds.doc-qnty >= 0 then 1 else - 1 ) *
                                      (if sj-goods.alt-type then 1 else 0) * sj-goods.twounit +
                                      (if sj-goods.two-type then 1 else 0) * ub.chk-gds.doc-qnty
      sj-adv.num-lines  = sj-adv.num-lines + 1
      sj-adv.num-docs   = sj-adv.num-doc + (if ub.chk-gds.doc-code = prev-doc then 0 else 1)
      prev-doc          = ub.chk-gds.doc-code
      sj-adv.brutto-sum = sj-adv.brutto-sum + GetRoundSum(ub.chk-gds.doc-code,ub.chk-gds.line-num,ub.chk-gds.doc-qnty, ub.chk-gds.price-base) 
                          + ChkPromoSum(ub.chk-gds.doc-code,ub.chk-gds.line-num)       
      sj-adv.discnt-sum = sj-adv.discnt-sum + ub.chk-gds.discnt * ub.chk-gds.doc-qnty
                          + ChkPromoSum(ub.chk-gds.doc-code,ub.chk-gds.line-num)
      sj-adv.netto-sum = sj-adv.netto-sum +
                         GetRoundSum(ub.chk-gds.doc-code,ub.chk-gds.line-num,ub.chk-gds.doc-qnty, ( ub.chk-gds.price-base - ub.chk-gds.discnt )).
      if v-curr-r-b = {&r-b-base} then do:
        assign
        sj-adv.brutto-sum-r = sj-adv.brutto-sum-r + 
                              round(GetRoundSum(ub.chk-gds.doc-code,ub.chk-gds.line-num,ub.chk-gds.doc-qnty * v-rate, chk-gds.price-base), 2) + 
                              ChkPromoSum(ub.chk-gds.doc-code,ub.chk-gds.line-num)
        sj-adv.netto-sum-r = sj-adv.netto-sum-r +                                   
                             round(GetRoundSum(ub.chk-gds.doc-code,ub.chk-gds.line-num,ub.chk-gds.doc-qnty * v-rate,( ub.chk-gds.price-base - ub.chk-gds.discnt )),2)        
        .
       end.
       v-found-chk-gds = yes
       .
     END .   /* FOR EACH ub.chk-gds ... */
    assign
    v-num-chk = (if v-found-chk-gds
                  then v-num-chk + 1
                  else v-num-chk)
    .
    ACCUMULATE ub.chk-doc.doc-code ( COUNT ) .
    if ( ( ACCUM COUNT ub.chk-doc.doc-code ) modulo 20 ) = 0 AND
          ( ACCUM COUNT ub.chk-doc.doc-code ) >= 20 then
        run waitfram-show in p-sj-handle ( obj-list.obj-type + " " + string( obj-list.obj-code ) +
            vproc-check + string( ACCUM COUNT ub.chk-doc.doc-code ) ) .
  END.    /* FOR EACH ub.chk-doc ... */
END.        /* FOR EACH obj-list ... */