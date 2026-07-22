/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сбор данных для отчета с разброской по платежам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/05/07
Author: Bakhtadze Natalya
Creation date: 11/05/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then
define variable pychk_rv as integer no-undo .
DEFINE BUFFER b-treal-3 for treal-3.

&else

if x-SelectGood  = {&g-choice} then do:
  find first gds-list no-lock where
          gds-list.gds-code = buf_bar-code.gds-code no-error .
end.
if x-SelectGood  = {&g-all}
or available gds-list then do:
    FIND FIRST treal-3 No-LOCK WHERE
              treal-3.gds-code = buf_bar-code.gds-code
          AND treal-3.cpay-code = buf_chk-gds-pay.pay-code
          AND treal-3.curr-code = buf_chk-gds-pay.curr-code
          AND treal-3.rv = pychk_rv  No-ERROR.
    IF NOT AVAIL treal-3 then do:
      FIND last b-treal-3 No-LOCK WHERE
                b-treal-3.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
      create treal-3.
      assign
      treal-3.gds-code = buf_bar-code.gds-code
      treal-3.rv = pychk_rv
      treal-3.cpay-code = buf_chk-gds-pay.pay-code
      treal-3.curr-code = buf_chk-gds-pay.curr-code
      treal-3.qnty1  =  0
      treal-3.netto = 0
      treal-3.out-name = buf_cash-pay.obj-name
      treal-3.is-pay = yes
      treal-3.ii =  (if avail b-treal-3
                    then b-treal-3.ii + 1
                    else 1)
      .

    END. /*IF NOT AVAIL treal-3 then do:*/
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
    /*если это запись в первый раз обрабатывается в текущей продаже то обнулим поля сумм для однйо продажи*/
    treal-3.netto-inkas = (if treal-3.inkas-code <> buf_inkas.inkas-code
                          then 0
                          else treal-3.netto-inkas)
    treal-3.netto-rubl-inkas = (if treal-3.inkas-code <> buf_inkas.inkas-code
                                then 0
                                else treal-3.netto-rubl-inkas)
    treal-3.vat-pc      = if treal-3.inkas-code <> buf_inkas.inkas-code
                          then -1
                          else treal-3.vat-pc
    treal-3.inkas-code        = if treal-3.inkas-code <> buf_inkas.inkas-code
                                then buf_inkas.inkas-code
                                else treal-3.inkas-code
    treal-3.netto-inkas = treal-3.netto-inkas + (if v-curr-r-b = {&r-b-base}
                                                  or v-base-code = 0
                                                  then buf_chk-gds-pay.tot-r-b
                                                  else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
    treal-3.netto-rubl-inkas = treal-3.netto-rubl-inkas + (if v-curr-r-b = {&r-b-rubl}
                                                            or v-base-code = 0
                                                            then buf_chk-gds-pay.tot-r-b
                                                            else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))
    .
end. /*if x-SelectGood  = {&g-all}*/
&Endif