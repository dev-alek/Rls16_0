 /*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура отслыки конфигурации АЗС

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/05/05
Author: Bakhtadze Natalya
Creation date: 12/05/05

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure putc-pet :
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-version like ub.cash-desk.version no-undo .
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define input parameter p-cash-num like ub.cash-desk.cash-num  no-undo .

define variable v-gds-code like ub.goods.gds-code no-undo .
define variable IBM2-short as character no-undo .
DEFINE VARIABLE IBM-good-code-2 as character no-undo .

define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_pump for ub.pump.
define buffer buf_nozzle for ub.nozzle.
define buffer buf_pump-nozzle for ub.pump-nozzle.
define buffer buf_pl-pump for ub.pl-pump.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.

  do
  on error undo, return error
  :
    CASE p-pos-type:
      when {&cd-type-ibm} then do:
        put stream IbmStream unformatted "41 -1":U skip.
        for each cash-place,
            each buf_pl-gds no-lock where
                buf_pl-gds.obj-type = cash-place.obj-type
            and buf_pl-gds.obj-code = cash-place.obj-code
            and buf_pl-gds.pl-code = cash-place.pl-code
            and buf_pl-gds.status_ <> {&deleted-status},
            each cash-gds no-lock where
                 cash-gds.gds-code = buf_pl-gds.gds-code:
          if cash-gds.b-str = '':U then nEXT.
          assign
          IBM-good-code = "":U
          .
          run ibm-gdsc in this-procedure (
                                          input (p-pos-type = {&cd-type-maria}) /*p-zeros*/
                                        , output IBM-good-code
                                        , output IBM-good-code-2
                                        , output IBM2-short
                                        ) no-error .
          if IBM-good-code = "":U then
          assign
          IBM-good-code = IBM-good-code-2
          .
          put stream IBMStream unformatted
          '41' {&space-char}
          {&double-quote} action {&double-quote} {&space-char}
          cash-place.loc1 {&space-char}
          cash-place.pl-code {&space-char}
          {&double-quote}
          cash-place.pl-name
          {&double-quote} {&space-char}
          IBM-good-code {&space-char}
          (if buf_pl-gds.status_ = {&current-status}
           then 1
           else 0) {&space-char}
          OS2-time
          {&new-line}
          .
          v-gds-code = cash-gds.gds-code.
        end.
        v-gds-code = 0.
        for each buf_pl-pump-nozzle no-lock where
                buf_pl-pump-nozzle.obj-type = p-obj-type
            AND buf_pl-pump-nozzle.obj-code = i-obj-code
            and buf_pl-pump-nozzle.status_  <> {&deleted-status},
            first cash-place no-lock where
                  cash-place.obj-type = p-obj-type
              and cash-place.obj-code = i-obj-code
              and cash-place.pl-code = buf_pl-pump-nozzle.pl-code:
          find first buf_pl-gds-pump no-lock where
                    buf_pl-gds-pump.obj-type  = p-obj-type
                and buf_pl-gds-pump.obj-code  = i-obj-code
                and buf_pl-gds-pump.pump-code = buf_pl-pump-nozzle.pump-code
                and buf_pl-gds-pump.pl-code  = buf_pl-pump-nozzle.pl-code
                and buf_pl-gds-pump.status_   = {&current-status}  no-error.
          if available buf_pl-gds-pump
          then
          put stream IBMStream unformatted
          '42' {&space-char}
          {&double-quote} action {&double-quote}  {&space-char}
          buf_pl-pump-nozzle.pump-code {&space-char}
          buf_pl-pump-nozzle.nozzle-code {&space-char}
          cash-place.loc1 {&space-char}
          (if available buf_pl-gds-pump and
          buf_pl-gds-pump.status_ = {&current-status}
          then 1
          else 0) {&space-char}
          OS2-time
          {&new-line}
          .
        end.
        put stream Ibmstream unformatted "41 -2":U skip.
      end. /*when ibm*/
      when {&cd-type-ibm-xml} then do:
        for each cash-place,
            each buf_pl-gds no-lock where
                buf_pl-gds.obj-type = cash-place.obj-type
            and buf_pl-gds.obj-code = cash-place.obj-code
            and buf_pl-gds.pl-code = cash-place.pl-code
            and buf_pl-gds.status_ <> {&deleted-status},
            each cash-gds no-lock where
                 cash-gds.gds-code = buf_pl-gds.gds-code:
          if cash-gds.b-str = '':U then nEXT.
          assign
          IBM-good-code = "":U
          .
          run ibm-gdsc in this-procedure (
                                          input (p-pos-type = {&cd-type-maria}) /*p-zeros*/
                                        , output IBM-good-code
                                        , output IBM-good-code-2
                                        , output IBM2-short
                                        ) no-error .
          if IBM-good-code = "":U then
          assign
          IBM-good-code = IBM-good-code-2
          .
          run bgelib-tag-open in this-procedure ( input 2, input "Tank"
                                                , input substitute("ctrl='&1' tms='&2' code='&3'"
                                                , (if action = 'U' then 'ADD':U else 'DEL')
                                                , OS2-time, cash-place.pl-code)).

          run bgelib-tag-put in this-procedure ( input 3, input "TankNum"       , input string(integer(cash-place.loc1)), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "TankName"      , input substring(cash-place.pl-name, 1, 15), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "TankProduct"   , input IBM-good-code, input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "TankActive"    ,input (if buf_pl-gds.status_ = {&current-status}
                                                                                        then 1
                                                                                        else 0) , INPUT 1).
          run bgelib-tag-close in this-procedure ( input 2, input "Tank").
          v-gds-code = cash-gds.gds-code.


        end.
        for each buf_pl-pump-nozzle no-lock where
                buf_pl-pump-nozzle.obj-type = p-obj-type
            AND buf_pl-pump-nozzle.obj-code = i-obj-code
            and buf_pl-pump-nozzle.status_  <> {&deleted-status}
        break
        by buf_pl-pump-nozzle.obj-type
        by buf_pl-pump-nozzle.obj-code
        by buf_pl-pump-nozzle.pump-code:
          find first cash-place no-lock where
                cash-place.obj-type = p-obj-type
            and cash-place.obj-code = i-obj-code
            and cash-place.pl-code = buf_pl-pump-nozzle.pl-code no-error .
          find first buf_pl-gds-pump no-lock where
                    buf_pl-gds-pump.obj-type  = p-obj-type
                and buf_pl-gds-pump.obj-code  = i-obj-code
                and buf_pl-gds-pump.pump-code = buf_pl-pump-nozzle.pump-code
                and buf_pl-gds-pump.pl-code  = buf_pl-pump-nozzle.pl-code
                and buf_pl-gds-pump.status_   = {&current-status}  no-error.
          if first-of (buf_pl-pump-nozzle.pump-code) then do:
            run bgelib-tag-open in this-procedure ( input 2, input "FuelPump"
                                                  , input substitute("ctrl='&1' tms='&2' code='&3'"
                                                  , (if action = 'U' then 'ADD':U else 'DEL')
                                                  , OS2-time, buf_pl-pump-nozzle.pump-code)).
          end.
		  if available buf_pl-gds-pump
          then do :
	          run bgelib-tag-open in this-procedure ( input 3, input "FPFuel", input '':U).
	          if not available cash-place
	          or not available buf_pl-gds-pump
	          then do:
	            run bgelib-tag-put in this-procedure ( input 4, input "FPFCode"       , input string(0), input 1 ).
	          end.
	          else do:
	            find first cash-gds where cash-gds.gds-code = buf_pl-gds-pump.gds-code.
	            run ibm-gdsc in this-procedure (
	                                            input (p-pos-type = {&cd-type-maria}) /*p-zeros*/
	                                          , output IBM-good-code
	                                          , output IBM-good-code-2
	                                          , output IBM2-short
	                                          ) no-error .
	            if IBM-good-code = "":U then
	            assign
	            IBM-good-code = IBM-good-code-2
	            .
	            run bgelib-tag-put in this-procedure ( input 4, input "FPFCode"       , input IBM-good-code, input 1 ).
	          end.
	          run bgelib-tag-put in this-procedure ( input 4, input "FPFTank"       , input string(if available cash-place
	                                                                                               then integer(cash-place.loc1)
	                                                                                               else 0 ), input 1 ).
	          run bgelib-tag-put in this-procedure ( input 4, input "FPFNzl"        , input string(buf_pl-pump-nozzle.nozzle-code), input 1 ).
	          run bgelib-tag-put in this-procedure ( input 4, input "FPFActive"     , input string((if available buf_pl-gds-pump and
	                                                                                                 buf_pl-gds-pump.status_ = {&current-status}
	                                                                                                then 1
	                                                                                                else 0)), input 1).
	          if not available cash-place then do:
	            run bgelib-tag-put in this-procedure ( input 4, input "FPFUnused"       , input string(0), input 1 ).
	          end.
	          find first buf_pump-nozzle no-lock where
	                    buf_pump-nozzle.obj-type = p-obj-type
	               and  buf_pump-nozzle.obj-code = i-obj-code
	               and buf_pump-nozzle.pump-code = buf_pl-pump-nozzle.pump-code
	               and buf_pump-nozzle.nozzle-code = buf_pl-pump-nozzle.nozzle-code
	               and buf_pump-nozzle.status_  = {&current-status} no-error.
	          if available buf_pump-nozzle then do:
	            run bgelib-tag-put in this-procedure ( input 4, input "FPFNozzleID"       , input string(buf_pump-nozzle.ef-nid), input 1 ).
	          end.
	          run bgelib-tag-close in this-procedure ( input 3, input "FPFuel").
		  end.
          if last-of (buf_pl-pump-nozzle.pump-code) then do:
             run bgelib-tag-close in this-procedure ( input 2, input "FuelPump").
          end.
        end. /*for each buf_pl-pump-nozzle no-lock where*/
      end. /*when cd-tyupe-ibm-xml*/

    END CASE.
  end.

end procedure. /* putc-par */

/* $Workfile$ e n d */