/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сбор данных для выгрузки разброски по платежам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/05/07
Author: Bakhtadze Natalya
Creation date: 11/05/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

define variable v-pay-desk as integer   no-undo .
define variable v-pay-card as character no-undo .
define variable v-doc-code as character no-undo .
define variable v-doc-code-r as character no-undo .
define variable v-doc-code-v as character no-undo .
define variable v-density as decimal no-undo .
DEFINE BUFFER b-treal-2 for treal-2.
DEFINE BUFFER b-treal-3 for treal-3.
DEFINE BUFFER b-treal-4 for treal-4.
DEFINE BUFFER b2-treal-2 for treal-2.
DEFINE BUFFER b2-treal-3 for treal-3.
DEFINE BUFFER b2-treal-4 for treal-4.
DEFINE BUFFER b3-treal-2 for treal-2.
DEFINE BUFFER b3-treal-3 for treal-3.
DEFINE BUFFER b3-treal-4 for treal-4.
define buffer buf_temp-cpa-pcep for temp-cpa-pcep.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_goods for ub.goods.
define buffer ras-doc for ub.trn-doc.
define buffer ret-doc for ub.trn-doc.

&else

CASE entry(1, buf_chk-gds-pay.line-type, {&delim-par}):
  WHEN {&petrolium}  then do:
    if p-petrol then do:
      /*если есть разброска по префикс то в этом месте собираем для префикса*/
      if ub.chk-doc.netto < 0 then do:
        if v-doc-code-r <> ub.chk-doc.out-code
        then do:
          find first ras-doc no-lock
            where ras-doc.doc-code = ub.chk-doc.out-code
            no-error .
          if not available ras-doc then do:
            message
            substitute("Отсутствует документ расхода по чеку &1"
                        , ub.chk-doc.doc-code
                        )   skip
            "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
            view-as alert-box error .
            return error .
          end.
          v-doc-code-r = ras-doc.doc-code.
          find first ret-doc no-lock where
                    ret-doc.doc-code = ras-doc.out-code no-error .
          if not available ret-doc then do:
            message
            substitute("Отсутствует документ возврата по чеку &1"
                      , ub.chk-doc.doc-code
                      )   skip
            "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
            view-as alert-box error .
            return error .
          end.
          v-doc-code-v = ret-doc.doc-code.
        end.
        assign
        v-doc-code = v-doc-code-v
        .
      end. /*if ub.chk-doc.netto < 0 then do:*/
      else do:
        assign
        v-doc-code = ub.chk-doc.out-code
        .
      end.
      if p-by-pay-card-prefix
      and v-pay-card <> "other"
      then do:
        FIND FIRST b2-treal-2 No-LOCK WHERE
                  b2-treal-2.gds-code = buf_bar-code.gds-code
              AND b2-treal-2.cpay-code = buf_chk-gds-pay.pay-code
              AND b2-treal-2.curr-code = buf_chk-gds-pay.curr-code
              AND b2-treal-2.is-pay = yes
              AND b2-treal-2.pay-desk = v-pay-desk
              AND b2-treal-2.prefix = v-pay-card  No-ERROR.
        IF NOT AVAIL  b2-treal-2 then do:
          FIND last b3-treal-2 No-LOCK WHERE
                    b3-treal-2.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
          create b2-treal-2.
          assign
          b2-treal-2.gds-code = buf_bar-code.gds-code
          b2-treal-2.cpay-code = buf_chk-gds-pay.pay-code
          b2-treal-2.curr-code = buf_chk-gds-pay.curr-code
          b2-treal-2.out-name = buf_cash-pay.obj-name
          b2-treal-2.is-pay = yes
          b2-treal-2.ii = (if avail b3-treal-2
                        then b3-treal-2.ii + 1
                        else 1)
          b2-treal-2.pay-desk = v-pay-desk
          b2-treal-2.prefix   = v-pay-card
          .

        END.
        find first buf_goods  no-lock where
                  buf_goods.gds-code  = buf_bar-code.gds-code .
        find first buf_doc-line no-lock where
                  buf_doc-line.doc-code  = v-doc-code
              and buf_doc-line.artic     = buf_goods.artic
              and buf_doc-line.prod-type = buf_goods.prod-type
              and buf_doc-line.prod-code = buf_goods.prod-code  no-error.
        assign
        v-density = ( if available buf_doc-line
                          then buf_doc-line.fact-density
                          else 0 ).

        assign
        b2-treal-2.netto = b2-treal-2.netto +
                                        (if v-curr-r-b = {&r-b-base}
                                        or v-base-code = 0
                                        then buf_chk-gds-pay.tot-r-b
                                        else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
        /*netto всегда в б.в.*/
        b2-treal-2.qnty1 = b2-treal-2.qnty1 + buf_chk-gds-pay.eff-doc-qnty
        b2-treal-2.qnty2 = b2-treal-2.qnty2 + buf_chk-gds-pay.eff-doc-qnty * v-density
        b2-treal-2.netto-rubl = b2-treal-2.netto-rubl +
                                        (if v-curr-r-b = {&r-b-rubl}
                                        or v-base-code = 0
                                        then buf_chk-gds-pay.tot-r-b
                                        else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))

        .
      end. /*if p-by-pay-card-prefix*/
      FIND FIRST treal-2 No-LOCK WHERE
                treal-2.gds-code = buf_bar-code.gds-code
            AND  treal-2.cpay-code = buf_chk-gds-pay.pay-code
            AND  treal-2.curr-code = buf_chk-gds-pay.curr-code
            AND  treal-2.is-pay = yes
            AND treal-2.pay-desk = v-pay-desk
            AND treal-2.prefix = '':U  No-ERROR.
      IF NOT AVAIL treal-2 then do:
        FIND last b-treal-2 No-LOCK WHERE
                  b-treal-2.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
          create treal-2.
          assign
          treal-2.gds-code = buf_bar-code.gds-code
          treal-2.cpay-code = buf_chk-gds-pay.pay-code
          treal-2.curr-code = buf_chk-gds-pay.curr-code
          treal-2.out-name = buf_cash-pay.obj-name
          treal-2.is-pay = yes
          treal-2.ii = (if avail b-treal-2
                        then b-treal-2.ii + 1
                        else 1)
          treal-2.pay-desk = v-pay-desk
          treal-2.prefix   = '':U
          .

      END.
      assign
      treal-2.netto = treal-2.netto + (if v-curr-r-b = {&r-b-base}
                                        or v-base-code = 0
                                        then buf_chk-gds-pay.tot-r-b
                                        else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
      treal-2.qnty1 = treal-2.qnty1 + buf_chk-gds-pay.eff-doc-qnty
      treal-2.qnty2 = treal-2.qnty2 + buf_chk-gds-pay.eff-doc-qnty * v-density
      treal-2.netto-rubl = treal-2.netto-rubl + (if v-curr-r-b = {&r-b-rubl}
                                        or v-base-code = 0
                                        then buf_chk-gds-pay.tot-r-b
                                        else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))

      .
    end. /*if p-petrol then do:*/
  end. /*when petrolium*/
  /*при экспорте - по каждому товару а не по группе*/
  WHEN {&gds-goods}  then do:
    if p-goods then do:
      /*если есть разброска по чекам и префикс участвует в выгрузке то здесь собираем по префиксу*/
      if p-by-pay-card-prefix
      and v-pay-card <> "other"
      then do:
        FIND FIRST b2-treal-3 No-LOCK WHERE
                  b2-treal-3.gds-code = buf_bar-code.gds-code
              AND b2-treal-3.cpay-code = buf_chk-gds-pay.pay-code
              AND b2-treal-3.curr-code = buf_chk-gds-pay.curr-code
              AND b2-treal-3.pay-desk = v-pay-desk
              AND b2-treal-3.prefix = v-pay-card No-ERROR.
        IF NOT AVAIL b2-treal-3 then do:
          FIND last b3-treal-3 No-LOCK WHERE
                    b3-treal-3.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
          create b2-treal-3.
          assign
          b2-treal-3.gds-code = buf_bar-code.gds-code
          b2-treal-3.cpay-code = buf_chk-gds-pay.pay-code
          b2-treal-3.curr-code = buf_chk-gds-pay.curr-code
          b2-treal-3.qnty1  =  0
          b2-treal-3.netto = 0
          b2-treal-3.out-name = buf_cash-pay.obj-name
          b2-treal-3.is-pay = yes
          b2-treal-3.ii =  (if avail b3-treal-3
                            then b3-treal-3.ii + 1
                            else 1)
          b2-treal-3.pay-desk = v-pay-desk
          b2-treal-3.prefix   = v-pay-card
          .

        END.
        assign
        b2-treal-3.netto = b2-treal-3.netto + (if v-curr-r-b = {&r-b-base}
                                              or v-base-code = 0
                                              then buf_chk-gds-pay.tot-r-b
                                              else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
        b2-treal-3.qnty1 = b2-treal-3.qnty1 + buf_chk-gds-pay.eff-doc-qnty
        b2-treal-3.netto-rubl = b2-treal-3.netto-rubl + (if v-curr-r-b = {&r-b-rubl}
                                                          or v-base-code = 0
                                                          then buf_chk-gds-pay.tot-r-b
                                                          else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))
        .
      end.
      FIND FIRST treal-3 No-LOCK WHERE
                treal-3.gds-code = buf_bar-code.gds-code
            AND treal-3.cpay-code = buf_chk-gds-pay.pay-code
            AND treal-3.curr-code = buf_chk-gds-pay.curr-code
            AND treal-3.pay-desk = v-pay-desk
            AND treal-3.prefix = '':U No-ERROR.
      IF NOT AVAIL treal-3 then do:
        FIND last b-treal-3 No-LOCK WHERE
                  b-treal-3.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
          create treal-3.
          assign
          treal-3.gds-code = buf_bar-code.gds-code
          treal-3.cpay-code = buf_chk-gds-pay.pay-code
          treal-3.curr-code = buf_chk-gds-pay.curr-code
          treal-3.qnty1  =  0
          treal-3.netto = 0
          treal-3.out-name = buf_cash-pay.obj-name
          treal-3.is-pay = yes
          treal-3.ii =  (if avail b-treal-3
                            then b-treal-3.ii + 1
                            else 1)
          treal-3.pay-desk = v-pay-desk
          treal-3.prefix   = '':U
          .
      END.
      assign
      treal-3.netto = treal-3.netto + (if v-curr-r-b = {&r-b-base}
                                      or v-base-code = 0
                                      then buf_chk-gds-pay.tot-r-b
                                      else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
      treal-3.qnty1 = treal-3.qnty1 + buf_chk-gds-pay.eff-doc-qnty
      treal-3.netto-rubl = treal-3.netto-rubl + (if v-curr-r-b = {&r-b-rubl}
                                                or v-base-code = 0
                                                then buf_chk-gds-pay.tot-r-b
                                                else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))
      .
    END. /*if p-goods then do:*/
  END. /*when goods*/
  WHEN {&gds-office} then do:
    if p-services then do:
        /*если есть выгрузка по префикса и это префикс участвующий в выгрузкн */
      if p-by-pay-card-prefix
      and v-pay-card <> "other"
      then do:
        FIND FIRST b2-treal-4 No-LOCK WHERE
                  b2-treal-4.gds-code = buf_bar-code.gds-code
              AND b2-treal-4.cpay-code = buf_chk-gds-pay.pay-code
              AND b2-treal-4.curr-code = buf_chk-gds-pay.curr-code
              AND b2-treal-4.is-pay = yes
              AND b2-treal-4.pay-desk = v-pay-desk
              AND b2-treal-4.prefix = v-pay-card No-ERROR.
        IF NOT AVAIL b2-treal-4 then do:
          FIND last b3-treal-4 No-LOCK WHERE
                    b3-treal-4.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
          create b2-treal-4.
          assign
          b2-treal-4.gds-code = buf_bar-code.gds-code
          b2-treal-4.cpay-code = buf_chk-gds-pay.pay-code
          b2-treal-4.curr-code = buf_chk-gds-pay.curr-code
          b2-treal-4.qnty1  =  0
          b2-treal-4.netto = 0
          b2-treal-4.out-name = buf_Cash-pay.obj-name
          b2-treal-4.is-pay = yes
          b2-treal-4.ii = (if avail b3-treal-4
                          then b3-treal-4.ii + 1
                          else 1)
          b2-treal-4.pay-desk = v-pay-desk
          b2-treal-4.prefix   = v-pay-card
          .
        END.
        assign
        b2-treal-4.netto = b2-treal-4.netto + (if v-curr-r-b = {&r-b-base}
                                              or v-base-code = 0
                                              then buf_chk-gds-pay.tot-r-b
                                              else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
        b2-treal-4.qnty1 = b2-treal-4.qnty1 + buf_chk-gds-pay.eff-doc-qnty
        b2-treal-4.netto-rubl = b2-treal-4.netto-rubl + (if v-curr-r-b = {&r-b-rubl}
                                                or v-base-code = 0
                                                then buf_chk-gds-pay.tot-r-b
                                                else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))
        .
      end.
      fIND FIRST treal-4 No-LOCK WHERE
                treal-4.gds-code = buf_bar-code.gds-code
            AND treal-4.cpay-code = buf_chk-gds-pay.pay-code
            AND treal-4.curr-code = buf_chk-gds-pay.curr-code
            AND treal-4.is-pay = yes
            AND treal-4.pay-desk = v-pay-desk
            AND treal-4.prefix = '':U  No-ERROR.
      IF NOT AVAIL treal-4 then do:
        FIND last b-treal-4 No-LOCK WHERE
                  b-treal-4.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
        create treal-4.
        assign
        treal-4.gds-code = buf_bar-code.gds-code
        treal-4.cpay-code = buf_chk-gds-pay.pay-code
        treal-4.curr-code = buf_chk-gds-pay.curr-code
        treal-4.qnty1  =  0
        treal-4.netto = 0
        treal-4.out-name = buf_Cash-pay.obj-name
        treal-4.is-pay = yes
        treal-4.ii = (if avail b-treal-4
                        then b-treal-4.ii + 1
                        else 1)
        treal-4.pay-desk = v-pay-desk
        treal-4.prefix   = '':U
        .
      END.
      assign
      treal-4.netto = treal-4.netto + (if v-curr-r-b = {&r-b-base}
                                      or v-base-code = 0
                                      then buf_chk-gds-pay.tot-r-b
                                      else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
      treal-4.qnty1 = treal-4.qnty1 + buf_chk-gds-pay.eff-doc-qnty
      treal-4.netto-rubl = treal-4.netto-rubl + (if v-curr-r-b = {&r-b-rubl}
                                                or v-base-code = 0
                                                then buf_chk-gds-pay.tot-r-b
                                                else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))
      .
    END. /*if p-services then do:*/
  END. /*WHEN {&gds-office} then do:*/
END CASE.

&endif

/* $Workfile$ e n d */