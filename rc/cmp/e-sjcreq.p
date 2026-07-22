block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-sjcreq.p $
$Archive: cmp/e-sjcreq.p $

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
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-sjcreq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/e-sjcreq.p $":U .
define variable vss-description as character no-undo init "Заполнение полей временной таблицы для журнала продаж".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i " " cmp }

&scop MaxSalemanNum 10000
define variable strbuf1     as character no-undo.
DEFINE variable for-saleman as integer no-undo.
DEFINE variable for-saleman-psn-code as integer no-undo.
define variable for-saleman-chr as character no-undo .
DEFINE VARIABLE vproc-check as character no-undo .
vproc-check = entry(1, par-run-names, {&delim-par}).
{ cmp/e-sjdf.i "SHARED" }

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
  FOR EACH chk-doc WHERE
          chk-doc.obj-type = obj-list.obj-type AND
          chk-doc.obj-code = obj-list.obj-code
&if "{1}" = "yes" &then
          AND
          (chk-doc.shift-date >= startdate AND
          chk-doc.shift-date <= enddate)
          NO-LOCK:
&else
          AND chk-doc.chk-date >= startdate
          AND chk-doc.chk-date <= enddate
          use-index obj-date NO-LOCK :
&endif
      if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then NEXT _chk-doc.
      if saleman-num < {&MaxSalemanNum} then do:
        if rs-seller-cashier = "seller" then do:
          if chk-doc.sales-man <> 0
          and not can-find(first sj-salesman where sj-salesman.seller = chk-doc.sales-man) then NEXT.
          if chk-doc.salesman-psn-code <> ?
          and chk-doc.salesman-psn-code <> 0
          and not can-find(first sj-salesman where sj-salesman.psn-code = chk-doc.salesman-psn-code) then NEXT.
        end.
        else do:
          if chk-doc.cashier <> 0
          and not can-find(first sj-salesman where sj-salesman.seller = chk-doc.cashier) then NEXT.
          if chk-doc.cashier-psn-code <> ?
          and chk-doc.cashier-psn-code <> 0
          and not can-find(first sj-salesman where sj-salesman.psn-code = chk-doc.cashier-psn-code) then NEXT.
        end.
      end.
      if NOT ( {2} ) then   NEXT .
&if "{1}" = "yes" &then
    IF Period-Type = 3 AND
        ((chk-doc.shift-date = startdate AND chk-doc.shift-num < startshift) OR
          (chk-doc.shift-date = enddate AND  chk-doc.shift-num > endshift) ) THEN NEXT.
    IF Period-Type = 4 AND
        chk-doc.shift-num <> shiftalone THEN NEXT.
&endif
if v-curr-r-b = {&r-b-base} then do:
    v-rate = ?.
    assign
    v-rate = chk-doc.cash-rate / chk-doc.cash-scale
    no-error .
    if error-status:error
    or v-rate = 0 or v-rate = ?
    then do:
      FIND FIRST chk-pay WHERE
                  chk-pay.doc-code = chk-doc.doc-code NO-LOCK .
      if not avail chk-pay then  NEXT _chk-doc.
      assign
      v-rate = chk-pay.tot-rubl / chk-pay.tot-base.
    end.
