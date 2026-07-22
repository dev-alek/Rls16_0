/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/05/07
Author: Bakhtadze Natalya
Creation date: 11/05/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

define variable v-pay-desk as integer   no-undo .
DEFINE BUFFER b-treal-2 for treal-2.
DEFINE BUFFER b-treal-3 for treal-3.
DEFINE BUFFER b-treal-4 for treal-4.
DEFINE BUFFER b2-treal-2 for treal-2.
DEFINE BUFFER b2-treal-3 for treal-3.
DEFINE BUFFER b2-treal-4 for treal-4.
&else

CASE entry(1, buf_chk-gds-pay.line-type, {&delim-par}):
  WHEN {&petrolium}  then do:
    FIND FIRST treal-2 No-LOCK WHERE
              treal-2.gds-code = buf_bar-code.gds-code
          AND treal-2.cpay-code = buf_chk-gds-pay.pay-code
          AND treal-2.curr-code = buf_chk-gds-pay.curr-code
          AND treal-2.is-pay = yes
          and treal-2.pump = buf_chk-gds.pump
          AND treal-2.pay-desk = v-pay-desk
          AND treal-2.prefix = buf_chk-gds-pay.pay-card  No-ERROR.
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
        treal-2.pump = buf_chk-gds.pump
        treal-2.prefix = buf_chk-gds-pay.pay-card
        .
    END.
    assign
    treal-2.netto = treal-2.netto + (if v-curr-r-b = {&r-b-base}
                                      or v-base-code = 0
                                      then buf_chk-gds-pay.tot-r-b
                                      else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
    treal-2.qnty1 = treal-2.qnty1 + buf_chk-gds-pay.eff-doc-qnty
    treal-2.netto-rubl = treal-2.netto-rubl + (if v-curr-r-b = {&r-b-rubl}
                                      or v-base-code = 0
                                      then buf_chk-gds-pay.tot-r-b
                                      else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))

    .
  end. /*when petrolium*/
  /*при экспорте - по каждому товару а не по группе*/
  WHEN {&gds-goods}  then do:
    FIND FIRST treal-3 No-LOCK WHERE
              treal-3.gds-code = buf_bar-code.gds-code
          AND treal-3.cpay-code = buf_chk-gds-pay.pay-code
          AND treal-3.curr-code = buf_chk-gds-pay.curr-code
          AND treal-3.pay-desk = v-pay-desk
          AND treal-3.prefix = buf_chk-gds-pay.pay-card  No-ERROR.
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
        treal-3.prefix   = buf_chk-gds-pay.pay-card
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
  END. /*when goods*/
  WHEN {&gds-office} then do:
    fIND FIRST treal-4 No-LOCK WHERE
              treal-4.gds-code = buf_bar-code.gds-code
          AND treal-4.cpay-code = buf_chk-gds-pay.pay-code
          AND treal-4.curr-code = buf_chk-gds-pay.curr-code
          AND treal-4.is-pay = yes
          AND treal-4.pay-desk = v-pay-desk
          AND treal-4.prefix = buf_chk-gds-pay.pay-card  No-ERROR.
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
      treal-4.prefix   = buf_chk-gds-pay.pay-card
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
  END. /*WHEN {&gds-office} then do:*/
END CASE.

&endif

/* $Workfile$ e n d */