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

define variable pychk_without-src-code as logical no-undo .
DEFINE BUFFER b-treal-3 for treal-3.

&else

   FIND FIRST treal-3 No-LOCK WHERE
             treal-3.gds-code = buf_bar-code.gds-code
        AND  treal-3.is-out   = (chk-doc.chk-type = integer({&rcpt-sale})) AND
                      (
                      p-without-src-code = yes
                      or
                      treal-3.src-code = buf_chk-gds.src-code)
         AND treal-3.is-pay = yes No-ERROR.
   IF NOT AVAIL treal-3 then do:
     FIND last b-treal-3 No-LOCK WHERE
                b-treal-3.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
     create treal-3.
     assign
     treal-3.gds-code = buf_bar-code.gds-code
     treal-3.is-out   = (ub.chk-doc.chk-type = integer({&rcpt-sale}))
     treal-3.src-code = (if p-without-src-code then "":U else buf_chk-gds.src-code)
     treal-3.qnty1    = 0
     treal-3.netto    = 0
     treal-3.out-name = buf_cash-pay.obj-name
     treal-3.is-pay   = yes
     treal-3.ii       =  (if avail b-treal-3
                          then b-treal-3.ii + 1
                          else 1)
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
   treal-3.rest-qnty = treal-3.qnty1
   .
&endif

/* $Workfile$ e n d */