end.
    if rs-seller-cashier = "seller" then do:
      assign
      for-saleman = IF BYSALERS
                    then chk-doc.sales-man
                    else 0
      for-saleman-psn-code = IF BYSALERS and chk-doc.salesman-psn-code <> ?
                            then chk-doc.salesman-psn-code
                            else 0
      for-saleman-chr = string(for-saleman) + {&delim-par} + string(for-saleman-psn-code)
      v-found-chk-gds = no
      .
    end.
    else do:
      assign
      for-saleman = IF BYSALERS
                    then chk-doc.cashier
                    else 0
      for-saleman-psn-code = IF BYSALERS and chk-doc.cashier-psn-code <> ?
                            then chk-doc.cashier-psn-code
                            else 0
      for-saleman-chr = string(for-saleman) + {&delim-par} + string(for-saleman-psn-code)
      v-found-chk-gds = no
      .

    end.
    FOR EACH chk-gds WHERE
              chk-gds.doc-code = chk-doc.doc-code NO-LOCK :
      if rs-seller-cashier = "seller" then do:
        assign
        for-saleman = (if BYSALERS AND chk-gds.sales-man <> ? AND chk-gds.sales-man <> 0
                        then chk-gds.sales-man
                        else for-saleman)
        for-saleman-psn-code = (if BYSALERS AND chk-gds.salesman-psn-code <> ?  AND chk-gds.salesman-psn-code <> 0
                        then chk-gds.salesman-psn-code
                        else for-saleman-psn-code)
        for-saleman-chr = string(for-saleman) + {&delim-par} + string(for-saleman-psn-code)
        .
      end.

      FIND sj-goods WHERE
            sj-goods.obj-attr = strbuf1 AND
            sj-goods.b-code = chk-gds.b-code AND
            sj-goods.saleman-chr = for-saleman-chr
             NO-ERROR .
      if available sj-goods then do:
        if ptwounit and sj-goods.twounit > 0 then
              FIND sj-adv WHERE
                    sj-adv.obj-attr = strbuf1 AND
                    sj-adv.b-code = chk-gds.b-code AND
                    sj-adv.saleman-chr = for-saleman-chr AND
                    sj-adv.price = chk-gds.price-base AND
                    sj-adv.dop-rowid = rowid(chk-gds)
                    NO-ERROR .
        else
              FIND sj-adv WHERE
                    sj-adv.obj-attr = strbuf1 AND
                    sj-adv.b-code = chk-gds.b-code AND
                    sj-adv.saleman-chr = for-saleman-chr AND
                    sj-adv.price = chk-gds.price-base
                    NO-ERROR .
        if NOT available sj-adv then  do:
          CREATE sj-adv.
          assign
          sj-adv.obj-attr = strbuf1
          sj-adv.b-code = chk-gds.b-code
          sj-adv.saleman-chr = for-saleman-chr
          sj-adv.price = chk-gds.price-base
          sj-adv.discnt = chk-gds.discnt
          sj-adv.qnty = 0
          sj-adv.qnty-2 = 0
          sj-adv.qnty-3 = 0
          sj-adv.dop-rowid = if ptwounit
                              then rowid(chk-gds)
                              else sj-adv.dop-rowid
          .
        end. /* if NOT available sj-adv then  do: */
      end. /*if available sj-goods then do:*/
      else do:
        FIND bar-code WHERE
              bar-code.b-code = chk-gds.b-code NO-LOCK NO-ERROR .
        IF not avail bar-code then NEXT.
        if available bar-code then do:
          if Producer = {&g-choice} then do:
            find first gds-list where
                      gds-list.gds-code = bar-code.gds-code no-error .
            if not available gds-list then NEXT.
          end.
          FIND goods WHERE
                goods.gds-code = bar-code.gds-code NO-LOCK.
          if not avail goods then NEXT.
          IF Producer = {&g-prod} then do:
            FIND g#cli WHERE
                  g#cli.obj-type = goods.prod-type AND
                  g#cli.obj-code = goods.prod-code NO-LOCK NO-ERROR.
            if not avail g#cli then NEXT.
          end.
          if ptwounit then do:
            FIND FIRST units no-LOCK WHERE
                        units.unit-name = goods.unit-base No-ERROR.
          end.
          FIND clients WHERE
                clients.obj-type = goods.prod-type AND
                clients.obj-code = goods.prod-code NO-LOCK.
          FIND FIRST gds-prt No-LOCK WHERE
                      gds-prt.node-code = bar-code.node-code No-ERROR.
          CREATE sj-goods.
          CREATE sj-adv.
          assign
          sj-goods.obj-attr = strbuf1
          sj-goods.b-code = bar-code.b-code
          sj-goods.saleman-chr = for-saleman-chr
          sj-goods.artic = goods.artic
          sj-goods.name = goods.gds-name
          sj-goods.grp-code = goods.grp-code
          sj-goods.prod-name = clients.obj-name
          sj-goods.node-code = bar-code.node-code
          sj-goods.node-name = if avail gds-prt and NOT gds-prt.node-name = {&empty-scale}
                                  then gds-prt.node-name
                                  else ""
          sj-goods.two-type = if ptwounit
                                  then  (if avail units and LOOKUP({&twounit}, units.type ) > 0
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
                                    then goods.wt-cart
                                    else 0)
          sj-adv.obj-attr = strbuf1
          sj-adv.b-code = chk-gds.b-code
          sj-adv.saleman = for-saleman-chr
          sj-adv.price = chk-gds.price-base
          sj-adv.discnt = chk-gds.discnt
          sj-adv.qnty = 0
          sj-adv.qnty-2 = 0
          sj-adv.qnty-3 = 0
          sj-adv.dop-rowid = if ptwounit
                              then rowid(chk-gds)
                              else sj-adv.dop-rowid
          .
          find first sj-grp where
                      sj-grp.grp-code = sj-goods.grp-code no-error .
          if not available sj-grp then do:
            create sj-grp.
            assign
            sj-grp.grp-code = sj-goods.grp-code
            sj-grp.grp-name = goods.grp-name
            .
          end. /*if not available sj-grp then do:*/
        end. /*if available bar-code then do:*/
      end. /*else do: (not avail sj-goods*/
      assign
      sj-adv.qnty = sj-adv.qnty + chk-gds.doc-qnty
      /*штучные*/
      sj-adv.qnty-2 = sj-adv.qnty-2 + (if chk-gds.doc-qnty >= 0 then 1 else - 1 ) *
                                      (if sj-goods.two-type then 1 else 0) * sj-goods.twounit +
                                      (if sj-goods.alt-type then 1 else 0) * chk-gds.doc-qnty
      /*вес*/
      sj-adv.qnty-3 = sj-adv.qnty-3 + (if chk-gds.doc-qnty >= 0 then 1 else - 1 ) *
                                      (if sj-goods.alt-type then 1 else 0) * sj-goods.twounit +
                                      (if sj-goods.two-type then 1 else 0) * chk-gds.doc-qnty
      sj-adv.num-lines  = sj-adv.num-lines + 1
      sj-adv.num-docs   = sj-adv.num-doc + (if chk-gds.doc-code = prev-doc then 0 else 1)
      prev-doc          = chk-gds.doc-code
      sj-adv.brutto-sum = sj-adv.brutto-sum + chk-gds.doc-qnty * chk-gds.price-base
      sj-adv.discnt-sum = sj-adv.discnt-sum + chk-gds.discnt * chk-gds.doc-qnty
      sj-adv.netto-sum = sj-adv.netto-sum +
                      ( chk-gds.price-base - chk-gds.discnt ) * chk-gds.doc-qnty .
      if v-curr-r-b = {&r-b-base} then do:
        assign
        sj-adv.brutto-sum-r = sj-adv.brutto-sum-r + chk-gds.doc-qnty *
                        round( chk-gds.price-base * (v-rate), 2 )
        sj-adv.netto-sum-r = sj-adv.netto-sum-r +
                        round( ( chk-gds.price-base - chk-gds.discnt ) *
                        chk-gds.doc-qnty * ( v-rate ), 2 )
        .
       end.
       v-found-chk-gds = yes
       .
     END .   /* FOR EACH chk-gds ... */
    assign
    v-num-chk = (if v-found-chk-gds
                  then v-num-chk + 1
                  else v-num-chk)
    .
    ACCUMULATE chk-doc.doc-code ( COUNT ) .
    if ( ( ACCUM COUNT chk-doc.doc-code ) modulo 20 ) = 0 AND
          ( ACCUM COUNT chk-doc.doc-code ) >= 20 then
        run waitfram-show in p-sj-handle ( obj-list.obj-type + " " + string( obj-list.obj-code ) +
            vproc-check + string( ACCUM COUNT chk-doc.doc-code ) ) .
  END.    /* FOR EACH chk-doc ... */
END.        /* FOR EACH obj-list ... */