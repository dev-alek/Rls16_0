block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: testq00.p $
$Archive: utl/testq00.p $

Компилируемый ран-тайм модуль тестов по чекам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/09/05
Author: Bakhtadze Natalya
Creation date: 10/09/05

*/

define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER test-number as integer.
DEFINE INPUT PARAMETER my-inkas as char.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-where-phrase as character no-undo .
define input parameter parscales-pref as character no-undo .
define input parameter parpgscales-pref as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: testq00.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/testq00.p $":U .
define variable vss-description as character no-undo init "Компилируемый ран-тайм модуль тестов по чекам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/libbcrcn.i }
{ gbl/waitfram.i }

define SHARED var ff as decimal.
define SHARED var gg as decimal.
DEFine SHARED VAR accum1 as decimal.
DEFINE VARIABLE bc-buf as char no-undo.
DEFINE VARIABLE b-c like ub.bar-code.b-code no-undo.
DEFINE VARIABLE flag as logical.
DEFINE VARIABLE price-from-check like ub.chk-gds.price-base no-undo .
DEFINE VARIABLE r-bar-code like ub.bar-code.b-code no-undo .
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
DEFINE VARIABLE v-err       as logical           no-undo .

define buffer for-gds for ub.chk-gds.

DEFINE SHARED STREAM PrnLibStream.

define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i v-curr-r-b }

define query testqi for ub.inkas, ub.chk-doc.
define query testqc for ub.chk-doc.
define variable v-qh as handle no-undo .
define variable glog as logical no-undo .
if my-inkas = "ALL" then do:
  v-qh = query testqi:handle.
end.
else do:
  v-qh = query testqc:handle.
end.
assign
glog = v-qh:query-prepare(p-where-phrase) no-error.
if error-status:error then do:
  message error-status:get-message(1)
  view-as alert-box error .
  undo, return error .
end.
assign
glog = v-qh:query-open( ) no-error .
if error-status:error then do:
  message error-status:get-message(1)
  view-as alert-box error .
  undo, return error .
end.



