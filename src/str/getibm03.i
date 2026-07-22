/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура обработки строки 03 в спуле IBM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure proc-03 :
define input parameter loc-exist as logical no-undo .

  do
  on error undo, return error
  :
    assign
    v-end-of-check = yes
    pay-card_ = ""
    .
    if not loc-exist then do:
      assign
      tot_sum = dec( n-entry[5] )
      curr_code = ( if kassa-rub-code = INT(n-entry[4] )
                    then 0
                    else int( n-entry[4] )
                  )
      pay_code = int(n-entry[2])
      cass-rate = dec( substr( n-entry[6], 1, 11 ) )
      rate-por = int( substr( n-entry[6], 13, 3 ) )
      time-oper_ =  (if ibmspool ="4"
                    then
                          (
                          int( substr( n-entry[10], 1, 2 ) ) * 3600 +
                          int( substr( n-entry[10], 3, 2 ) ) * 60  +
                          int( substr(n-entry[10], 5, 2) )
                          )
                    else ub.chk-doc.chk-time
                    )
      bank-rate_ = dec(n-entry[7])
      bank-scale_ = int(n-entry[8])
      pass-pay_ = int(n-entry[9])
      pay-card_ =  (if n-entry[3] <> "0":U
                    then trim(n-entry[3])
                    else "":U
                    )
      no-error
      .
      if error-status:error then do:
        {&error-in-file-format}
      end.
      FIND ub.chk-pay WHERE
            ub.chk-pay.doc-code = ub.chk-doc.doc-code AND
            ub.chk-pay.curr-code = curr_code AND
            ub.chk-pay.pay-code = pay_code  
            /* AND
            ub.chk-pay.line-num = lnp + 1  */
            NO-ERROR.
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
        cass-rate = cass-rate * exp( 10, int( rate-por ) )
        ub.chk-pay.cash-rate = cass-rate
        ub.chk-pay.bank-rate = bank-rate_
        ub.chk-pay.bank-scale = bank-scale_
        ub.chk-pay.pass-pay = pass-pay_
        ub.chk-pay.pay-card = pay-card_
        ub.chk-pay.line-type = "":U
        ub.chk-pay.line-sign = (if ub.chk-doc.chk-type = integer({&rcpt-sale})
                            or not (chk-doc.chk-type = integer({&encashment})
                                    or
                                    ub.chk-doc.chk-type =  integer({&cd-expense})
                                    )
                            then (chk-pay.tot-sum >= 0)
                            else (chk-pay.tot-sum <= 0)
                            )
        ub.chk-pay.is-error = no
        .
      end.
      assign
      ub.chk-pay.tot-sum = ub.chk-pay.tot-sum + tot_sum
      .      
    end. /* if not loc-exist */
  end.

end procedure. /* proc-03 */


/* $Workfile$ e n d */