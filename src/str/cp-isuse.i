/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/28/08
Author: Bakhtadze Natalya
Creation date: 03/28/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ ref/cp-attr.i }

FUNCTION cp-isuse returns logical ( input p-cdpay-code as integer
                                   ,input p-curr-code as integer
                                   ,input p-host-code as integer
                                   ,input p-obj-type as character
                                   ,input p-obj-code as integer
                                   ,input p-cp-is-use as logical
                                   ,input p-cash-num as integer
                                   ,input p-pos-type as character
                                   ):
define variable v-value as character no-undo .
define variable v-type as character no-undo .

if p-cp-is-use then do:
  run cp-attr-value  in this-procedure (
                                           input p-cdpay-code
                                          ,input p-curr-code
                                          ,input p-host-code
                                          ,input p-obj-type
                                          ,input p-obj-code
                                          ,input {&cp-attr-is-use}
                                          ,output v-value
                                          ,output v-type) no-error .
  if error-status:error
  or v-value = '':u then do:
    run cp-attr-value  in this-procedure (
                                             input p-cdpay-code
                                            ,input p-curr-code
                                            ,input p-host-code
                                            ,input '':U /*p-obj-type     */
                                            ,input  0 /*p-obj-code     */
                                            ,input {&cp-attr-is-use}
                                            ,output v-value
                                            ,output v-type) no-error .
    if error-status:error
    or v-value = '':u then do:
      run cp-attr-value  in this-procedure (
                                              input  p-cdpay-code
                                              ,input p-curr-code
                                              ,input  0 /*p-host-code*/
                                              ,input  '':U /*p-obj-type*/
                                              ,input  0  /*p-obj-code*/
                                              ,input  {&cp-attr-is-use}
                                              ,output v-value
                                              ,output v-type) no-error .
    end.
  end.
  if v-value <> '*':U
  and lookup(string(p-cash-num) + {&comma-char} + p-pos-type, v-value, {&delim-par}) = 0 then do:
    return no.
  end.
end.
return yes.
END FUNCTION.

/* $Workfile$ e n d */