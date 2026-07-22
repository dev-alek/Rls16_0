 /*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура отслыки справочника ОСС

Автор: Морозов Александр Сергеевич
Дата создания: 02/14/14
Author: Alexandr Morozov
Creation date: 02/14/14

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ ref/extclass.i }

procedure putc-oss :
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-version like ub.cash-desk.version no-undo .
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define input parameter p-cash-num like ub.cash-desk.cash-num  no-undo .
define input parameter action as character no-undo .
define input parameter pSubs as character no-undo .
/*DEFINE INPUT PARAMETER selective as integer no-undo.*/

define buffer buf_OperServ for ub.OperServ.

define variable v-OsType     as character no-undo .
define variable ii           as integer   no-undo .
define variable v-sum        as decimal   no-undo .
  do
  on error undo, return error
  :
  pSubs = trim(pSubs,{&delim-cmd}) .  
  if pSubs = "" then do:
        if action <> 'D' then do:
      for each buf_OperServ where buf_OperServ.Status_ = 0:
          v-sum = buf_OperServ.CommPerc + buf_OperServ.CommSumm .
          run bgelib-tag-open in this-procedure ( input 2, input "OperServ", input substitute("ctrl='&2' tms='&3' code='&1'", string (buf_OperServ.id), "ADD":u, OS2-time)).
          run bgelib-tag-put in this-procedure ( input 3, input "OSCode":U, input string (buf_OperServ.id), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSName":U, input string(buf_OperServ.OSname), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSQuantMin":U, input string(buf_OperServ.QuantMin), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSQuantMax":U, input string(buf_OperServ.QuantMax), input 1 ).
/*          run bgelib-tag-put in this-procedure ( input 3, input "OSGroup":U, input string (""), input 1 ). /*???????*/*/
          run bgelib-tag-put in this-procedure ( input 3, input "OSSumMin":U, input string(buf_OperServ.SummMin), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSSumMax":U, input string(buf_OperServ.SummMax), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSSumAtent":U, input string(buf_OperServ.SummAtent), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSComType":U, input string(if v-sum > 0 then string(buf_OperServ.CommType) else "0"), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSComPerc":U, input string(buf_OperServ.CommPerc), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSComSum":U, input string(buf_OperServ.CommSumm), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSPreAvt":U, input string(if buf_OperServ.PreAAvt = true then "1" else "0"), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSPreSlip":U, input string(if buf_OperServ.PreSlip = true then "1" else "0"), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSSlipName":U, input string(buf_OperServ.SlipName), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSOperType":U, input string(buf_OperServ.CalcType), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSAgntSign":U, input string(buf_OperServ.AgentFlag), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSPayAgntPhn":U, input string(buf_OperServ.AgentTel), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSPayAgntSgn":U, input string(buf_OperServ.AgentFlagRasch), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSPayAgntTrnsct":U, input string(buf_OperServ.AgentOpere), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSTrnsfOperName":U, input string(buf_OperServ.OperName), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSTrnsfOperAddr":U, input string(buf_OperServ.OperAddr), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSTrnsfOperINN":U, input string(buf_OperServ.OperInn), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSTrnsfOperPhn":U, input string(if buf_OperServ.OperTelTran <> ? then buf_OperServ.OperTelTran else ""), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSProvidName":U, input string(buf_OperServ.SuppName), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSProvidPhn":U, input string(if buf_OperServ.SuppTel <> ? then buf_OperServ.SuppTel else ""), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSProvidINN":U, input string(buf_OperServ.InnSupp), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSObtainOperPhn":U, input string(if buf_OperServ.OperTel <> ? then buf_OperServ.OperTel else ""), input 1 ).
          case buf_OperServ.OsType:
            when 0 then do:
              v-OsType = "".
            end.
            when 1 then do:
              v-OsType = "mobile".
            end.
            when 2 then do:
              v-OsType = "autohelp".
            end.
            when 3 then do:
              v-OsType = "remittance".
            end.  
            when 5 then do:
              v-OsType = "cashingout" .
            end.  
          end.  
          run bgelib-tag-put in this-procedure ( input 3, input "OSExtHndl":U, input string(v-OsType), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSItemCode":U, input string(if buf_OperServ.gds-code <> ? then buf_OperServ.gds-code else 0), input 1 ).  
        run bgelib-tag-close in this-procedure ( input 2, input "OperServ").    
      end. /*for each buf_OperServ where buf_OperServ.Status_ = 0:*/
      end.
    else do:
      run bgelib-tag-open in this-procedure ( input 2, input "OperServ", input substitute("ctrl='&2' code='&1'", "*", "DEL":u)).
      run bgelib-tag-close in this-procedure ( input 2, input "OperServ").
    end. 
    
    end.
    else do:
      do ii = 1 to num-entries (pSubs,{&delim-cmd}):
            for each buf_OperServ where buf_OperServ.Status_ = 0 and buf_OperServ.id = integer(entry(ii,pSubs,{&delim-cmd})):
        if action <> 'D' then do:
          v-sum = buf_OperServ.CommPerc + buf_OperServ.CommSumm .
          run bgelib-tag-open in this-procedure ( input 2, input "OperServ", input substitute("ctrl='&2' tms='&3' code='&1'", string (buf_OperServ.id), "ADD":u, OS2-time)).
          run bgelib-tag-put in this-procedure ( input 3, input "OSCode":U, input string (buf_OperServ.id), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSName":U, input string(buf_OperServ.OSname), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSQuantMin":U, input string(buf_OperServ.QuantMin), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSQuantMax":U, input string(buf_OperServ.QuantMax), input 1 ).
/*          run bgelib-tag-put in this-procedure ( input 3, input "OSGroup":U, input string (""), input 1 ). /*???????*/*/
          run bgelib-tag-put in this-procedure ( input 3, input "OSSumMin":U, input string(buf_OperServ.SummMin), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSSumMax":U, input string(buf_OperServ.SummMax), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSSumAtent":U, input string(buf_OperServ.SummAtent), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSComType":U, input string(if v-sum > 0 then string(buf_OperServ.CommType) else "0"), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSComPerc":U, input string(buf_OperServ.CommPerc), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSComSum":U, input string(buf_OperServ.CommSumm), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSPreAvt":U, input string(if buf_OperServ.PreAAvt = true then "1" else "0"), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSPreSlip":U, input string(if buf_OperServ.PreSlip = true then "1" else "0"), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSSlipName":U, input string(buf_OperServ.SlipName), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSOperType":U, input string(buf_OperServ.CalcType), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSAgntSign":U, input string(buf_OperServ.AgentFlag), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSPayAgntPhn":U, input string(buf_OperServ.AgentTel), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSPayAgntSgn":U, input string(buf_OperServ.AgentFlagRasch), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSPayAgntTrnsct":U, input string(buf_OperServ.AgentOpere), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSTrnsfOperName":U, input string(buf_OperServ.OperName), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSTrnsfOperAddr":U, input string(buf_OperServ.OperAddr), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSTrnsfOperINN":U, input string(buf_OperServ.OperInn), input 1 ).
		  run bgelib-tag-put in this-procedure ( input 3, input "OSTrnsfOperPhn":U, input string(if buf_OperServ.OperTelTran <> ? then buf_OperServ.OperTelTran else ""), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSProvidName":U, input string(buf_OperServ.SuppName), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSProvidPhn":U, input string(if buf_OperServ.SuppTel <> ? then buf_OperServ.SuppTel else ""), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSProvidINN":U, input string(buf_OperServ.InnSupp), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "OSObtainOperPhn":U, input string(if buf_OperServ.OperTel <> ? then buf_OperServ.OperTel else ""), input 1 ).

          case buf_OperServ.OsType:
            when 0 then do:
              v-OsType = "".
            end.
            when 1 then do:
              v-OsType = "mobile".
            end.
            when 2 then do:
              v-OsType = "autohelp".
            end.
            when 3 then do:
              v-OsType = "remittance".
            end.  
            when 5 then do:
              v-OsType = "cashingout" .
            end.              
          end.  
          run bgelib-tag-put in this-procedure ( input 3, input "OSExtHndl":U, input string(v-OsType), input 1 ). 
          run bgelib-tag-put in this-procedure ( input 3, input "OSItemCode":U, input string(if buf_OperServ.gds-code <> ? then buf_OperServ.gds-code else 0), input 1 ).  
        run bgelib-tag-close in this-procedure ( input 2, input "OperServ").    
  
      end. /*for each buf_OperServ where buf_OperServ.Status_ = 0:*/
    else do:
      run bgelib-tag-open in this-procedure ( input 2, input "OperServ", input substitute("ctrl='&2' code='&1'", "*", "DEL":u)).
      run bgelib-tag-close in this-procedure ( input 2, input "OperServ").
    end. 
    end.
    end.
    end.  
    end.
    
 

end procedure. /* putc-par */

/* $Workfile$ e n d */