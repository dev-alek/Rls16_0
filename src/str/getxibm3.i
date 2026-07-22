/*

$Revision: cd82ba7bd738, 2912, rls $
$Author: DRuban $
$Date: Пн ноя 22 19:49:14 2021 +0300 $
$Workfile: getxibm3.i $
$Archive: str/getxibm3.i $

Процедура обработки строки 03 в спул IBM-XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/30/05
Author: Bakhtadze Natalya
Creation date: 10/30/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: getxibm3.i $ $Revision: cd82ba7bd738, 2912, rls $".
{utl\parsjson.i}
procedure proc-03 :
define input parameter par-mode as integer no-undo .
define input parameter loc-exist as logical no-undo .
define variable lnp-spl as integer no-undo .
define buffer buf_temp-temp for temp-temp.
define buffer buf_chk-doc for tt-chk-doc.
define buffer buf_chk-doc-attr for tt-chk-doc-attr.
define buffer buf_chk-pay for tt-chk-pay.
define buffer buf_chk-pay-attr for tt-chk-pay-attr.
define variable i-cpdoc      as int no-undo.

/*0 - ub.chk-doc  ub.chk-pay
  1- ub.chk-doc ub.chk-pay
*/
/*Переменные для записи в таблицу chk-pay-attr*/
define variable c-attr-code   as character no-undo.
define variable c-attr-value  as character no-undo.
define variable vCPAgreement  as character no-undo.
define variable vCPWithdrawal as character no-undo.
define variable vsbpstat as character no-undo.
define variable vsbprrn as character no-undo.
define variable vqrpay  as character no-undo.

  _proc-03:
  do
  on error undo, return error
  :

    if not loc-exist then do:
      pay-card_ = "".
      for each buf_temp-temp where
              buf_temp-temp.record-name = "CPay":U
        and buf_temp-temp.id = v-id:

        CASE buf_temp-temp.field-name:
          when "CPCode":U then do:
            if p-pos-type = {&cd-type-IBM-XML}
            then do:
              if integer(buf_temp-temp.field-value) = ibm-ccm then do:
                   assign pay_code = 1
                   c-attr-code  = "IBM-CCM".
                   c-attr-value = 'yes'.
              end.     
              else assign pay_code = integer(buf_temp-temp.field-value)      no-error .
            end.
            else do:
              assign
              pay_code = convert-pay-code(p-pos-type, integer(buf_temp-temp.field-value), output curr_code)
              no-error .
            end.
          end.
          when "CPCurr":U then do:
            if p-pos-type = {&cd-type-IBM-XML}
            then
            assign
            curr_code = if kassa-rub-code = integer(buf_temp-temp.field-value)
                        then 0
                        else integer(buf_temp-temp.field-value)
            no-error .
            if p-pos-type = {&cd-type-autotank} then do:
              /*только нац вал!!! - это зашито в shattr41.w*/
              assign
              curr_code = 0 no-error.
            end.
          end.
          when "CPTotal":U then do:
            assign
            tot_sum = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPCard":U then do:
            assign
            pay-card_ = trim(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPRate":U then do:
            assign
            cass-rate = fdecimal(buf_temp-temp.field-value)
            rate-por = 0
            no-error .
          end.
          when "CPCBR":U then do:
            assign
            bank-rate_ = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPMCBR":U then do:
            assign
            bank-scale_ = integer(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPString":U then do:
            assign
            lnp-spl = integer(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPSHandCard":u then do:
            assign
            pass-pay_ =   (if integer(buf_temp-temp.field-value) = 1
                          then 1
                          else 0)
            no-error .
          end.
          when "CPDOC":U then do:
            do i-cpdoc = 1 to num-entries(buf_temp-temp.field-value,',':U):
                if num-entries(entry(i-cpdoc,buf_temp-temp.field-value),'=':U) >= 2 then do:
                    c-attr-code  = entry(1,entry(i-cpdoc,buf_temp-temp.field-value,','),'=':U).
                    c-attr-value = entry(2,entry(i-cpdoc,buf_temp-temp.field-value,','),'=':U).
                end.    
                
              else do:
                    c-attr-code  = "CPDOC".
                    c-attr-value = entry(i-cpdoc,buf_temp-temp.field-value,',').               
              end.
            end.
          end. /*when "CPDOC":U then do:*/
          when "CPAgreement" then do:
             vCPAgreement = buf_temp-temp.field-value.
          end.
          when "CPMisc" then do:
             vsbpstat = gettegjson(buf_temp-temp.field-value,"SBpStat").
             vsbprrn  = gettegjson(buf_temp-temp.field-value,"SBPRRN").
             vqrpay   = gettegjson(buf_temp-temp.field-value,"QRPay").
          end.
          when "CPWithdrawal" then do:
             vCPWithdrawal = buf_temp-temp.field-value.
          end.
          otherwise do:
            error-status:error = no.
          end.
        END CASE.
        if error-status:error then do:
          {&error-in-file-format}
        end.
        delete buf_temp-temp.
      end. /*for each buf_temp-temp*/
      assign
      time-oper_ =  v-time
      no-error
      .
      if error-status:error then do:
        {&error-in-file-format}
      end.

      find first buf_chk-doc NO-ERROR.
      find first buf_chk-pay-attr where 
            buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
        and buf_chk-pay-attr.line-num   = lnp-spl
        and buf_chk-pay-attr.attr-code  = 'RTA_RefundExport' no-error.
      if available buf_chk-pay-attr then do:
        assign
          buf_chk-pay-attr.attr-value = buf_chk-pay-attr.attr-value + c-attr-value
          no-error.
        leave _proc-03.      
      end.
      
      CASE par-mode:
        when 0
        or when 1
        then do:
          FIND buf_chk-pay WHERE
                buf_chk-pay.doc-code = buf_chk-doc.doc-code
            AND buf_chk-pay.curr-code = curr_code
            AND buf_chk-pay.pay-code = pay_code
            and buf_chk-pay.line-num = lnp-spl
            NO-ERROR.
          if NOT available buf_chk-pay
          then  do:
          
            
            CREATE buf_chk-pay .
            assign
            buf_chk-pay.doc-code = buf_chk-doc.doc-code
            buf_chk-pay.line-num = lnp-spl
            buf_chk-pay.chk-date = buf_chk-doc.chk-date
            buf_chk-pay.obj-code = shop-code
            buf_chk-pay.obj-type = shop-type
            buf_chk-pay.tot-rubl = 0
            buf_chk-pay.tot-sum  = 0
            buf_chk-pay.tot-base = 0
            buf_chk-pay.pay-code = pay_code
            buf_chk-pay.curr-code = curr_code
            buf_chk-pay.time-oper = time-oper_
            cass-rate = cass-rate * exp( 10, int( rate-por ) )
            buf_chk-pay.cash-rate = cass-rate
            buf_chk-pay.bank-rate = bank-rate_
            buf_chk-pay.bank-scale = bank-scale_
            buf_chk-pay.pass-pay  = pass-pay_
            buf_chk-pay.pay-card  = pay-card_
            buf_chk-pay.line-type = "":U
            buf_chk-pay.line-sign = (if buf_chk-doc.chk-type = integer({&rcpt-sale})
                                then (buf_chk-pay.tot-sum >= 0)
                                else (buf_chk-pay.tot-sum <= 0)
                                )
            buf_chk-pay.is-error = no
            .
            assign 
              pay-card_ = "".
            if not (c-attr-code = "" or c-attr-code = ?) then do:
              create buf_chk-pay-attr.
              assign 
              buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
              buf_chk-pay-attr.line-num   = lnp-spl
              buf_chk-pay-attr.attr-code  = c-attr-code
              buf_chk-pay-attr.attr-value = c-attr-value
              no-error.
            end.
            if vCPAgreement ne "" and vCPAgreement ne ? 
            then do:
              create buf_chk-pay-attr.
              assign 
              buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
              buf_chk-pay-attr.line-num   = lnp-spl
              buf_chk-pay-attr.attr-code  = "CPAgreement"
              buf_chk-pay-attr.attr-value = vCPAgreement
              no-error.
            end.
            if vsbpstat ne "" and vsbpstat ne ? 
            then do:
               create buf_chk-pay-attr.
               assign 
               buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
               buf_chk-pay-attr.line-num   = lnp-spl
               buf_chk-pay-attr.attr-code  = "SBPStat"
               buf_chk-pay-attr.attr-value = vsbpstat
               no-error.
            end.
            if vsbprrn ne "" and vsbprrn ne ? 
            then do:
               create buf_chk-pay-attr.
               assign 
               buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
               buf_chk-pay-attr.line-num   = lnp-spl
               buf_chk-pay-attr.attr-code  = "SBPRRN"
               buf_chk-pay-attr.attr-value = vsbprrn
               no-error.
            end.
            if vqrpay ne "" and vqrpay ne ? 
            then do:
               create buf_chk-pay-attr.
               assign 
               buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
               buf_chk-pay-attr.line-num   = lnp-spl
               buf_chk-pay-attr.attr-code  = "QRPay"
               buf_chk-pay-attr.attr-value = vqrpay
               no-error.
            end.
            if vCPWithdrawal ne "" and vCPWithdrawal ne ? and dec(vCPWithdrawal) ne 0  
            then do:
              create buf_chk-pay-attr.
              assign 
              buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
              buf_chk-pay-attr.line-num   = lnp-spl
              buf_chk-pay-attr.attr-code  = "CPWithdrawal"
              buf_chk-pay-attr.attr-value = left-trim(string (dec(vCPWithdrawal),">>>>>>>>>>>9.99") ) 
              no-error.
            end.
            
          end.
          assign
          buf_chk-pay.tot-sum = buf_chk-pay.tot-sum + tot_sum
          .
        end.
        

      END CASE.
    end. /* if not loc-exist */
  end.

end procedure. /* proc-03 */

procedure proc-cash :
define input parameter loc-exist as logical no-undo .
define variable par-val_ as decimal no-undo .
define variable lnp-spl as integer no-undo .
define variable tot_rubl as decimal no-undo .
define variable tot_base as decimal no-undo .
define buffer buf_temp-temp for temp-temp.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-pay for ub.chk-pay.

  do
  on error undo, return error
  :
    if not loc-exist then do:
      for each buf_temp-temp where
              buf_temp-temp.record-name = "Cash":U
        AND buf_temp-temp.id = v-id:
        CASE buf_temp-temp.field-name:
          when "CSValue":U then do:
            assign
            tot_sum = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CCCode":U then do:
            assign
            curr_code = if kassa-rub-code = integer(buf_temp-temp.field-value)
                        then 0
                        else integer(buf_temp-temp.field-value)
            no-error .
          end.
          when "CAMount":U then do:
            assign
            curr-string-qnty = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CValue":u then do:
            assign
            par-val_ =   fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPString":u then do:
            assign
            lnc =   integer(buf_temp-temp.field-value)
            no-error .
          end.
          when "CString":u then do:
            assign
            lnp-spl =   integer(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPayCode":U then do:
            if p-pos-type = {&cd-type-IBM-XML}
            or p-pos-type = {&cd-type-autotank}
            then do:
              assign
              pay_code = integer(buf_temp-temp.field-value)
              no-error .
            end.
          end.
          when "CCCode":U then do:
            if p-pos-type = {&cd-type-IBM-XML}
            or p-pos-type = {&cd-type-autotank}
            then
            assign
            curr_code = if kassa-rub-code = integer(buf_temp-temp.field-value)
                        then 0
                        else integer(buf_temp-temp.field-value)
            no-error .
          end.
          when "CRate":U then do:
            assign
            rate-por = 0
            cass-rate = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CSBase" then do:
            assign
            tot_base = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CSNat" then do:
            assign
            tot_rubl = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          otherwise do:
            error-status:error = no.
          end.
        END CASE.
        if error-status:error then do:
          {&error-in-file-format}
        end.
        delete buf_temp-temp.
      end. /*for each buf_temp-temp*/
      assign
      time-oper_ =  v-time
      no-error
      .
      
      find first buf_chk-doc no-error.
            
      if par-val_ = 0
      and buf_chk-doc.chk-type = integer({&cd-drawer}) then do:
      end.
      else do:
      FIND buf_chk-pay WHERE
            buf_chk-pay.doc-code = buf_chk-doc.doc-code
        AND buf_chk-pay.curr-code = curr_code
        AND buf_chk-pay.pay-code = pay_code
        and buf_chk-pay.line-num = lnp-spl
        and buf_chk-pay.src-val = par-val_
        NO-ERROR.
      if NOT available buf_chk-pay then  do:
        CREATE buf_chk-pay .
        assign
        buf_chk-pay.doc-code = buf_chk-doc.doc-code
        buf_chk-pay.line-num = lnp-spl
        buf_chk-pay.chk-date = buf_chk-doc.chk-date
        buf_chk-pay.obj-code = shop-code
        buf_chk-pay.obj-type = shop-type
        buf_chk-pay.tot-rubl = 0
        buf_chk-pay.tot-sum = 0
        buf_chk-pay.tot-base = 0
        buf_chk-pay.pay-code = pay_code
        buf_chk-pay.curr-code = curr_code
        buf_chk-pay.time-oper = time-oper_
        cass-rate = cass-rate * exp( 10, int( rate-por ) )
        buf_chk-pay.cash-rate = cass-rate
        buf_chk-pay.bank-rate = 1
        buf_chk-pay.bank-scale = 1
        /*
        ub.chk-pay.bank-rate = bank-rate_
        ub.chk-pay.bank-scale = bank-scale_
        */
        buf_chk-pay.pass-pay = 1
        buf_chk-pay.pay-card = ''
        buf_chk-pay.line-type = "":U
        buf_chk-pay.line-sign = (if buf_chk-doc.chk-type = integer({&encashment})
                              or buf_chk-doc.chk-type =  integer({&cd-expense}
                              )
                            then (buf_chk-pay.tot-sum <= 0)
                            else (buf_chk-pay.tot-sum >= 0)
                            )
        buf_chk-pay.is-error = no
        .
      end.
      assign
      buf_chk-pay.tot-sum = buf_chk-pay.tot-sum + (if par-val_ = 0
                                     then tot_sum
                                     else 0)
      .
      if par-val_ > 0
      or curr-string-qnty <> 0 then do:
        assign
        buf_chk-pay.src-qnty = curr-string-qnty
        buf_chk-pay.src-val  = par-val_
        buf_chk-pay.tot-sum = par-val_ * curr-string-qnty
        .
      end.
      end. /*else if par-val_ = 0 */
    end. /* not loc-exist*/
  end.

end procedure. /* proc-cash */


/* $Workfile: getxibm3.i $ e n d */