REPEAT :
  v-qh:GET-NEXT().
  IF v-qh:QUERY-OFF-END THEN LEAVE.
  if chk-doc.chk-type = integer({&rcpt-annu}) then next.
  if lookup(string(chk-doc.chk-type), {&wth-receipt-codes}) > 0  then next.
  if my-inkas = "ALL" then do:
    my-inkas = inkas.inkas-code.
  end.
  run waitfram-show in this-procedure ( input substitute("Ждите - идет обработка -  чек &1",chk-doc.doc-code)).

  CASE test-number:
    WHEN 1 then do:
      FOR EACH ub.chk-gds no-lock where ub.chk-gds.doc-code = ub.CHK-DOC.doc-code :
        flag = no.
        IF chk-gds.b-code = ? or chk-gds.b-code <= 0 THEN FLAG = YES.
        else do:
          assign
          price-from-check = chk-gds.price-base
          bc-buf = string(chk-gds.b-code)
          .
          { str/bc-rcnz.i
            parparentproc
            bc-buf
            price-from-check
            chk-doc.obj-type
            chk-doc.obj-code
            yes
            no
            parscales-pref
            parpgscales-pref
            varresult
            vartype-bc
            varweight
            ub.bar-code
            ub.prod-bc
            ub.place
            no-error
          }
          if error-status:error then do:
            release bar-code.
          end.
          if avail bar-code then do:
            v-err = no.
            { gbl/gdsbcode.i bar-code.gds-code bar-code.node-code r-bar-code no-error }
            if error-status:error then v-err = yes.
            if v-err then  do:
              assign
              b-c = ?
              flag = yes
              .
            end.
            else do:
              if bar-code.in-code = "":U and bar-code.part-code = "":U then do:
                assign
                b-c = r-bar-code
                .
              end.
              else do:
                v-err = no.
                { gbl/gdspcode.i bar-code.gds-code bar-code.node-code bar-code.in-code bar-code.part-code r-bar-code no-error }
                if error-status:error then v-err = yes.
                assign
                b-c = (if v-err
                       then ?
                       else r-bar-code)
                flag = (if v-err
                       then yes
                       else flag)
                .
              end.
            end.
          end.
          else do:
            assign
            b-c = ?
            flag = yes
            .
          end.
        end.
        if chk-gds.out-code <> chk-doc.out-code then flag = yes.
        if flag then do:
           PUT STREAM PrnLibStream UNFORMATTED
            chk-gds.doc-code FORMAT "X(20)"  space(1)
            CHK-DOC.pay-desk format "99999" space(1)
            CHK-DOC.chk-num format "-99999" space(1)
            if chk-gds.b-code = ? then "?" else string(chk-gds.b-code, "-9999999999") space(1)
            string(chk-gds.out-code <> chk-doc.out-code, "да/нет")
            SKIP
            .
        end.
    end. /*each chk-gds*/
    END. /*WHEN 1*/
    WHEN 2 then do:
        ff = 0.
        gg = 0.
        flag = no.
        if lookup(string(chk-doc.chk-type), {&petrol-receipt-codes}) > 0 then next.
        for each ub.chk-gds where ub.chk-gds.doc-code = ub.chk-doc.doc-code no-lock:
            if ub.chk-gds.write-off-code <> ? and ub.chk-gds.write-off-code > 0 then next.
            ff = ff + ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - chk-gds.discnt).
            flag = (ub.chk-gds.out-code <> ub.chk-doc.out-code) OR flag.
        end.
         for each ub.chk-pay where ub.chk-pay.doc-code = ub.chk-doc.doc-code no-lock:
            gg = gg +  ub.chk-pay.tot-rubl.
            flag = (ub.chk-pay.out-code <> ub.chk-doc.out-code) OR flag.
        end.
        if abs(ff - gg) > 0.0000000002 or flag then do:
            put stream PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code  format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ff   format "-999,999.9999999999" space(1)
            gg format "-999,999.9999999999" space(1)
            (ff - gg) format "-999,999.9999999999" space(1)
            flag
            skip.
        accum1 = accum1 + (ff - gg) .
        end.
    END. /*when 2*/
    WHEN 3 then do:
        ff = 0.
        gg = 0.
        flag = no.
        if lookup(string(ub.chk-doc.chk-type), {&petrol-receipt-codes}) > 0 then next.
         for each ub.chk-gds where ub.chk-gds.doc-code = ub.chk-doc.doc-code no-lock:
           if ub.chk-gds.write-off-code <> ? and ub.chk-gds.write-off-code > 0 then next.
            ff = ff + ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt).
            flag = (ub.chk-gds.out-code <> ub.chk-doc.out-code) or flag.
        end.
         for each ub.chk-pay where ub.chk-pay.doc-code = ub.chk-doc.doc-code no-lock:
            gg = gg +  ub.chk-pay.tot-base.
            flag = (ub.chk-pay.out-code <> ub.chk-doc.out-code) or flag.
        end.
        if abs(ff - gg) > 0.0000000002 or flag then do:
            put stream PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code  format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ff   format "-999,999.9999999999" space(1)
            gg format "-999,999.9999999999" space(1)
            (ff - gg) format "-999,999.9999999999" space(1)
            flag
            skip.
        accum1 = accum1 + (ff - gg) .
        end.
    END. /*3*/
    WHEN 4 then do:
        ff = 0.
        flag = no.
        for each ub.chk-pay No-LOCK WHERE ub.chk-pay.doc-code = ub.chk-doc.doc-code:
            ff = ff + ub.chk-pay.tot-rubl .
            flag = (ub.chk-pay.out-code <> ub.chk-doc.out-code) or flag.
        end.
        if abs(ff - ub.chk-doc.netto)  > 0.0000000002 or flag then do:
            PUT STREAM PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code  format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ub.chk-doc.netto format "-999,999.9999999999" space(1)
            ff   format "-999,999.9999999999" space(1)
            (ff - ub.chk-doc.netto) format "-999,999.9999999999" space(1)
            flag
            SKIP.
            accum1 = accum1 + (ff - ub.chk-doc.netto).
        end.
    END. /*when 4*/
    WHEN 5 then do:
        ff = 0.
        flag = no.
        for each ub.chk-pay NO-LOCK WHERE ub.chk-pay.doc-code = chk-doc.doc-code :
            ff = ff + ub.chk-pay.tot-base .
            flag = (ub.chk-pay.out-code <> chk-doc.out-code) or flag.
        end.
        if abs(ff - chk-doc.netto)  > 0.0000000002 or flag then do:
            PUT STREAM PrnLibStream UNFORMATTED
            chk-doc.doc-code  format "X(20)" space(1)
            chk-doc.pay-desk format "99999" space(1)
            chk-doc.chk-num format "-99999" space(1)
            chk-doc.netto format "-999,999.9999999999" space(1)
            ff   format "-999,999.9999999999" space(1)
            (ff - chk-doc.netto) format "-999,999.9999999999" space(1)
            flag
            SKIP.
            accum1 = accum1 + (ff - chk-doc.netto).
        end.
    END. /*when 5*/
    WHEN 6 then do:
        flag = no.
        for each ub.chk-pay NO-LOCK WHERE ub.chk-pay.doc-code = chk-doc.doc-code :
            flag = ub.chk-pay.out-code <> chk-doc.out-code.
            FIND FIRST ub.cash-pay NO-LOCK WHERE
                                ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
                                ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
            if not avail ub.cash-pay or flag then do:
                PUT STREAM PrnLibStream UNFORMATTED
                ub.chk-doc.doc-code  format "X(20)" space(1)
                ub.chk-doc.pay-desk format "99999" space(1)
                ub.chk-doc.chk-num format "-99999" space(1)
                (if v-curr-r-b = {&r-b-base}
                then ub.chk-pay.tot-base
                else ub.chk-pay.tot-rubl)  format "-999,999.9999999999" space(1)
                (if not avail cash-pay
                then ("+" + fill(" ", 29) + fill(" ", 29) + fill(" ", 25)
                        )
                else (fill(" ", 30) +
                        string(ub.chk-pay.curr-code, "99999") + fill(" ", 24) +
                        string(cash-pay.curr-code, "99999") + fill(" ", 20)
                        )
                )
                " "
                flag
                SKIP.
            end.
        end.
    END. /*WHEN 6*/
    WHEN 7 then do:
        assign
        ff = 0
        gg= 0
        flag = no
        .
        for each ub.chk-pay NO-LOCK WHERE ub.chk-pay.doc-code = ub.chk-doc.doc-code :
            assign
            ff = ff + ub.chk-pay.tot-rubl
            gg = gg + ub.chk-pay.tot-base
            flag = (ub.chk-pay.out-code <> ub.chk-doc.out-code) or flag
            .
        end.
        if abs(ff - gg)  > 0.0000000002 or flag then do:
            PUT STREAM PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code  format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ub.chk-doc.netto format "-999,999.9999999999" space(1)
            ff   format "-999,999.9999999999" space(1)
            (ff - gg) format "-999,999.9999999999" space(1)
            flag
            SKIP.
            accum1 = accum1 + (ff - gg) .
        end.
    end.  /*when 7*/
    WHEN 8 then do:
        assign
        ff = 0
        gg= 0
        flag = no
        .
        for each ub.chk-gds NO-LOCK WHERE ub.chk-gds.doc-code = ub.chk-doc.doc-code :
          if ub.chk-gds.write-off-code <> ?
          and ub.chk-gds.write-off-code > 0 then next.
          assign
          ff = ff + ub.chk-gds.discnt * ub.chk-gds.doc-qnty
          flag = (ub.chk-gds.out-code <> ub.chk-doc.out-code) or flag
          .
        end.
        gg = ub.chk-doc.discnt.
        if abs(ff - gg)  > 0.0000000002 or flag then do:
            PUT STREAM PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code  format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ff   format "-999,999.9999999999" space(1)
            gg format "-999,999.9999999999" space(1)
            (ff - gg) format "-999,999.9999999999" space(1)
            flag
            SKIP.
            accum1 = accum1 + (ff - gg) .
        end.
    end.  /*when 8*/
    WHEN 9 then do:
        if abs(ub.chk-doc.netto - (ub.chk-doc.tot-doc - ub.chk-doc.discnt )
               ) > 0.0000000002  then do:
            put stream PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ub.chk-doc.tot-doc format "-999,999.9999999999" space(1)
            ub.chk-doc.discnt format "-999,999.9999999999" space(1)
            ub.chk-doc.netto format "-999,999.9999999999" space(1)
            ub.chk-doc.tot-doc - ub.chk-doc.discnt  format "-999,999.9999999999" space(1)
            ub.chk-doc.netto - (ub.chk-doc.tot-doc - ub.chk-doc.discnt)  format "-999,999.9999999999" space(1)
           skip.
            accum1 = accum1 +  (ub.chk-doc.netto - (ub.chk-doc.tot-doc - ub.chk-doc.discnt)).
        end.
    END. /*when 9*/
    WHEN 10 then do:
        assign
        ff = 0
        flag = no.
        if lookup(string(ub.chk-doc.chk-type), {&petrol-receipt-codes}) > 0 then next.
        for each ub.chk-gds where ub.chk-gds.doc-code = ub.chk-doc.doc-code no-lock:
            if ub.chk-gds.write-off-code <> ? and ub.chk-gds.write-off-code > 0 then next.
            assign
            flag = (ub.chk-gds.out-code <> ub.chk-doc.out-code) or flag
            ff = ff +  ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt) .
        end.
        if abs(ff - ub.chk-doc.netto) > 0.0000000002  or flag then do:
            put stream PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ff format "-999,999.9999999999" space(1)
            ub.chk-doc.netto  format "-999,999.9999999999" space(1)
            (ff - ub.chk-doc.netto)  format "-999,999.9999999999" space(1)
            flag
            skip.
            accum1 = accum1 + (ff - ub.chk-doc.netto).
        end.
    END. /*WHEN 10*/
    WHEN 11 then do:
        assign
        ff = 0
        flag = no.
        if lookup(string(ub.chk-doc.chk-type), {&petrol-receipt-codes}) > 0 then next.
         for each ub.chk-gds where ub.chk-gds.doc-code = ub.chk-doc.doc-code no-lock:
            if ub.chk-gds.write-off-code <> ? and ub.chk-gds.write-off-code > 0 then next.
            assign
            flag = (ub.chk-gds.out-code <> ub.chk-doc.out-code) or flag
            ff = ff +  ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt)
            .
        end.
        if abs(ff - (ub.chk-doc.tot-doc - ub.chk-doc.discnt)) > 0.0000000002  or flag then do:
            put stream PrnLibStream  UNFORMATTED
            ub.chk-doc.doc-code format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ub.chk-doc.tot-doc format "-999,999.9999999999" space(1)
            ub.chk-doc.discnt format "-999,999.9999999999" space(1)
            ub.chk-doc.sub-discnt format "-999,999.9999999999" space(1)
            ff format "-999,999.9999999999" space(1)
            ub.chk-doc.tot-doc - ub.chk-doc.discnt  format "-999,999.9999999999" space(1)
            ff - (ub.chk-doc.tot-doc - ub.chk-doc.discnt)  format "-999,999.9999999999" space(1)
            flag
            skip.
            accum1 = accum1 + (ff - (ub.chk-doc.tot-doc - ub.chk-doc.discnt)).
        end.
    END. /*WHEN 11*/
    WHEN 12 then do:
        flag = no.
        if ub.chk-doc.netto >= 0 and can-find(FIRST ub.chk-gds where ub.chk-gds.doc-qnty < 0 and
                                                                        ub.chk-gds.doc-code = ub.chk-doc.doc-code) then do:

            for each ub.chk-gds where ub.chk-gds.doc-qnty < 0 AND ub.chk-gds.doc-code = ub.chk-doc.doc-code NO-LOCK:
                flag = ub.chk-gds.out-code <> ub.chk-doc.out-code.
                FIND FIRST for-gds where for-gds.b-code = ub.chk-gds.b-code AND for-gds.doc-qnty > 0
                AND for-gds.doc-code = ub.chk-gds.doc-code NO-LOCK NO-ERROR.
                if avail for-gds and for-gds.price-base <> ub.chk-gds.price-base or flag then do:
                    PUT stream PrnLibStream UNFORMATTED
                    ub.chk-gds.doc-code FORMAT "X(20)"  space(1)
                    ub.chk-doc.pay-desk format "99999" space(1)
                    ub.chk-doc.chk-num format "-99999" space(1)
                    ub.chk-gds.b-code format "-9999999999"
                    ub.chk-gds.price-base format "-999,999,999.999"
                    for-gds.price-base format "-999,999,999.999"
                    (ub.chk-gds.price-base - for-gds.price-base) * ub.chk-gds.doc-qnty format "-999,999.9999999999" space(1)
                    flag
                    skip.
                    accum1 = accum1 +  (ub.chk-gds.price-base - for-gds.price-base) * ub.chk-gds.doc-qnty.
                end. /*if avail for-gds*/
          end. /*for each ub.chk-gds*/
        end. /*if ub.chk-doc.netto >= 0*/
        if ub.chk-doc.netto < 0 and can-find(FIRST ub.chk-gds where ub.chk-gds.doc-qnty > 0 and
                                                                    ub.chk-gds.doc-code = ub.chk-doc.doc-code) then do:
            FOR EACH ub.chk-gds where ub.chk-gds.doc-qnty > 0 AND ub.chk-gds.doc-code = ub.chk-doc.doc-code NO-LOck:
                flag = ub.chk-gds.out-code <> ub.chk-doc.out-code.
                FIND FIRST for-gds where for-gds.b-code = ub.chk-gds.b-code and for-gds.doc-qnty < 0
                AND for-gds.doc-code = ub.chk-gds.doc-code  NO-LOCK NO-ERROR.
                if avail for-gds and for-gds.price-base <> ub.chk-gds.price-base or flag then do:
                    PUT stream PrnLibStream UNFORMATTED
                    ub.chk-gds.doc-code FORMAT "X(20)"  space(1)
                    ub.chk-doc.pay-desk format "99999" space(1)
                    ub.chk-doc.chk-num format "-99999" space(1)
                    ub.chk-gds.b-code format "-9999999999"
                    ub.chk-gds.price-base format "-999,999,999.999"
                    for-gds.price-base format "-999,999,999.999"
                    (ub.chk-gds.price-base - for-gds.price-base) * ub.chk-gds.doc-qnty   format "-999,999.9999999999" space(1)
                    flag
                    skip.
                    accum1 = accum1 +  (ub.chk-gds.price-base - for-gds.price-base) * ub.chk-gds.doc-qnty  .
                end. /*if avail for-gds*/
            end. /*for EACH ub.chk-gds*/
        end. /*if ub.chk-doc.netto < 0*/
    END. /*WHEN 12*/
    when 13 then do:
        assign
        ff = 0
        flag = no.
        if lookup(string(ub.chk-doc.chk-type), {&petrol-receipt-codes}) > 0 then next.
         for each ub.chk-gds where ub.chk-gds.doc-code = ub.chk-doc.doc-code no-lock:
          if ub.chk-gds.write-off-code <> ? and ub.chk-gds.write-off-code <> 0 then do:
            assign
            flag = (ub.chk-gds.out-code <> ub.chk-doc.out-code) or flag
            ff = ff +  ub.chk-gds.doc-qnty * ub.chk-gds.price-base  * (if ub.chk-gds.write-off-code > 0 then 1 else - 1)
            .
          end.
        end.
        if abs(ub.chk-doc.sub-discnt - ff ) > 0.0000000002  or flag then do:
            put stream PrnLibStream  UNFORMATTED
            ub.chk-doc.doc-code format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ub.chk-doc.sub-discnt format "-999,999.9999999999" space(1)
            ff format "-999,999.9999999999" space(1)
            ub.chk-doc.sub-discnt - ff format "-999,999.9999999999" space(1)
            flag
            skip.
            accum1 = accum1 + (ub.chk-doc.sub-discnt - ff).
        end.
    end.
    when 14 then do:
      assign
      ff = 0
      .
      if lookup(string(ub.chk-doc.chk-type), {&petrol-receipt-codes}) > 0
      or ub.chk-doc.chk-type = integer({&rcpt-annu})
      then next.
      for each ub.chk-discnt no-lock where
              ub.chk-discnt.doc-code = ub.chk-doc.doc-code
          AND ub.chk-discnt.record-type = 2,
          first ub.chk-gds no-lock where
              ub.chk-gds.doc-code = ub.chk-doc.doc-code
          AND ub.chk-gds.line-num = ub.chk-discnt.object-line-num:
        assign
        ff = ff +  ub.chk-discnt.discnt-value-abs
        accum1 = accum1 + ub.chk-discnt.discnt-value-abs
        .
        put stream PrnLibStream  UNFORMATTED
        ub.chk-doc.doc-code   format "X(20)"           space(1)
        ub.chk-doc.chk-date   format "99/99/9999"      space(1)
        ub.chk-doc.out-code   format "X(20)"           space(1)
        ub.chk-doc.pay-desk   format "99999"           space(1)
        ub.chk-doc.chk-num    format "-99999"          space(1)
        ub.chk-gds.line-num   format "-99999"          space(1)
        ub.chk-gds.b-code     format "999999999"       space(1)
        ub.chk-gds.price-base format "-999,999,999.99" space(1)
        ub.chk-gds.doc-qnty   FORMAT "-999,999.99"     space(1)
        ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt) format "-999,999,999.999999999"  space(1)
        ub.chk-discnt.discnt-value-abs format "-999,999,999.999999999"  space(1)
        ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt + ub.chk-discnt.discnt-value-abs) * ub.chk-discnt.discnt-value-pcnt / 100 format "-999,999,999.999999999"
        skip.
      end.
      if ff <> 0 then
      put stream PrnLibStream  UNFORMATTED
      "Итого по чеку"  space(1)
      ff format "-999,999,999.999999999"
      skip(1).
    end.
  END CASE.
  run waitfram-hide in this-procedure .
END.