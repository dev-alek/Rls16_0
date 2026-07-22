block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: testq0.p $
$Archive: cmp/testq0.p $

Компилируемый ран-тайм модуль тестов по чекам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/09/05
Author: Bakhtadze Natalya
Creation date: 10/09/05

*/

DEFINE INPUT PARAMETER test-number as integer.
DEFINE INPUT PARAMETER my-inkas as char.
define input parameter p-call-handle as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: testq0.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/testq0.p $":U .
define variable vss-description as character no-undo init "Компилируемый ран-тайм модуль тестов по чекам".
{ cmp/vssrevis.i }

def SHARED var ff as decimal.
def SHARED var gg as decimal.
DEF SHARED VAR accum1 as decimal.
DEFINE VARIABLE bc-buf as char no-undo.
DEFINE VARIABLE b-c like bar-code.b-code no-undo.
DEFINE VARIABLE flag as logical.
DEFINE VARIABLE price-from-check like chk-gds.price-base no-undo .
DEFINE VARIABLE r-bar-code like ub.bar-code.b-code no-undo .
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
DEFINE VARIABLE v-err       as logical           no-undo .

define buffer for-gds for chk-gds.

DEFINE SHARED STREAM PrnLibStream.
{ cmp/trg-def.i }

define variable v-curr-r-b as character no-undo .
if valid-handle(p-call-handle)
and p-call-handle:get-signature ('callback-curr-r-b':U) <> "":U then do:
  run callback-curr-r-b in p-call-handle (output v-curr-r-b) no-error.
end.
else do:
  error-status:error = yes.
end.
if error-status:error then do:
  message
  "Не могу получить значение параметра ТИП ВАЛЮТЫ ПРОДАЖ - base или rubl"
  view-as alert-box error .
  return error .
end.


&if "{2}" = "all" OR "{2}" = "ALL" &then
FOR EACH inkas NO-LOCK where
         inkas.obj-type = p-obj-type
    AND  inkas.obj-code = p-obj-code,
    EACH chk-doc NO-LOCK where
         chk-doc.out-code = inkas.inkas-code {1}:
        my-inkas = inkas.inkas-code.
&else
FOR EACH chk-doc NO-LOCK where
         chk-doc.out-code = my-inkas {1}:
