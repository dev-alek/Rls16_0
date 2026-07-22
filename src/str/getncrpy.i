/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура обработки записи типа T в спуле NCR

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure proc-tender :
define input parameter par-mode as integer no-undo .
define input parameter loc-exist as logical no-undo .
/*0 - chk-doc  ub.chk-pay
  1- chk-doc ub.chk-pay
*/

  do
  on error undo, return error
  :
    if loc-exist then return.
    if p-pos-type <> {&cd-type-ncr-as-r}
    and (code3 = '2') then return.
    assign
    tot_sum = dec( substr(n-entry[11], 9, 10) ) / 100
    pay_code = int( substr(n-entry[11], 1, 2) )
    curr_code = ( if pay_code = 1
                  then 0
                  else ?
                  )
    tot_sum = (if par-mode = 1 AND
                  (ub.chk-doc.chk-type = integer({&encashment}) OR
                  ub.chk-doc.chk-type = integer({&cd-expense}))
                then - 1
                else 1 ) * tot_sum
    time-oper_ =  int( substr( n-entry[4], 1, 2 ) ) * 3600 +
                  int( substr( n-entry[4], 3, 2 ) ) * 60  +
                  int( substr(n-entry[4], 5, 2) )
    pass-pay_ = int(substr(n-entry[8], 3, 1))
    pay-card_ = trim(n-entry[10])
    no-error
    .
    if error-status:error then do:
      {&error-in-file-format}
    end.
    if curr_code = ? then
    FIND FIRST ub.cash-pay WHERE
              ub.cash-pay.cdpay-code = pay_code no-lock no-error .
    else
    FIND FIRST ub.cash-pay WHERE
              ub.cash-pay.cdpay-code = pay_code AND
              ub.cash-pay.curr-code = 0  NO-LOCK NO-ERROR.
    assign
    curr_code = if available ub.cash-pay
                then ub.cash-pay.curr-code
                else 0
    .
    CASE par-mode:
      when 1 then do:
        if code2 <> "6":U
        or (p-pos-type = {&cd-type-ncr-as-r} and code3 <> "4")
        /*если = 6 то это неконтролируемые*/   then do:
          FIND ub.chk-pay WHERE
                ub.chk-pay.doc-code = ub.chk-doc.doc-code AND
                ub.chk-pay.curr-code = curr_code AND
                ub.chk-pay.pay-code = pay_code      NO-ERROR.
          if NOT available ub.chk-pay then  do:
            CREATE ub.chk-pay .
            assign
            lnp = lnp + 1
            ub.chk-pay.doc-code = ub.chk-doc.doc-code
            ub.chk-pay.line-num = lnp
            ub.chk-pay.chk-date = ub.chk-doc.chk-date
            ub.chk-pay.obj-code = shop-code
            ub.chk-pay.obj-type = shop-type
            ub.chk-pay.tot-rubl = 0
            ub.chk-pay.tot-sum = 0
            ub.chk-pay.tot-base = 0
            ub.chk-pay.pay-code = pay_code
            ub.chk-pay.curr-code = curr_code
            ub.chk-pay.time-oper = time-oper_
            ub.chk-pay.cash-rate = 1 /*?????*/
            ub.chk-pay.bank-rate = 1 /*?????*/
            ub.chk-pay.bank-scale = 1  /*?????*/
            ub.chk-pay.line-type = "":U
            ub.chk-pay.line-sign = (if ub.chk-doc.chk-type = integer({&encashment})
                                  or ub.chk-doc.chk-type =  integer({&cd-expense})
                                  then (chk-pay.tot-sum <= 0)
                                  else (chk-pay.tot-sum >= 0)
                                  )
            ub.chk-pay.is-error = no
            ub.chk-pay.pass-pay = pass-pay_
            ub.chk-pay.pay-card = ''
            .
          end.
          assign
          ub.chk-pay.tot-sum = ub.chk-pay.tot-sum + tot_sum
          .
        end.
      end. /*when 1*/
      when 0 then do:
        FIND ub.chk-pay WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code AND
              ub.chk-pay.curr-code = curr_code AND
              ub.chk-pay.pay-code = pay_code      NO-ERROR.
        if NOT available ub.chk-pay
        then  do:
          CREATE ub.chk-pay .
          assign
          lnp = lnp + 1
          ub.chk-pay.doc-code = ub.chk-doc.doc-code
          ub.chk-pay.line-num = lnp
          ub.chk-pay.chk-date = ub.chk-doc.chk-date
          ub.chk-pay.obj-code = shop-code
          ub.chk-pay.obj-type = shop-type
          ub.chk-pay.tot-rubl = 0
          ub.chk-pay.tot-sum = 0
          ub.chk-pay.tot-base = 0
          ub.chk-pay.pay-code = pay_code
          ub.chk-pay.curr-code = curr_code
          ub.chk-pay.time-oper = time-oper_
          ub.chk-pay.cash-rate = 1
          ub.chk-pay.bank-rate = 1
          ub.chk-pay.bank-scale = 1
          ub.chk-pay.pass-pay = 0
          ub.chk-pay.pay-card = pay-card_
          ub.chk-pay.line-type = "":U
          ub.chk-pay.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                              then (chk-pay.tot-sum >= 0)
                              else (chk-pay.tot-sum <= 0)
                              )
          ub.chk-pay.is-error = no
          .
        end.
        assign
        ub.chk-pay.tot-sum = ub.chk-pay.tot-sum + tot_sum
        .
      end. /*when par-mode = 0*/
    END CASE.
  end. /*doe*/

end procedure. /* proc-tender */


/* $Workfile$ e n d */