&endif
  if chk-doc.chk-type = integer({&rcpt-annu}) then next.
  if lookup(string(chk-doc.chk-type),{&receipt-codes}) > 0 then next.
  if my-inkas = ? and NOT p-obj-code = chk-doc.obj-code then NEXT.

  if valid-handle(p-call-handle)
  and p-call-handle:get-signature ('waifram-show':U) <> "":U then do:
    run waitfram-show in p-call-handle ("Ждите - идет обработка -  чек " + chk-doc.doc-code).
  end.
  CASE test-number:
    WHEN 1 then do:
      FOR EACH chk-gds no-lock where chk-gds.doc-code = CHK-DOC.doc-code :
        flag = no.
        IF chk-gds.b-code = ? or chk-gds.b-code <= 0 THEN FLAG = YES.
        else do:
          assign
          price-from-check = chk-gds.price-base
          bc-buf = string(chk-gds.b-code)
          .
          if valid-handle(p-call-handle)
          and p-call-handle:get-signature ('callback-bc-rcnz':U) <> "":U then do:
            run callback-bc-rcnz in p-call-handle(
              input bc-buf
              ,input price-from-check
              ,input chk-doc.obj-type
              ,input chk-doc.obj-code
              ,input yes
              ,input no
              ,output varresult
              ,output vartype-bc
              ,output varweight
              ,buffer bar-code
              ,buffer prod-bc
              ,buffer place)
              no-error.
              if error-status:error then do:
                release bar-code.
              end.
          end.

          if avail bar-code then do:
            v-err = no.
            if valid-handle(p-call-handle)
            and p-call-handle:get-signature ('callback-gdsbcode':U) <> "":U then do:
            run callback-gdsbcode in p-call-handle
              (input bar-code.gds-code
              ,input bar-code.node-code
              ,output r-bar-code
              ) no-error .
            if error-status:error then v-err = yes.
           end.
           else  do:
            v-err = yes.
           end.
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
                if valid-handle(p-call-handle)
                and p-call-handle:get-signature ('callback-gdspcode':U) <> "":U then do:
                  run callback-gdspcode in p-call-handle
                    (input bar-code.gds-code
                    ,input bar-code.node-code
                    ,input bar-code.in-code
                    ,input bar-code.part-code
                    ,output r-bar-code
                    ) no-error .
                  if error-status:error then v-err = yes.
                end.
                else do:
                  v-err = yes.
                end.
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
        for each chk-gds where chk-gds.doc-code = chk-doc.doc-code no-lock:
            if chk-gds.write-off-code <> ? and chk-gds.write-off-code > 0 then next.
            ff = ff + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt).
            flag = (chk-gds.out-code <> chk-doc.out-code) OR flag.
        end.
         for each chk-pay where chk-pay.doc-code = chk-doc.doc-code no-lock:
            gg = gg +  chk-pay.tot-rubl.
            flag = (chk-pay.out-code <> chk-doc.out-code) OR flag.
        end.
        if abs(ff - gg) > 0.0000000002 or flag then do:
            put stream PrnLibStream UNFORMATTED
            chk-doc.doc-code  format "X(20)" space(1)
            chk-doc.pay-desk format "99999" space(1)
            chk-doc.chk-num format "-99999" space(1)
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
        if lookup(string(chk-doc.chk-type), {&petrol-receipt-codes}) > 0 then next.
         for each chk-gds where chk-gds.doc-code = chk-doc.doc-code no-lock:
           if chk-gds.write-off-code <> ? and chk-gds.write-off-code > 0 then next.
            ff = ff + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt).
            flag = (chk-gds.out-code <> chk-doc.out-code) or flag.
        end.
         for each chk-pay where chk-pay.doc-code = chk-doc.doc-code no-lock:
            gg = gg +  chk-pay.tot-base.
            flag = (chk-pay.out-code <> chk-doc.out-code) or flag.
        end.
        if abs(ff - gg) > 0.0000000002 or flag then do:
            put stream PrnLibStream UNFORMATTED
            chk-doc.doc-code  format "X(20)" space(1)
            chk-doc.pay-desk format "99999" space(1)
            chk-doc.chk-num format "-99999" space(1)
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
        for each chk-pay No-LOCK WHERE chk-pay.doc-code = chk-doc.doc-code:
            ff = ff + chk-pay.tot-rubl .
            flag = (chk-pay.out-code <> chk-doc.out-code) or flag.
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
    END. /*when 4*/
    WHEN 5 then do:
        ff = 0.
        flag = no.
        for each chk-pay NO-LOCK WHERE chk-pay.doc-code = chk-doc.doc-code :
            ff = ff + chk-pay.tot-base .
            flag = (chk-pay.out-code <> chk-doc.out-code) or flag.
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
        for each chk-pay NO-LOCK WHERE chk-pay.doc-code = chk-doc.doc-code :
            flag = chk-pay.out-code <> chk-doc.out-code.
            FIND FIRST cash-pay NO-LOCK WHERE
                                cash-pay.cdpay-code = chk-pay.pay-code AND
                                cash-pay.curr-code = chk-pay.curr-code No-ERROR.
            if not avail cash-pay or flag then do:
                PUT STREAM PrnLibStream UNFORMATTED
                chk-doc.doc-code  format "X(20)" space(1)
                chk-doc.pay-desk format "99999" space(1)
                chk-doc.chk-num format "-99999" space(1)
                (if v-curr-r-b = {&r-b-base}
                then chk-pay.tot-base
                else chk-pay.tot-rubl)  format "-999,999.9999999999" space(1)
                (if not avail cash-pay
                then ("+" + fill(" ", 29) + fill(" ", 29) + fill(" ", 25)
                        )
                else (fill(" ", 30) +
                        string(chk-pay.curr-code, "99999") + fill(" ", 24) +
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
        for each chk-pay NO-LOCK WHERE chk-pay.doc-code = chk-doc.doc-code :
            assign
            ff = ff + chk-pay.tot-rubl
            gg = gg + chk-pay.tot-base
            flag = (chk-pay.out-code <> chk-doc.out-code) or flag
            .
        end.
        if abs(ff - gg)  > 0.0000000002 or flag then do:
            PUT STREAM PrnLibStream UNFORMATTED
            chk-doc.doc-code  format "X(20)" space(1)
            chk-doc.pay-desk format "99999" space(1)
            chk-doc.chk-num format "-99999" space(1)
            chk-doc.netto format "-999,999.9999999999" space(1)
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
        for each chk-gds NO-LOCK WHERE chk-gds.doc-code = chk-doc.doc-code :
          if chk-gds.write-off-code <> ?
          and chk-gds.write-off-code > 0 then next.
          assign
          ff = ff + chk-gds.discnt * chk-gds.doc-qnty
          flag = (chk-gds.out-code <> chk-doc.out-code) or flag
          .
        end.
        gg = chk-doc.discnt.
        if abs(ff - gg)  > 0.0000000002 or flag then do:
            PUT STREAM PrnLibStream UNFORMATTED
            chk-doc.doc-code  format "X(20)" space(1)
            chk-doc.pay-desk format "99999" space(1)
            chk-doc.chk-num format "-99999" space(1)
            ff   format "-999,999.9999999999" space(1)
            gg format "-999,999.9999999999" space(1)
            (ff - gg) format "-999,999.9999999999" space(1)
            flag
            SKIP.
            accum1 = accum1 + (ff - gg) .
        end.
    end.  /*when 8*/
    WHEN 9 then do:
        if abs(chk-doc.netto - (chk-doc.tot-doc - chk-doc.discnt )
               ) > 0.0000000002  then do:
            put stream PrnLibStream UNFORMATTED
            chk-doc.doc-code format "X(20)" space(1)
            chk-doc.pay-desk format "99999" space(1)
            chk-doc.chk-num format "-99999" space(1)
            chk-doc.tot-doc format "-999,999.9999999999" space(1)
            chk-doc.discnt format "-999,999.9999999999" space(1)
            chk-doc.netto format "-999,999.9999999999" space(1)
            chk-doc.tot-doc - chk-doc.discnt  format "-999,999.9999999999" space(1)
            chk-doc.netto - (chk-doc.tot-doc - chk-doc.discnt)  format "-999,999.9999999999" space(1)
           skip.
            accum1 = accum1 +  (chk-doc.netto - (chk-doc.tot-doc - chk-doc.discnt)).
        end.
    END. /*when 9*/
    WHEN 10 then do:
        assign
        ff = 0
        flag = no.
        if lookup(string(chk-doc.chk-type), {&petrol-receipt-codes}) > 0 then next.
        for each chk-gds where chk-gds.doc-code = chk-doc.doc-code no-lock:
            if chk-gds.write-off-code <> ? and chk-gds.write-off-code > 0 then next.
            assign
            flag = (chk-gds.out-code <> chk-doc.out-code) or flag
            ff = ff +  chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt) .
        end.
        if abs(ff - chk-doc.netto) > 0.0000000002  or flag then do:
            put stream PrnLibStream UNFORMATTED
            chk-doc.doc-code format "X(20)" space(1)
            chk-doc.pay-desk format "99999" space(1)
            chk-doc.chk-num format "-99999" space(1)
            ff format "-999,999.9999999999" space(1)
            chk-doc.netto  format "-999,999.9999999999" space(1)
            (ff - chk-doc.netto)  format "-999,999.9999999999" space(1)
            flag
            skip.
            accum1 = accum1 + (ff - chk-doc.netto).
        end.
    END. /*WHEN 10*/
    WHEN 11 then do:
        assign
        ff = 0
        flag = no.
        if lookup(string(chk-doc.chk-type), {&petrol-receipt-codes}) > 0 then next.
         for each chk-gds where chk-gds.doc-code = chk-doc.doc-code no-lock:
            if chk-gds.write-off-code <> ? and chk-gds.write-off-code > 0 then next.
            assign
            flag = (chk-gds.out-code <> chk-doc.out-code) or flag
            ff = ff +  chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt)
            .
        end.
        if abs(ff - (chk-doc.tot-doc - chk-doc.discnt)) > 0.0000000002  or flag then do:
            put stream PrnLibStream  UNFORMATTED
            chk-doc.doc-code format "X(20)" space(1)
            chk-doc.pay-desk format "99999" space(1)
            chk-doc.chk-num format "-99999" space(1)
            chk-doc.tot-doc format "-999,999.9999999999" space(1)
            chk-doc.discnt format "-999,999.9999999999" space(1)
            chk-doc.sub-discnt format "-999,999.9999999999" space(1)
            ff format "-999,999.9999999999" space(1)
            chk-doc.tot-doc - chk-doc.discnt  format "-999,999.9999999999" space(1)
            ff - (chk-doc.tot-doc - chk-doc.discnt)  format "-999,999.9999999999" space(1)
            flag
            skip.
            accum1 = accum1 + (ff - (chk-doc.tot-doc - chk-doc.discnt)).
        end.
    END. /*WHEN 11*/
    WHEN 12 then do:
        flag = no.
        if chk-doc.netto >= 0 and can-find(FIRST chk-gds where chk-gds.doc-qnty < 0 and
                                                                        chk-gds.doc-code = chk-doc.doc-code) then do:

            for each chk-gds where chk-gds.doc-qnty < 0 AND chk-gds.doc-code = chk-doc.doc-code NO-LOCK:
                flag = chk-gds.out-code <> chk-doc.out-code.
                FIND FIRST for-gds where for-gds.b-code = chk-gds.b-code AND for-gds.doc-qnty > 0
                AND for-gds.doc-code = chk-gds.doc-code NO-LOCK NO-ERROR.
                if avail for-gds and for-gds.price-base <> chk-gds.price-base or flag then do:
                    PUT stream PrnLibStream UNFORMATTED
                    chk-gds.doc-code FORMAT "X(20)"  space(1)
                    chk-doc.pay-desk format "99999" space(1)
                    chk-doc.chk-num format "-99999" space(1)
                    chk-gds.b-code format "-9999999999"
                    chk-gds.price-base format "-999,999,999.999"
                    for-gds.price-base format "-999,999,999.999"
                    (chk-gds.price-base - for-gds.price-base) * chk-gds.doc-qnty format "-999,999.9999999999" space(1)
                    flag
                    skip.
                    accum1 = accum1 +  (chk-gds.price-base - for-gds.price-base) * chk-gds.doc-qnty.
                end. /*if avail for-gds*/
          end. /*for each chk-gds*/
        end. /*if chk-doc.netto >= 0*/
        if chk-doc.netto < 0 and can-find(FIRST chk-gds where chk-gds.doc-qnty > 0 and
                                                                    chk-gds.doc-code = chk-doc.doc-code) then do:
            FOR EACH chk-gds where chk-gds.doc-qnty > 0 AND chk-gds.doc-code = chk-doc.doc-code NO-LOck:
                flag = chk-gds.out-code <> chk-doc.out-code.
                FIND FIRST for-gds where for-gds.b-code = chk-gds.b-code and for-gds.doc-qnty < 0
                AND for-gds.doc-code = chk-gds.doc-code  NO-LOCK NO-ERROR.
                if avail for-gds and for-gds.price-base <> chk-gds.price-base or flag then do:
                    PUT stream PrnLibStream UNFORMATTED
                    chk-gds.doc-code FORMAT "X(20)"  space(1)
                    chk-doc.pay-desk format "99999" space(1)
                    chk-doc.chk-num format "-99999" space(1)
                    chk-gds.b-code format "-9999999999"
                    chk-gds.price-base format "-999,999,999.999"
                    for-gds.price-base format "-999,999,999.999"
                    (chk-gds.price-base - for-gds.price-base) * chk-gds.doc-qnty   format "-999,999.9999999999" space(1)
                    flag
                    skip.
                    accum1 = accum1 +  (chk-gds.price-base - for-gds.price-base) * chk-gds.doc-qnty  .
                end. /*if avail for-gds*/
            end. /*for EACH CHK-GDS*/
        end. /*if chk-doc.netto < 0*/
    END. /*WHEN 12*/
    when 13 then do:
        assign
        ff = 0
        flag = no.
        if lookup(string(chk-doc.chk-type), {&petrol-receipt-codes}) > 0 then next.
         for each chk-gds where chk-gds.doc-code = chk-doc.doc-code no-lock:
          if chk-gds.write-off-code <> ? and chk-gds.write-off-code <> 0 then do:
            assign
            flag = (chk-gds.out-code <> chk-doc.out-code) or flag
            ff = ff +  chk-gds.doc-qnty * chk-gds.price-base  * (if chk-gds.write-off-code > 0 then 1 else - 1)
            .
          end.
        end.
        if abs(chk-doc.sub-discnt - ff ) > 0.0000000002  or flag then do:
            put stream PrnLibStream  UNFORMATTED
            chk-doc.doc-code format "X(20)" space(1)
            chk-doc.pay-desk format "99999" space(1)
            chk-doc.chk-num format "-99999" space(1)
            chk-doc.sub-discnt format "-999,999.9999999999" space(1)
            ff format "-999,999.9999999999" space(1)
            chk-doc.sub-discnt - ff format "-999,999.9999999999" space(1)
            flag
            skip.
            accum1 = accum1 + (chk-doc.sub-discnt - ff).
        end.
    end.
    when 14 then do:
      assign
      ff = 0
      .
      if lookup(string(chk-doc.chk-type), {&petrol-receipt-codes}) > 0
      or chk-doc.chk-type = integer({&rcpt-annu})
      then next.
      for each chk-discnt no-lock where
              chk-discnt.doc-code = chk-doc.doc-code
          AND chk-discnt.record-type = 2,
          first chk-gds no-lock where
              chk-gds.doc-code = chk-doc.doc-code
          AND chk-gds.line-num = chk-discnt.object-line-num:
        assign
        ff = ff +  chk-discnt.discnt-value-abs
        accum1 = accum1 + chk-discnt.discnt-value-abs
        .
        put stream PrnLibStream  UNFORMATTED
        chk-doc.doc-code   format "X(20)"           space(1)
        chk-doc.chk-date   format "99/99/9999"      space(1)
        chk-doc.out-code   format "X(20)"           space(1)
        chk-doc.pay-desk   format "99999"           space(1)
        chk-doc.chk-num    format "-99999"          space(1)
        chk-gds.line-num   format "-99999"          space(1)
        chk-gds.b-code     format "999999999"       space(1)
        chk-gds.price-base format "-999,999,999.99" space(1)
        chk-gds.doc-qnty   FORMAT "-999,999.99"     space(1)
        chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt) format "-999,999,999.999999999"  space(1)
        chk-discnt.discnt-value-abs format "-999,999,999.999999999"  space(1)
        chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-discnt.discnt-value-abs) * chk-discnt.discnt-value-pcnt / 100 format "-999,999,999.999999999"
        skip.
      end.
      if ff <> 0 then
      put stream PrnLibStream  UNFORMATTED
      "Итого по чеку"  space(1)
      ff format "-999,999,999.999999999"
      skip(1).
    end.
  END CASE.
END.